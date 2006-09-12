#################################################################
# DataBlock.pm
#################################################################
# Author: Thomas Hladish
# $Id: DataBlock.pm,v 1.10 2006/09/05 16:48:17 vivek Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::DataBlock - Represents the deprecated DATA Block in NEXUS file. 

=head1 SYNOPSIS

$block_object = new Bio::NEXUS::DataBlock($type, $block, $verbose, $taxlabels_ref);

=head1 DESCRIPTION

The DataBlock class represents the deprecated Data Block in a NEXUS file.  Data Blocks are still used by some prominent programs, unfortunately, although they are essentially the same as a Characters Block and a Taxa Block combined.  Data Blocks may be used as input, but are not output by the NEXPL library.  For more information on Data Blocks, see the Characters Block documentation.

=head1 COMMENTS

Don't use this block type if you can help it.

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.10 $

=head1 METHODS

=cut

package Bio::NEXUS::DataBlock;

use strict;
use Data::Dumper;
use Carp;
use Bio::NEXUS::Functions;
use Bio::NEXUS::CharactersBlock;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::CharactersBlock);

=head2 new

 Title   : new
 Usage   : block_object = new Bio::NEXUS::CharactersBlock($block_type, $block, $verbose, $taxa);
 Function: Creates a new Bio::NEXUS::CharactersBlock object
 Returns : Bio::NEXUS::CharactersBlock object
 Args    : verbose flag (0 or 1), type (string) and the block to parse (string)

=cut

sub new {
    my $deprecated_class = shift;
    my $deprecated_type  = shift;
    print
        "    Read in Data Block (deprecated), creating Characters Block instead . . .\n";
    my $self = new Bio::NEXUS::CharactersBlock( 'characters', @_ );
    return $self;
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::DataBlock::';

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
