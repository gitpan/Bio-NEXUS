#################################################################
# MatrixBlock.pm
#################################################################
# Author: Thomas Hladish
# $Id: MatrixBlock.pm,v 1.12 2006/09/11 23:12:42 thladish Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::MatrixBlock - Provides functions for handling blocks that have matrices

=head1 SYNOPSIS

This module is the super class of Characters, Unaligned, and Distances block classes, and indirectly it is a super-class of Data and History blocks, which are both sub-classes of Characters blocks. These sub-classes inherint the methods within this module.  There is no constructor, as a MatrixBlock should not exist that is not also one of the sub-class block types.

=head1 DESCRIPTION

Provides functions used for handling blocks that have matrices.

=head1 COMMENTS

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.12 $

=head1 METHODS

=cut

package Bio::NEXUS::MatrixBlock;

use strict;
use Data::Dumper;
use Carp;
use Bio::NEXUS::Functions;
use Bio::NEXUS::Block;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::Block);

=head2 get_ntax

 Title   : get_ntax
 Usage   : $block->get_ntax();
 Function: Returns the number of taxa in the block
 Returns : # taxa
 Args    : none

=cut

sub get_ntax {
    my $self = shift;

    if ( my $otuset = $self->get_otuset() ) {
        return $otuset->get_ntax();
    }
    elsif ( my $dimensions = $self->get_dimensions() ) {
        return $dimensions->{'ntax'};
    }
    else {
        return;
    }
}

=head2 get_nchar

 Title   : get_nchar
 Usage   : $block->get_nchar();
 Function: Returns the number of characters in the block (Note: In Distances Blocks, this is the number of characters used to infer distances.)
 Returns : # taxa
 Args    : none

=cut

sub get_nchar {
    my $self = shift;

    if ( my $dimensions = $self->get_dimensions() ) {
        return $dimensions->{'nchar'};
    }
    else {
        return;
    }
}

=begin comment

 Title   : _parse_format
 Usage   : $format = $self->_parse_format($buffer); (private)
 Function: Extracts format values from line and stores in format attribute
 Returns : none
 Args    : buffer (string)
 Methods : Separates formats by whitespace and creates hash containing
           key = format name and value = format value.

=end comment 

=cut

sub _parse_format {
    my ( $self, $string ) = @_;

    my %format = ();

    my @format_tokens = @{ _parse_nexus_words($string) };
    while (@format_tokens) {

# If the second thing in the list is a '=' (e.g. ('datatype', '=', 'standard') )
        if ( $format_tokens[1] && $format_tokens[1] eq '=' ) {

            #then set the first thing equal to the third
            my ( $key, $equals, $val ) = splice( @format_tokens, 0, 3 );
            $format{ lc $key } = $val;
        }
        else {
            my $key = shift @format_tokens;

            # Otherwise, just set the first thing equal to TRUE
            $format{ lc $key } = 1;
        }
    }

    # Note: Treating flags and things with rvalues the same way is problematic--
    # how do you know whether a given format token has a count of 1, or if it
    # was merely present, and that's why it has a value of one.  One possible
    # way to make this more robust is to store flags in $format{'flags'},
    # e.g. $format{'flags'} = ['tokens', 'respectcase'];

    $self->set_format( \%format );
    return;
}

=begin comment

 Title   : _validate_format
 Usage   : $self->_validate_format($format_hashref); (private)
 Function: Assigns defaults and sorts through formatting subcommands per the NEXUS standard
 Returns : hash reference (the validated formatting)
 Args    : hash reference with format keys (the subcommands) and their values

=end comment 

=cut

sub _validate_format {
    my ( $self, $format ) = @_;
    my $block_type = $self->get_type();

    # Currently, only Characters and Unaligned blocks are handled here--other
    # matrix-type blocks are treated as though their formatting is valid
    return $format
        unless ( $block_type eq 'characters' || $block_type eq 'unaligned' );

    if ($format->{'datatype'} =~ /^(?:dna|rna|nucleotide|protein|continuous)$/ )
    {
        delete $format->{'respectcase'};
    }
    elsif ( $format->{'datatype'} eq 'standard'
        || !defined $format->{'datatype'} )
    {
        $format->{'datatype'} = 'standard'; # 'standard' is the default datatype

        if ( !$format->{'respectcase'} ) {
            for my $sub_cmd (qw/symbols missing gap matchar/) {
                $format->{$sub_cmd} = lc $format->{$sub_cmd}
                    if defined $format->{$sub_cmd};
            }
        }
    }
    else {
        carp
            "WARNING: Unfamiliar datatype encountered in $block_type block: '$format->{'datatype'}' (continuing anyway) ";
    }

    return $format;
}

=head2 set_format

 Title   : set_format
 Usage   : $block->set_format(\%format);
 Function: set the format of the characters
 Returns : none
 Args    : hash of format values

=cut

sub set_format {
    my ( $self, $format_hashref ) = @_;
    $self->{'format'} = $self->_validate_format($format_hashref);
}

=head2 get_format

 Title   : get_format
 Usage   : $block->get_format($attribute);
 Function: Returns the format of the characters
 Returns : hash of format values, or if $attribute (a string) is supplied, the value of that attribute in the hash
 Args    : none

=cut

sub get_format {
    my ( $self, $attribute ) = @_;
    $attribute
        ? return $self->{'format'}->{$attribute}
        : return $self->{'format'} || {};
}

=head2 add_taxlabels

 Title   : add_taxlabels
 Usage   : $block->add_taxlabels($new_taxlabels);
 Function: Adds new taxa to taxlabels if they aren't already there
 Returns : none
 Args    : taxa to be added

=cut

sub add_taxlabels {
    my ( $self, $new_taxlabels ) = @_;
    my $current_taxlabels = $self->get_taxlabels();

    for my $new_label (@$new_taxlabels) {

        # Check to see if new_label is already in current_taxlabels
        if ( !defined first {/$new_label/} @$current_taxlabels ) {
            push @$current_taxlabels, $new_label;
        }
    }
    return;
}

=begin comment

 Title   : _write_dimensions
 Usage   : $block->_write_dimensions();
 Function: writes out the dimensions command
 Returns : none
 Args    : filehandle to write to, a verbose flag

=end comment 

=cut

sub _write_dimensions {
    my ( $self, $fh, $verbose ) = @_;
    $fh ||= \*STDOUT;

    my $ntax  = $self->get_ntax();
    my $nchar = $self->get_nchar();

    return if !defined $ntax && !defined $nchar;

    my $ntax_text  = $ntax  ? " ntax=$ntax"   : q{};
    my $nchar_text = $nchar ? " nchar=$nchar" : q{};

    croak "Characters blocks require that Dimensions:nchar be defined\n"
        if $self->get_type() eq 'characters' && !$nchar;

    print $fh "\tDIMENSIONS$ntax_text$nchar_text;\n";
    return;
}

=begin comment

 Title   : _write_format
 Usage   : $block->_write_format();
 Function: writes out the format command
 Returns : none
 Args    : filehandle to write to, a verbose flag

=end comment 

=cut

sub _write_format {
    my ( $self, $fh, $verbose ) = @_;
    $fh ||= \*STDOUT;

    my %format_of = %{ $self->get_format() };
    if ( scalar keys %format_of ) {
        print $fh "\tFORMAT";

        print $fh " datatype=$format_of{'datatype'}"
            if defined $format_of{'datatype'};
        print $fh ' respectcase' if $format_of{'respectcase'};

        while ( my ( $key, $val ) = each %format_of ) {
            if ( !$val || ( $key =~ /(?:datatype|respectcase)/i ) ) { next; }
            elsif ( $val eq '1' ) {
                print $fh " $key";
            }
            else {
                print $fh " $key=$val";
            }
        }
        print $fh ";\n";
    }
    return;
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::MatrixBlock::';

    # The following methods are deprecated and are temporarily supported
    # via a warning and a redirection
    my %synonym_for = (

#        "${package_name}parse"      => "${package_name}_parse_tree",  # example
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
