######################################################
# AssumptionsBlock.pm
######################################################
# Author: Chengzhi Liang, Weigang Qiu, Eugene Melamud, Peter Yang, Thomas Hladish
# $Id: AssumptionsBlock.pm,v 1.34 2006/09/01 19:24:02 thladish Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::AssumptionsBlock - parses and reads in the assumptions block of a NEXUS file

=head1 SYNOPSIS

 if ( $type =~ /assumptions/i ) {
     $block_object = new Bio::NEXUS::AssumptionsBlock($block_type, $block, $verbose);
 }

=head1 DESCRIPTION

If a NEXUS block is an assumptions block, this module parses the block and stores the assumptions data. Currently this only works with SOAP weight data, but we hope to extend its functionality.

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Chengzhi Liang (liangc@umbi.umd.edu)
 Weigang Qiu (weigang@genectr.hunter.cuny.edu)
 Eugene Melamud (melamud@carb.nist.gov)
 Peter Yang (pyang@rice.edu)
 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.34 $

=head1 METHODS

=cut

package Bio::NEXUS::AssumptionsBlock;

use strict;
use Carp;
use Data::Dumper;
use Bio::NEXUS::Functions;
use Bio::NEXUS::Block;
use Bio::NEXUS::WeightSet;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::Block);

=head2 new

 Title   : new
 Usage   : block_object = new Bio::NEXUS::AssumptionsBlock($block_type, $commands, $verbose );
 Function: Creates a new Bio::NEXUS::AssumptionsBlock object 
 Returns : Bio::NEXUS::AssumptionsBlock object
 Args    : type (string), the commands/comments to parse (array ref), and a verbose flag (0 or 1; optional)

=cut

sub new {
    my ( $class, $type, $commands, $verbose ) = @_;
    unless ($type) { ($type = lc $class) =~ s/Bio::NEXUS::(.+)Block/$1/i; }
    my $self = { 'type' => $type, 'assumptions' => [] };
    bless $self, $class;
    $self->_parse_block( $commands, $verbose ) if ((defined $commands) and @$commands);
    return $self;
}

=begin comment

 Title   : _parse_wtset
 Usage   : $self->_parse_wtset($buffer); (private)
 Function: Processes the buffer containing weights data
 Returns : name and array of weights
 Args    : the buffer to parse (string)
 Method  : Creates a Bio::NEXUS::WeightSet object and sets the name and list of weight values.
           Adds the newly created WeightSet object to the set of assumptions
           this block contains.

=end comment 

=cut

sub _parse_wtset {
    my ( $self, $buffer ) = @_;
    my ( $name, $weights ) = split /=/, $buffer;
    $name =~ s/(\(.*\))//;
    my $flags = $1;
    my ( $type, $tokens );
    $type   = ( $flags =~ /vector/i )   ? 'VECTOR' : 'STANDARD';
    $tokens = ( $flags =~ /notokens/i ) ? 0        : 1;
    $name    =~ s/^\s*(\S+)\s*$/$1/;
    $weights =~ s/^\s*(\S+.*\S+)\s*$/$1/s;
    my @weights      = split //, $weights;
    my $is_weightset = 1;

    my $new_weightset =
        Bio::NEXUS::WeightSet->new( $name, \@weights, $is_weightset, $tokens,
        $type );
    $self->add_weightset($new_weightset);
    return ( $name, \@weights, $is_weightset, $tokens, $type );
}

=head2 add_weightset

 Title   : add_weightset
 Usage   : $block->add_weightset(weightset);
 Function: add a weightset to this assumption block
 Returns : none
 Args    : WeightSet object

=cut

sub add_weightset {
    my ( $self, $weight ) = @_;
    push @{ $self->{'assumptions'} }, $weight;
}

=head2 get_assumptions

 Title   : get_assumptions
 Usage   : $block->get_assumptions();
 Function: Gets the list of assumptions (Bio::NEXUS::WeightSet objects) and returns it
 Returns : ref to array of Bio::NEXUS::WeightSet objects
 Args    : none

=cut

sub get_assumptions {
    my ($self) = @_;
    return $self->{'assumptions'} || [];
}

=head2 select_assumptions

 Title   : select_assumptions
 Usage   : $block->select_assumptions($columns);
 Function: select assumptions (Bio::NEXUS::WeightSet objects) for a set of characters (columns)
 Returns : none
 Args    : column numbers for the set of characters to be selected

=cut

sub select_assumptions {
    my ( $self, $columns ) = @_;
    if ( !$self->get_assumptions() ) { return; }
    my @assump = @{ $self->get_assumptions() };
    for my $assump (@assump) {
        $assump->select_weights($columns);
    }
}

=head2 equals

 Name    : equals
 Usage   : $assump->equals($another);
 Function: compare if two Bio::NEXUS::AssumptionsBlock objects are equal
 Returns : boolean 
 Args    : a Bio::NEXUS::AssumptionsBlock object

=cut

sub equals {
    my ( $self, $block ) = @_;
    if ( !Bio::NEXUS::Block::equals( $self, $block ) ) { return 0; }

    #    if ($self->get_type() ne $block->get_type()) {return 0;}

    my @weightset1 = @{ $self->get_assumptions() };
    my @weightset2 = @{ $block->get_assumptions() };

    if ( @weightset1 != @weightset2 ) { return 0; }

    @weightset1 = sort { $a->get_name() cmp $b->get_name() } @weightset1;
    @weightset2 = sort { $a->get_name() cmp $b->get_name() } @weightset2;

    for ( my $i = 0; $i < @weightset1; $i++ ) {
        if ( !$weightset1[$i]->equals( $weightset2[$i] ) ) { return 0; }
    }

    return 1;
}

=begin comment

 Name    : _write
 Usage   : $assump->_write($filehandle, $verbose);
 Function: Writes NEXUS block from stored data
 Returns : none
 Args    : none

=end comment 

=cut

sub _write {
    my ( $self, $fh, $verbose ) = @_;
    $fh ||= \*STDOUT;

    Bio::NEXUS::Block::_write( $self, $fh );
    for my $assumption ( @{ $self->get_assumptions() } ) {
        if ( $assumption->is_wt() ) {
            my @wt        = @{ $assumption->get_weights() };
            my $delimiter = ' ';
            my $format = '(STANDARD TOKENS)';    ## This is the NEXUS default
            if ( !$assumption->_is_tokens() ) {
                $delimiter = '';
                $format =~ s/TOKENS/NOTOKENS/;
            }
            if ( $assumption->_is_vector() ) {
                $format =~ s/STANDARD/VECTOR/;
            }
            my @wtstring = join $delimiter, @wt;
            print $fh "\tWTSET ", $assumption->get_name(), " $format = \n\t";
            print $fh @wtstring, ";\n";
        }
    }
    for my $comm ( @{ $self->{'unknown'} || [] } ) {
        print $fh "\t$comm;\n";
    }
    print $fh "END;\n";
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::AssumptionsBlock::';

    # The following methods are deprecated and are temporarily supported
    # via a warning and a redirection
    my %synonym_for =
        ( "${package_name}parse_weightset" => "${package_name}_parse_wtset", );

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
