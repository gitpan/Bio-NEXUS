#######################################################################
# HistoryBlock.pm
#######################################################################
# Author: Chengzhi Liang, Justin Reese, Thomas Hladish
# $Id: HistoryBlock.pm,v 1.22 2006/09/01 19:24:02 thladish Exp $

#################### START POD DOCUMENTATION ##########################

=head1 NAME

Bio::NEXUS::HistoryBlock - represents a history block of a NEXUS file

=head1 SYNOPSIS

$block_object = new Bio::NEXUS::HistoryBlock('history', $block, $verbose);

=head1 DESCRIPTION

This is a class representing a history block in NEXUS file

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Chengzhi Liang (liangc@umbi.umd.edu)
 Justin Reese
 Tom Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.22 $

=head1 METHODS

=cut

package Bio::NEXUS::HistoryBlock;

use strict;
use Data::Dumper;
use Carp;
use Bio::NEXUS::Functions;
use Bio::NEXUS::TaxUnitSet;
use Bio::NEXUS::Block;
use Bio::NEXUS::Node;
use Bio::NEXUS::Tree;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::CharactersBlock Bio::NEXUS::TreesBlock);

=head2 new

 Title   : new
 Usage   : block_object = new Bio::NEXUS::HistoryBlock($block_type, $commands, $verbose);
 Function: Creates a new Bio::NEXUS::HistoryBlock object
 Returns : Bio::NEXUS::HistoryBlock object
 Args    : type (string), the commands/comments to parse (array ref), and a verbose flag (0 or 1; optional)
 Comments: 

=cut

sub new {
    my ( $class, $type, $commands, $verbose ) = @_;
    unless ($type) { ($type = lc $class) =~ s/Bio::NEXUS::(.+)Block/$1/i; }
    my $self = { type => $type };
    bless $self, $class;
    $self->{'otuset'} = new Bio::NEXUS::TaxUnitSet();
    $self->_parse_block( $commands, $verbose ) if ((defined $commands) and @$commands);
    return $self;
}

=begin comment

 Name    :_parse_nodelabels
 Usage   : $block->nodelabels($label_text);
 Function: Parse node labels like taxlabels in taxa block
 Returns : Labels as the array reference
 Args    : $labels_text as string

=end comment 

=cut

sub _parse_nodelabels {
    my ( $self, $labeltext ) = @_;
    my @labels = split( /\s+/, $labeltext );
    return \@labels;
}

=head2 equals

 Name    : equals
 Usage   : $block->equals($another);
 Function: compare if two Block objects are equal
 Returns : boolean 
 Args    : a Block object

=cut

sub equals {
    my ( $self, $block ) = @_;
    if ( !Bio::NEXUS::Block::equals( $self, $block ) ) {
        carp "First equals failed\n";
        return 0;
    }
    my $historytree1 = $self->get_tree();
    my $historytree2 = $block->get_tree();
    if ( !$historytree1->equals($historytree2) ) {
        carp "Trees do not appear to be the same, failing equals\n";
        return 0;
    }

    # check otus

    if ( !$self->get_otuset()->equals( $block->get_otuset() ) ) {
        carp "otusets do not appear to be the same, failing equals\n";
        return 0;
    }

    return 1;
}

=head2 rename_otus

 Name    : rename_otus
 Usage   : $nexus->rename_otus(\%translation);
 Function: rename all OTUs 
 Returns : a new nexus object with new OTU names
 Args    : a ref to hash based on OTU name pairs

=cut

sub rename_otus {
    my ( $self, $translation ) = @_;
    for my $parent (@ISA) {
        if ( my $coderef = $self->can( $parent . "::rename_otus" ) ) {
            $self->$coderef($translation);
        }
    }
}

=begin comment

 Name    : _write
 Usage   : $block->_write();
 Function: Writes NEXUS block containing history data
 Returns : none
 Args    : file name (string)

=end comment

=cut

sub _write {
    my ( $self, $fh, $verbose ) = @_;
    $fh ||= \*STDOUT;

    Bio::NEXUS::Block::_write( $self, $fh );
    $self->_write_dimensions( $fh, $verbose );
    $self->_write_format( $fh, $verbose );
    $self->_write_labels( $fh, $verbose );
    print $fh "\tNODELABELS ";
    for my $label ( @{ $self->get_otuset->get_otu_names } ) {
        print $fh _nexus_formatted($label) . ' ';
    }
    print $fh ";\n";
    $self->_write_matrix( $fh, $verbose );
    $self->_write_trees( $fh, $verbose );
    print $fh "END;\n";
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::HistoryBlock::';

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
