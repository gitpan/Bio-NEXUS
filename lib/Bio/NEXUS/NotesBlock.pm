#################################################################
# NotesBlock.pm
#################################################################
# Author: Thomas Hladish
# $Id: NotesBlock.pm,v 1.8 2006/08/26 05:54:34 vivek Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::NotesBlock 

=head1 SYNOPSIS

=head1 DESCRIPTION

Placeholding module for the Notes Block class.

=head1 COMMENTS

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.8 $

=head1 METHODS

=cut

package Bio::NEXUS::NotesBlock;

use strict;
use Data::Dumper;
use Carp;
use Bio::NEXUS::Functions;
use Bio::NEXUS::Block;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::Block);

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::NotesBlock::';

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
