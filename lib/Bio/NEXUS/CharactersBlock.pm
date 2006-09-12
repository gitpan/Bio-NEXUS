#######################################################################
# CharactersBlock.pm
#######################################################################
# Author: Chengzhi Liang, Weigang Qiu, Eugene Melamud, Peter Yang, Thomas Hladish
# $Id: CharactersBlock.pm,v 1.65 2006/09/11 23:09:28 thladish Exp $

#################### START POD DOCUMENTATION ##########################

=head1 NAME

Bio::NEXUS::CharactersBlock - Represents a CHARACTERS Block (Data or Characters) of a NEXUS file

=head1 SYNOPSIS

$block_object = new Bio::NEXUS::CharactersBlock($type, $block, $verbose, $taxlabels_ref);

=head1 DESCRIPTION

This is a class representing a Characters Block in a NEXUS file.  Characters Blocks generally contain state data for a set of characters for each taxon in the Taxa Block.  One common use of a Characters Block is to house multiple sequence alignments.

=head1 FEEDBACK

All feedbacks (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Chengzhi Liang (liangc@umbi.umd.edu)
 Weigang Qiu (weigang@genectr.hunter.cuny.edu)
 Eugene Melamud (melamud@carb.nist.gov)
 Peter Yang (pyang@rice.edu)
 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.65 $

=head1 METHODS

=cut

package Bio::NEXUS::CharactersBlock;

use strict;
use Data::Dumper;
use Carp;
use Bio::NEXUS::Functions;
use Bio::NEXUS::TaxUnitSet;
use Bio::NEXUS::MatrixBlock;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::MatrixBlock);

=head2 new

 Title   : new
 Usage   : block_object = new Bio::NEXUS::CharactersBlock($block_type, $commands, $verbose, $taxa);
 Function: Creates a new Bio::NEXUS::CharactersBlock object
 Returns : Bio::NEXUS::CharactersBlock object
 Args    : type (string), the commands/comments to parse (array ref), and a verbose flag (0 or 1)

=cut

sub new {
    my ( $class, $type, $commands, $verbose, $taxa ) = @_;
    unless ($type) { ( $type = lc $class ) =~ s/Bio::NEXUS::(.+)Block/$1/i; }
    my $self = { type => $type };
    bless $self, $class;
    $self->set_taxlabels($taxa);
    $self->{'otuset'} = new Bio::NEXUS::TaxUnitSet();
    $self->_parse_block( $commands, $verbose )
        if ( ( defined $commands ) and @$commands );

    return $self;
}

sub _post_processing {
    my ($self) = @_;

    # We prefer using the more versatile/experessive character-state labels,
    # rather than state labels
    if ( $self->get_statelabels() ) {
        $self->add_states_to_charstates( $self->get_statelabels() );
        delete $self->get_otuset->{'statelabels'};
    }

    # The 'ntax' subcommand is not required unless the 'newtaxa' subcommand has
    # been used
    my $dimensions = $self->get_dimensions();
    if ( !$dimensions->{'newtaxa'} ) {
        delete $dimensions->{'ntax'};
        $self->set_dimensions($dimensions);
    }

    return;
}

=begin comment

 Title   : _parse_charstatelabels
 Usage   : $self->_parse_charstatelabels($buffer);
 Function: Parses the buffer containing character labels, stores it
 Returns : array of charstates
 Args    : buffer (string)
 Method  : parse a charstatelabels command in Characters Block and store in hash

=end comment 

=cut

sub _parse_charstatelabels {
    my ( $self, $labels ) = @_;
    my @charstates;
    my @charlabels;
    for my $line ( split /,/, $labels ) {
        my ( $label, $states ) = split /\s*\/\s*/, $line;
        $label =~ s/\s*(.*)/$1/;
        my ( $id, $charlabel ) = split /\s+/, $label;
        my @states = split /\s+/, $states if $states;
        push @charstates, $self->create_charstates( $id, $charlabel, \@states );
        push @charlabels, $charlabel;
    }
    $self->set_charlabels( \@charlabels );
    return \@charstates;
}

=begin comment

 Title   : _parse_charlabels
 Usage   : $self->_parse_charlabels($buffer);
 Function: Parses the buffer containing character labels, stores it
 Returns : array of charstates
 Args    : buffer (string)
 Method  : Gets rid of leading blanks in the buffer and removes the
           semicolon. Splits the buffer by whitespace into a list of
           character labels and assigns that to charlabels.

=end comment 

=cut

sub _parse_charlabels {
    my ( $self, $labels ) = @_;
    my $id = 0;
    my @charstates;
    my @charlabels = @{ _parse_nexus_words($labels) };
    for my $charlabel (@charlabels) {
        push @charstates, $self->create_charstates( ++$id, $charlabel );
    }
    $self->set_charlabels( \@charlabels );
    return \@charstates;
}

=begin comment

 Title   : _parse_statelabels
 Usage   : $self->_parse_statelabels($buffer);
 Function: Parses the buffer containing state labels, stores it
 Returns : array of states
 Args    : buffer (string)
 Method  : parse a statelabels command in Characters Block and store in hash

=end comment 

=cut

sub _parse_statelabels {
    my ( $self, $buffer ) = @_;
    my @states;
    my ( $charnum, @statenames );
    my @statetokens = @{ _parse_nexus_words($buffer) };
    for my $token (@statetokens) {
        if ( $token =~ /^\d+$/ && !$charnum > 0 ) { $charnum = $token; next; }
        elsif ( $token =~ /^,$/ ) {
            push @states,
                $self->create_charstates( $charnum, "", \@statenames );
            $charnum    = "";
            @statenames = ();
        }
        else {
            push @statenames, $token;
        }
    }
    $self->set_statelabels( \@states );
    return \@states;
}

=head2 add_states_to_charstates

 Title   : add_states_to_charstates
 Usage   : $self->add_states_to_charstates($states);
 Function: Adds states to the character states
 Returns : None
 Args    : states

=cut

sub add_states_to_charstates {
    my ( $self, $states ) = @_;
    my $newstates;
    my $charstates = $self->get_charstatelabels();
    if ( !@$charstates ) { $self->set_charstatelabels($states); return; }
STATE:
    for my $state (@$states) {
        for my $charstate (@$charstates) {
            if ( $state->{'id'} == $charstate->{'id'} ) {
                $charstate->{'states'} = $state->{'states'};
                next STATE;
            }
        }
        splice @$charstates, $state->{'id'} - 1, 1, $state;
    }
}

=head2 create_charstates

 Title   : create_charstates
 Usage   : my $char_state_hash = $self->create_charstates($id,$label,$states);
 Function: Converts the input id, label, states to an hash ref for processing.
 Returns : Has reference with (id, charlabel,states as keys)
 Args    : id, label, states

=cut

sub create_charstates {
    my ( $self, $id, $label, $states ) = @_;
    my %states;
    for ( my $i = 0; $i < @{ $states || [] }; $i++ ) {
        $states{$i} = $states->[$i];
    }
    return { id => $id, charlabel => $label, states => \%states };
}

=head2 find_taxon

 Title   : find_taxon
 Usage   : my $is_taxon_present = $self->find_taxon($taxon_name);
 Function: Finds whether the input taxon name is present in the taxon label.
 Returns : 0 (not present)  or 1 (if present).
 Args    : taxon label (as string)

=cut

sub find_taxon {
    my ( $self, $name ) = @_;
    if ( @{ $self->get_taxlabels || [] } == 0 ) { return 1; }
    for my $taxon ( @{ $self->get_taxlabels() } ) {
        if ( lc $taxon eq lc $name ) { return 1; }
    }
    return 0;
}

=head2 set_otuset

 Title   : set_otuset
 Usage   : $block->set_otuset($otuset);
 Function: Set the otus
 Returns : none
 Args    : TaxUnitSet object

=cut

sub set_otuset {
    my ( $self, $otuset ) = @_;
    $self->{'otuset'} = $otuset;
    $self->set_taxlabels( $otuset->get_otu_names() );
    return;
}

=head2 set_charstatelabels

 Title   : set_charstatelabels
 Usage   : $block->set_charstatelabels($labels);
 Function: Set the character names and states
 Returns : none
 Args    : array of character states

=cut

sub set_charstatelabels {
    my ( $self, $charstatelabels ) = @_;
    $self->get_otuset->set_charstatelabels($charstatelabels);
    return;
}

=head2 get_charstatelabels

 Title   : get_charstatelabels
 Usage   : $set->get_charstatelabels();
 Function: Returns an array of character states
 Returns : character states
 Args    : none

=cut

sub get_charstatelabels {
    my ($self) = @_;
    return $self->get_otuset->get_charstatelabels();
}

=head2 set_charlabels

 Title   : set_charlabels
 Usage   : $set->set_charlabels($labels);
 Function: Set the character names
 Returns : none
 Args    : array of character names 

=cut

sub set_charlabels {
    my ( $self, $labels ) = @_;
    $self->get_otuset()->set_charlabels($labels);
}

=head2 get_charlabels

 Title   : get_charlabels
 Usage   : $set->get_charlabels();
 Function: Returns an array of character labels
 Returns : character names
 Args    : none

=cut

sub get_charlabels {
    my ($self) = @_;
    return $self->get_otuset()->get_charlabels();
}

=head2 set_statelabels

 Title   : set_statelabels
 Usage   : $set->set_statelabels($labels);
 Function: Set the state names
 Returns : none
 Args    : array of state names 

=cut

sub set_statelabels {
    my ( $self, $labels ) = @_;
    $self->get_otuset()->set_statelabels($labels);
}

=head2 get_statelabels

 Title   : get_statelabels
 Usage   : $set->get_statelabels();
 Function: Returns an array of stateacter labels
 Returns : stateacter names
 Args    : none

=cut

sub get_statelabels {
    my ($self) = @_;
    return $self->get_otuset()->get_statelabels();
}

=head2 get_nchar

 Title   : get_nchar
 Usage   : $block->get_nchar();
 Function: Returns the number of characters of the block
 Returns : # charaters
 Args    : none

=cut

sub get_nchar {
    my $self   = shift;
    my $nchar  = $self->get_dimensions('nchar');
    my $otuset = $self->get_otuset();
    $nchar ||= $otuset ? $otuset->get_nchar() : undef;
    return $nchar;
}

=begin comment

 Title   : _parse_matrix
 Usage   : $self->_parse_matrix($buffer); (private)
 Function: Processes buffer containing matrix data
 Returns : arrayref
 Args    : buffer (string)
 Method  : parse according to if name is quoted string or single word, 
           if each state is single character or multi-character (use token keyword)

=end comment 

=cut

sub _parse_matrix {
    my ( $self, $matrix, $verbose ) = @_;
    my $nchar     = $self->get_nchar();
    my @taxlabels = @{ $self->get_taxlabels() };

    my %format = %{ $self->get_format() };

    my $expect_labels     = !$format{'nolabels'};
    my $expect_interleave = $format{'interleave'};
    my $expect_tokens     = $format{'tokens'}
        || ( lc $format{'datatype'} eq 'continuous' );

    my $missing_symbol = $format{'missing'} || q{};
    my $gap_symbol     = $format{'gap'}     || q{};

    if ( $format{'datatype'} =~ /^/ ) { }

    # '+' and '-' are not included as punctuation because they are allowed as
    # state symbols in a matrix
    my $punctuation_regex = qr/[\/\\,;:=*"`<>]/;

    my ( @lines, %taxa );

    if ($expect_interleave) {
        @lines = split /\n+/, $matrix;
    }
    else {

        # This is a funny hoop we have to jump through to avoid major code
        # duplication
        @lines = ($matrix);
    }

    for my $line (@lines) {
        my @words       = @{ _parse_nexus_words($line) };
        my $name        = q{};
        my $in_grouping = 0;
        my $i           = 0;

    WORD:
        for my $word (@words) {

            # If it's not an interleaved matrix and we've already parsed all
            # the states for this taxon (nchar = number parsed), then move onto
            # the next taxon
            if (   !$expect_interleave
                && !$in_grouping
                && $taxa{$name}
                && scalar @{ $taxa{$name} } == $nchar )
            {
                $name = q{};
            }

            # If $name is empty, we're looking at the beginning of a new row
            if ( $name eq q{} ) {
                if ($expect_labels) {
                    $name = $word;
                    $taxa{$name} = [];
                    next WORD;
                }
                else {
                    $name = $taxlabels[ $i++ ];    # (if 'NoLabels')
                    $taxa{$name} = [];

                  # In case we're dealing with an interleaved, unlabeled matrix,
                  # reset $i if we've passed the end of the @taxlabels array
                    $i = $i > $#taxlabels ? 0 : $i;
                }
            }

            if (   $word ne $missing_symbol
                && $word ne $gap_symbol
                && $word =~ $punctuation_regex )
            {
                next WORD;
            }
            elsif ( $word eq '(' ) {
                push @{ $taxa{$name} },
                    { 'type' => 'polymorphism', 'states' => [] };
                $in_grouping = 1;
            }
            elsif ( $word eq '{' ) {
                push @{ $taxa{$name} },
                    { 'type' => 'uncertainty', 'states' => [] };
                $in_grouping = 1;
            }
            elsif ( $word eq ')' || $word eq '}' ) {
                $in_grouping = 0;
            }
            else {
                my ( $right_arrayref, @right_seq );
                $right_arrayref =
                    $in_grouping ? $taxa{$name}->[-1]{'states'} : $taxa{$name};
                @right_seq = $expect_tokens ? ($word) : split //, $word;
                push @$right_arrayref, @right_seq;
            }
        }
    }

    my $title = $self->get_title();
    $title = ": $title " if $title;
    my (@otus);

    while ( my ( $name, $seq ) = each %taxa ) {
        unless ( $self->find_taxon($name) ) {
            croak "Characters$title block error...\n",
                "Unknown taxon '$name\' encountered in matrix.  ",
                "Common causes include: Misspelled names, ",
                "sequence lengths that don't match the specified number of characters (nchar), ",
                "including a taxon that is not listed in the Taxa Block, ",
                "and not quoting names with whitespace or punctuation: ";
        }
        push @otus, Bio::NEXUS::TaxUnit->new( $name, $seq );

    }

    my $otuset = $self->get_otuset();
    $otuset->set_otus( \@otus );
    $self->set_taxlabels( $otuset->get_otu_names() );

    return \@otus;
}

=head2 select_columns

 Title   : select_columns
 Usage   : $block->select_columns($columns);
 Function: select a subset of characters
 Returns : new $self with subset of columns of characters
 Args    : column numbers

=cut

sub select_columns {
    my ( $self, $columns ) = @_;
    $self->get_otuset()->select_columns($columns);
    return $self;
}

=head2 rename_otus

 Title   : rename_otus
 Usage   : $block->rename_otus(\%translation);
 Function: Renames all the OTUs to something else
 Returns : none
 Args    : hash containing translation

=cut

sub rename_otus {
    my ( $self, $translation ) = @_;
    $self->get_otuset()->rename_otus($translation);
}

=head2 equals

 Name    : equals
 Usage   : $block->equals($another);
 Function: compare if two Bio::NEXUS::CharactersBlock objects are equal
 Returns : boolean 
 Args    : a Bio::NEXUS::CharactersBlock object

=cut

sub equals {
    my ( $self, $block ) = @_;
    if ( !Bio::NEXUS::Block::equals( $self, $block ) ) { return 0; }
    return $self->get_otuset()->equals( $block->get_otuset() );
}

=begin comment

 Name    : _write
 Usage   : $block->_write();
 Function: Writes NEXUS block containing character data
 Returns : none
 Args    : file handle

=end comment 

=cut

sub _write {
    my ( $self, $fh, $verbose ) = @_;
    $fh ||= \*STDOUT;

    Bio::NEXUS::Block::_write( $self, $fh );
    $self->_write_dimensions( $fh, $verbose );
    $self->_write_format( $fh, $verbose );
    $self->_write_labels( $fh, $verbose );
    $self->_write_matrix( $fh, $verbose );
    print $fh "END;\n";
}

=begin comment

 Name    : _write_labels
 Usage   : $self->_write_labels($file_handle,$verbose);
 Function: Writes Character labels and Character-State labels to the filehandle 
 Returns : none
 Args    : $file_handle and $verbose 

=end comment 

=cut

sub _write_labels {
    my ( $self, $fh, $verbose ) = @_;
    $fh ||= \*STDOUT;

    my @charstates = @{ $self->get_charstatelabels() };
    if ( keys %{ $charstates[0]->{'states'} } ) {
        print $fh "\tCHARSTATELABELS\n";
        for my $label (@charstates) {
            my ( $id, $charlabel ) =
                ( $label->{'id'}, $label->{'charlabel'} || '' );
            $charlabel = _nexus_formatted($charlabel);
            print $fh "\t$id $charlabel / ";
            for my $key ( sort keys %{ $label->{'states'} } ) {
                my $state = $label->{'states'}{$key};
                $state = _nexus_formatted($state);
                print $fh "$state ";
            }
            print $fh ",\n";
        }
        print $fh "\t;\n";
    }
    elsif ( @{ $self->get_charlabels } > 0 ) {
        print $fh "\tCHARLABELS\n\t";
        for my $charlabel ( @{ $self->get_charlabels } ) {
            $charlabel = _nexus_formatted($charlabel);
            print $fh " $charlabel";
        }
        print $fh ";\n";
    }
}

=begin comment

 Name    : _write_matrix
 Usage   : $self->_write_matrix($file_handle,$verbose);
 Function: Writes CharactersBlock matrix( The data stored in the matrix command)  into the filehandle 
 Returns : none
 Args    : $file_handle and $verbose 

=end comment 

=cut

sub _write_matrix {
    my ( $self, $fh, $verbose ) = @_;
    $fh ||= \*STDOUT;

    my @otus = @{ $self->get_otuset()->get_otus() };
    print $fh "\tMATRIX\n";
    for my $otu (@otus) {
        my $otu_name = _nexus_formatted( $otu->get_name() );
        my $seq      = $otu->get_seq_string( $self->{'format'}->{'tokens'} );
        print $fh "\t", $otu_name, "\t", $seq, "\n";
    }
    print $fh "\t;\n";

}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::CharactersBlock::';

    # The following methods are deprecated and are temporarily supported
    # via a warning and a redirection
    my %synonym_for = (
        "${package_name}set_charstates" => "${package_name}set_charstatelabels",
        "${package_name}get_charstates" => "${package_name}get_charstatelabels",
    );

    if ( defined $synonym_for{$AUTOLOAD} ) {
        carp "$AUTOLOAD() is deprecated; use $synonym_for{$AUTOLOAD}() instead";
        goto &{ $synonym_for{$AUTOLOAD} };
    }
    else {
        croak "ERROR: Unknown method $AUTOLOAD called";
    }
    return;
}

1;
