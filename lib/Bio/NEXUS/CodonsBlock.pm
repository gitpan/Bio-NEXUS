#################################################################
# CodonsBlock.pm
#################################################################
# Author: Thomas Hladish
# $Id: CodonsBlock.pm,v 1.10 2006/09/11 23:15:35 thladish Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::CodonsBlock - Represents CODONS block in NEXUS file

=head1 SYNOPSIS

=head1 DESCRIPTION

Placeholding module for the CODONS block class.

=head1 COMMENTS

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.10 $

=head1 METHODS

=cut

package Bio::NEXUS::CodonsBlock;

use strict;
use Data::Dumper;
use Carp;
use Bio::NEXUS::Functions;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::Block);

=head2 new

 Title   : new
 Usage   : block_object = new Bio::NEXUS::CodonsBlock();
 Function: Creates a new Bio::NEXUS::CodonsBlock object 
 Returns : Bio::NEXUS::CodonsBlock object
 Args    : 

=cut

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::CodonBlock::';

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
