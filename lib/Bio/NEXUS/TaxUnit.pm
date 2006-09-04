########################################################################
# TaxUnit.pm
########################################################################
# Author: Chengzhi Liang, Thomas Hladish
# $Id: TaxUnit.pm,v 1.16 2006/08/29 09:50:38 thladish Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::TaxUnit

=head1 SYNOPSIS

$tu = new Bio::NEXUS::TaxUnit($name, $seq);

=head1 DESCRIPTION

This module represents a taxon unit in a NEXUS file (in characters block or History block)

=head1 COMMENTS

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are greatly appreciated. 

=head1 AUTHORS

 Chengzhi Liang (liangc@umbi.umd.edu)
 Thomas Hladish (tjhladish at yahoo)

=head1 VERSION

$Revision: 1.16 $

=head1 METHODS

=cut

package Bio::NEXUS::TaxUnit;

use strict;
use Bio::NEXUS::Functions;
use Carp;
use Data::Dumper;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

=head2 new

 Title   : new
 Usage   : $otu = new Bio::NEXUS::TaxUnit($name, $seq);
 Function: Creates a new Bio::NEXUS::TaxUnit object 
 Returns : Bio::NEXUS::TaxUnit object
 Args    : name and sequence of TaxUnit object

=cut

sub new {
    my ( $class, $name, $seq ) = @_;
    my $self = { name => $name, seq => $seq, };
    bless $self, $class;
    return $self;
}

=head2 clone

 Title   : clone
 Usage   : my $newtu = $set->clone();
 Function: clone an TaxUnit object 
 Returns : TaxUnit object
 Args    : none

=cut

sub clone {
    my ($self) = @_;
    my $class = ref($self);
    my $newtu = bless( { %{$self} }, $class );
    return $newtu;
}

=head2 set_name

 Title   : set_name
 Usage   : $tu->set_name($name);
 Function: sets the name of OTU 
 Returns : none
 Args    : name

=cut

sub set_name {
    my ( $self, $name ) = @_;
    $self->{'name'} = $name;
}

=head2 get_name

 Title   : get_name
 Usage   : $tu->get_name();
 Function: Returns name
 Returns : name
 Args    : none

=cut

sub get_name {
    my ($self) = @_;
    return $self->{'name'};
}

=head2 set_seq

 Title   : set_seq
 Usage   : $tu->set_seq($seq);
 Function: sets the sequence of OTU 
 Returns : none
 Args    : sequence

=cut

sub set_seq {
    my ( $self, $seq ) = @_;
    $self->{'seq'} = $seq;
}

=head2 get_seq

 Title   : get_seq
 Usage   : $tu->get_seq();
 Function: Returns sequence
 Returns : sequence (an array of characters or tokens)
 Args    : none

=cut

sub get_seq {
    my ($self) = @_;
    return $self->{'seq'};
}

=head2 get_seq_string

 Title   : get_seq_string
 Usage   : $taxunit->get_seq_string($tokens_flag);
 Function: Returns sequence
 Returns : sequence (a string, wherein tokens or characters are space-delimited 
           if a true value has been passed in for $tokens)
 Args    : boolean tokens argument (optional)

=cut

sub get_seq_string {
    my ( $self, $tokens_flag ) = @_;
    my @seq;
    for my $token ( @{ $self->get_seq } ) {
        if ( ref $token eq 'HASH' ) {
            my @states = @{ $token->{'states'} };
            if ( $token->{'type'} eq 'uncertainty' ) {
                push @seq, '{', @states, '}';
            }
            elsif ( $token->{'type'} eq 'polymorphism' ) {
                push @seq, '(', @states, ')';
            }
            else {
                croak
                    "Unknown token type encountered: only 'uncertainty' and 'polymorphism' are valid";
            }
        }
        else {
            push @seq, $token;
        }
    }
    my $delimiter = $tokens_flag ? q{ } : q{};
    return join $delimiter, @seq;
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::TaxUnit::';

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
