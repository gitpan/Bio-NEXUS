######################################################
# UnknownBlock.pm
######################################################
# Author: Peter Yang, Thomas Hladish
# $Id: UnknownBlock.pm,v 1.20 2006/09/11 23:15:35 thladish Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::UnknownBlock - Represents a simple  object for storing information unrecognized blocks by the Bio::NEXUS module.

=head1 SYNOPSIS

$block_object = new Bio::NEXUS::UnknownBlock($block_type, $block, $verbose);

=head1 DESCRIPTION

Provides a simple way of storing information about a block that is not currently recognized by the NEXUS package. This is useful for remembering custom blocks.

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are all greatly appreciated. There are no mailing lists at this time for the Bio::NEXUS::TaxaBlock module, so send all relevant contributions to Dr. Weigang Qiu (weigang@genectr.hunter.cuny.edu).

=head1 AUTHORS

 Peter Yang (pyang@rice.edu)
 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.20 $

=head1 METHODS

=cut

package Bio::NEXUS::UnknownBlock;

use strict;
use Carp;
use Bio::NEXUS::Functions;
use Bio::NEXUS::Block;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

use vars qw(@ISA);
@ISA = qw(Bio::NEXUS::Block);

=head2 new

 Title   : new
 Usage   : block_object = new Bio::NEXUS::UnknownBlock($block_type, $commands, $verbose);
 Function: Creates a new Bio::NEXUS::UnknownBlock object and automatically reads the file
 Returns : Bio::NEXUS::UnknownBlock object
 Args    : type (string), the commands/comments to parse (array ref), and a verbose flag (0 or 1; optional)

=cut

sub new {
    my ( $class, $type, $commands, $verbose ) = @_;
    unless ($type) { ( $type = lc $class ) =~ s/Bio::NEXUS::(.+)Block/$1/i; }
    my $self = { type => $type, block => $commands, verbose => $verbose };
    bless $self, $class;
    return $self;
}

=begin comment

 Name    : _write
 Usage   : $block->_write();
 Function: Writes NEXUS block from stored data
 Returns : none
 Args    : none

=end comment

=cut

sub _write {
    my $self = shift;
    my $fh = shift || \*STDOUT;
    print $fh "BEGIN ", uc $self->get_type(), ";\n";
    my $commands = $self->{'block'};
    for my $cmd (@$commands) {
        next if lc $cmd eq 'begin';
        print $fh "$cmd\n";
    }
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::UnknownBlock::';

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
