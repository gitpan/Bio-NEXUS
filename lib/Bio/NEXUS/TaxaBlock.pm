######################################################
# TaxaBlock.pm
######################################################
# Author: Chengzhi Liang,  Weigang Qiu, Eugene Melamud, Peter Yang, Thomas Hladish
# $Id: TaxaBlock.pm,v 1.36 2006/09/01 19:24:02 thladish Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::TaxaBlock - parses and reads in the taxa block of a NEXUS file

=head1 SYNOPSIS

 if ( $type =~ /taxa/i ) {
     $block_object = new Bio::NEXUS::TaxaBlock($type, $block, $verbose);
 }

=head1 DESCRIPTION

If a NEXUS block is a taxa block, this module parses the block and stores the taxonomic data.

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Chengzhi Liang (liangc@umbi.umd.edu)
 Weigang Qiu (weigang@genectr.hunter.cuny.edu)
 Eugene Melamud (melamud@carb.nist.gov)
 Peter Yang (pyang@rice.edu)
 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.36 $

=head1 METHODS

=cut

package Bio::NEXUS::TaxaBlock;

use strict;
use Carp;
use Data::Dumper;
use Bio::NEXUS::Functions;
use Bio::NEXUS::Node;
use Bio::NEXUS::Block;
use Bio::NEXUS::TaxUnit;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::Block);

=head2 new

 Title   : new
 Usage   : block_object = new Bio::NEXUS::TaxaBlock($block_type, $commands, $verbose);
 Function: Creates a new Bio::NEXUS::TaxaBlock object 
 Returns : Bio::NEXUS::TaxaBlock object
 Args    : type (string), the commands/comments to parse (array ref), and a verbose flag (0 or 1; optional)

=cut

sub new {
    my ( $class, $type, $commands, $verbose ) = @_;
    unless ($type) { ($type = lc $class) =~ s/Bio::NEXUS::(.+)Block/$1/i; }
    my $self = { type => $type, };
    bless $self, $class;
    $self->_parse_block( $commands, $verbose ) if ((defined $commands) and @$commands);
    return $self;
}

=head2 is_taxon

 Title   : is_taxon
 Usage   : $block->is_taxon($query_taxonlabel);
 Function: Validates OTU names/taxlabels
 Returns : Returns taxlabel if true, undef if false
 Args    : Query taxon label

=cut

sub is_taxon {
    my ( $self, $query_taxon, $verbose ) = @_;
    my $taxlabels = $self->get_taxlabels();
    for my $taxlabel (@$taxlabels) {
        if ( $taxlabel eq $query_taxon ) { return $taxlabel }
    }
    if ( $verbose == 1 ) { print "$query_taxon is not a valid OTU name\n"; }
    return undef;
}

=head2 get_ntax

 Title   : get_ntax
 Usage   : $block->get_ntax();
 Function: Returns the dimensions (that is, ntax) of the block
 Returns : dimensions (integer)
 Args    : none

=cut

sub get_ntax {
    my ($self) = @_;
    return scalar @{ $self->get_taxlabels() };
}

=head2 rename_otus

 Title   : rename_otus
 Usage   : $block->rename_otus(\%translation);
 Function: Renames all the OTUs to something else
 Returns : none
 Args    : hash containing translation

=cut

sub rename_otus {
    my ( $self, $translate ) = @_;
    my $taxlabels = $self->get_taxlabels();
    my $newtaxlabels;
    for my $taxlabel (@$taxlabels) {
        $taxlabel = $$translate{$taxlabel} if $$translate{$taxlabel};
        push( @$newtaxlabels, $taxlabel );
    }
    $self->set_taxlabels($newtaxlabels);
}

=head2 equals

 Name    : equals
 Usage   : $taxa->equals($another);
 Function: compare if two Bio::NEXUS::TaxaBlock objects are equal
 Returns : boolean 
 Args    : a Bio::NEXUS::TaxaBlock object

=cut

sub equals {
    my ( $self, $block ) = @_;
    if ( !Bio::NEXUS::Block::equals( $self, $block ) ) { return 0; }

    #    if ($self->get_type() ne $block->get_type()) {return 0;}
    my @labels1 = @{ $self->get_taxlabels() };
    my @labels2 = @{ $block->get_taxlabels() };
    if ( @labels1 != @labels2 ) { return 0; }
    @labels1 = sort { $a cmp $b } @labels1;
    @labels2 = sort { $a cmp $b } @labels2;
    for ( my $i = 0; $i < @labels1; $i++ ) {
        if ( $labels1[$i] ne $labels2[$i] ) { return 0; }
    }
    return 1;
}

=begin comment

 Name    : _write
 Usage   : $taxa->_write($filehandle, $verbose);
 Function: Writes NEXUS block from stored data
 Returns : none
 Args    : none

=end comment

=cut

sub _write {
    my ( $self, $fh, $verbose ) = @_;
    $fh ||= \*STDOUT;

    my $ntax = $self->get_ntax();
    Bio::NEXUS::Block::_write( $self, $fh );
    print $fh "\tDIMENSIONS ntax=$ntax;\n";
    print $fh "\tTAXLABELS ";
    for my $OTU ( @{ $self->get_taxlabels() } ) {
        $OTU = _nexus_formatted($OTU);
        print $fh " $OTU";
    }
    print $fh ";\nEND;\n";
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::TaxaBlock::';

    # The following methods are deprecated and are temporarily supported
    # via a warning and a redirection
    my %synonym_for =
        ( "${package_name}parse_labels" => "${package_name}_parse_taxlabels", );

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
