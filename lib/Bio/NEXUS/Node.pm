######################################################
# Node.pm
######################################################
# Author:  Weigang Qiu, Eugene Melamud, Chengzhi Liang, Peter Yang, Thomas Hladish
# $Id: Node.pm,v 1.51 2006/08/31 16:33:13 vivek Exp $

#################### START POD DOCUMENTATION ##################

=head1 NAME

Bio::NEXUS::Node - provides a few functions for nodes

=head1 SYNOPSIS

new Bio::NEXUS::Node;

=head1 DESCRIPTION

Provides a few useful functions for nodes.

=head1 FEEDBACK

All feedback (bugs, feature enhancements, etc.) are all greatly appreciated. There are no mailing lists at this time for the Bio::NEXUS::Node module, so send all relevant contributions to Dr. Weigang Qiu (weigang@genectr.hunter.cuny.edu).

=head1 AUTHORS

 Weigang Qiu (weigang@genectr.hunter.cuny.edu)
 Eugene Melamud (melamud@carb.nist.gov)
 Chengzhi Liang (liangc@umbi.umd.edu)
 Thomas Hladish (tjhladish at yahoo)

=head1 CONTRIBUTORS

 Peter Yang (pyang@rice.edu)

=head1 METHODS

=cut

package Bio::NEXUS::Node;

use strict;
use Bio::NEXUS::Functions;
use Data::Dumper;
use Carp;

use Bio::NEXUS; our $VERSION = $Bio::NEXUS::VERSION;

sub BEGIN {
    eval {
        require warnings;
        1;
        }
        or do {
        no strict 'refs';
        *warnings::import = *warnings::unimport = sub { };
        $INC{'warnings.pm'} = '';
        };
}

=head2 new

 Title   : new
 Usage   : $node = new Bio::NEXUS::Node();
 Function: Creates a new Bio::NEXUS::Node object
 Returns : Bio::NEXUS::Node object
 Args    : none

=cut

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

=head2 clone

 Title   : clone
 Usage   : my $newblock = $block->clone();
 Function: clone a block object (shallow)
 Returns : Block object
 Args    : none

=cut

sub clone {
    my ($self) = @_;
    my $class = ref($self);
    my $newnode = bless( { %{$self} }, $class );
    my @children = @{ $newnode->get_children() };
    $newnode->set_children();
    for my $child (@children) {
        my $newchild = $child->clone();
        $newnode->add_child($newchild);
        $newchild->set_parent_node($newnode);
    }
    return $newnode;
}

=head2 get_seq

 Title   : get_seq
 Usage   : $sequence = $node->get_seq();
 Function: Returns the node's sequence
 Returns : sequence (string)
 Args    : none

=cut

sub get_seq {
    my ($self) = @_;
    return $self->{'seq'};
}

=head2 set_seq

 Title   : set_seq
 Usage   : $node->set_seq($sequence);
 Function: Sets sequence of the node
 Returns : none
 Args    : sequence (string)

=cut

sub set_seq {
    my ( $self, $seq ) = @_;
    $self->{'seq'} = $seq;
}

=head2 set_parent_node

 Title   : set_parent_node
 Usage   : $node->set_parent_node($parent);
 Function: Sets the parent node of the node
 Returns : none
 Args    : parent node (Bio::NEXUS::Node object)

=cut

sub set_parent_node {
    my ( $self, $parent ) = @_;
    $self->{'parent'} = $parent;
}

=head2 get_parent

 Title   : get_parent
 Usage   : $parent=$node->get_parent();
 Function: Returns the parent node of the node
 Returns : parent node (Bio::NEXUS::Node object) or undef if nonexistent
 Args    : none

=cut

sub get_parent {
    if ( defined $_[0]->{'parent'} ) {
        return $_[0]->{'parent'};
    }
    else {
        return undef;
    }
}

=head2 set_length

 Title   : set_length
 Usage   : $node->set_length($length);
 Function: Sets the node's length (meaning the length of the branch leading to the node)
 Returns : none
 Args    : length (number)

=cut

sub set_length {
    my ( $self, $length ) = @_;
    $self->{'length'} = $length;
}

=head2 get_length

 Title   : length
 Usage   : $length=$node->get_length();
 Function: Returns the node's length
 Returns : length (integer) or undef if nonexistent
 Args    : none

=cut

sub get_length {
    if ( defined $_[0]->{'length'} ) {
        return $_[0]->{'length'};
    }
    else {
        return undef;
    }
}

=head2 get_total_length

 Title   : get_total_length
 Usage   : $total_length = $node->get_total_length();
 Function: Gets the total branch length of the node and that of all the children (???)
 Returns : total branch length
 Args    : none

=cut

sub get_total_length {
    my $self = shift;
    my $len = $self->get_length() || 0;
    for my $child ( @{ $self->get_children() } ) {
        $len += $child->get_total_length();
    }
    return $len;
}

=head2 set_support_value

 Title   : set_support_value
 Usage   : $node->set_support_value($bootstrap);
 Function: Sets the branch support value associated with this node
 Returns : none
 Args    : bootstrap value (integer)

=cut

sub set_support_value {
    my ( $self, $bootstrap ) = @_;
    confess
        "Attempt to set bad branch support value: <$bootstrap> is not a valid number: $!"
        unless _is_number($bootstrap) or (not defined $bootstrap);

    $self->{'bootstrap'} = $bootstrap;
}

=head2 get_support_value

 Title   : get_support_value
 Usage   : $bootstrap=$node->get_support_value();
 Function: Returns the branch support value associated with this node
 Returns : bootstrap value (integer) or undef if nonexistent
 Args    : none

=cut

sub get_support_value {
    if ( defined $_[0]->{'bootstrap'} ) {
        return $_[0]->{'bootstrap'};
    }
    else {
        return undef;
    }
}

=begin comment

 Title   : _set_xcoord
 Usage   : $node->_set_xcoord($xcoord);
 Function: Sets the node's x coordinate (?)
 Returns : none
 Args    : x coordinate (integer)

=end comment 

=cut

sub _set_xcoord {
    my ( $self, $xcoord ) = @_;
    $self->{'xcoord'} = $xcoord;
}

=begin comment

 Title   : _get_xcoord
 Usage   : $xcoord=$node->_get_xcoord();
 Function: Returns the node's x coordinate
 Returns : x coordinate (integer) or undef if nonexistent
 Args    : none

=end comment 

=cut

sub _get_xcoord {
    if ( defined $_[0]->{'xcoord'} ) {
        return $_[0]->{'xcoord'};
    }
    else {
        return undef;
    }
}

=begin comment

 Title   : _set_ycoord
 Usage   : $node->_set_ycoord($ycoord);
 Function: Sets the node's y coordinate (?)
 Returns : none
 Args    : y coordinate (integer)

=end comment 

=cut

sub _set_ycoord {
    my ( $self, $ycoord ) = @_;
    $self->{'ycoord'} = $ycoord;
}

=begin comment

 Title   : _get_ycoord
 Usage   : $ycoord=$node->_get_ycoord();
 Function: Returns the node's y coordinate
 Returns : y coordinate (integer) or undef if nonexistent
 Args    : none

=end comment 

=cut

sub _get_ycoord {
    my $self = shift;
    return $self->{'ycoord'};
}

=head2 set_name

 Title   : set_name
 Usage   : $node->set_name($name);
 Function: Sets the node's name
 Returns : none
 Args    : name (string/integer)

=cut

sub set_name {
    my ( $self, $name ) = @_;
    $self->{'name'} = $name;
}

=head2 get_name

 Title   : get_name
 Usage   : $name = $node->get_name();
 Function: Returns the node's name
 Returns : name (integer/string) or undef if nonexistent
 Args    : none

=cut

sub get_name {
    my $self = shift;
    return $self->{'name'};
}

=head2 is_otu

 Title   : is_otu
 Usage   : $node->is_otu();
 Function: Returns 1 if the node is an OTU or 0 if it is not (internal node)
 Returns : 1 or 0
 Args    : none

=cut

sub is_otu {
    my $self = shift;
    defined $self->{'children'} ? return 0 : return 1;
}

=head2 add_child

 Title   : add_childTU
 Usage   : $node->add_child($node);
 Function: Adds a child to an existing node
 Returns : none
 Args    : child (Bio::NEXUS::Node object)

=cut

sub add_child {
    my ( $self, $child ) = @_;
    push @{ $self->{'children'} }, $child;
}

=head2 distance

 Title   : distance
 Usage   : $distance = $node1->distance($node2);
 Function: Calculates tree distance from one node to another (?)
 Returns : distance (floating-point number)
 Args    : node1, node2 (Bio::NEXUS::Node objects)

=cut

sub distance {
    my ( $node1, $node2 ) = @_;
    my $distance = 0;
    if ( $node1 eq $node2 ) {
        return 0;
    }
    my $tmp_node1 = $node1;
    my $tmp_node2 = $node2;

    my %parent1;
    my $common_parent;

    while ( defined $tmp_node1->{'parent'} ) {
        $parent1{$tmp_node1} = 1;
        $tmp_node1 = $tmp_node1->{'parent'};
    }

    #add root node to hash
    $parent1{$tmp_node1} = 1;

    #the following line handles cases where node2 is root
    $common_parent = $tmp_node2;

    while ( not exists $parent1{$tmp_node2} ) {
        if ( defined $tmp_node2->{'parent'} ) {
            $distance += $tmp_node2->get_length();
            $tmp_node2 = $tmp_node2->{'parent'};
        }
        $common_parent = $tmp_node2;
        my $tmp = $common_parent->get_length();
    }

    $tmp_node1 = $node1;    #reset node1
    while ( $tmp_node1 ne $common_parent ) {
        if ( defined $tmp_node1->{'parent'} ) {
            $distance += $tmp_node1->get_length();
            $tmp_node1 = $tmp_node1->{'parent'};
        }
    }
    return $distance;
}

=head2 to_string

 Title   : to_string
 Usage   : my $string; $root->tree_string(\$string, 0)
 Function: recursively builds Newick tree string from root to tips 
 Returns : none
 Args    : reference to string, boolean $remove_inode_names flag

=cut

sub to_string(\$) {
    my ( $self, $outtree, $remove_inode_names ) = @_;

    my $name = $self->get_name();
    $name = _nexus_formatted($name);
    my $bootstrap = $self->get_support_value();
    my $length    = $self->get_length();
    my @children  = @{ $self->get_children() };

    if (@children) {    # if $self is an internal node
        $$outtree .= '(';

        for my $child (@children) {
            $child->to_string( $outtree, $remove_inode_names );
        }

        $$outtree .= ')';

        if ( defined $name && !$remove_inode_names ) { $$outtree .= $name }
        if ( defined $length )    { $$outtree .= ":$length" }
        if ( defined $bootstrap ) { $$outtree .= "[$bootstrap]" }

        $$outtree .= ',';

    }
    else {    # if $self is a terminal node

        croak "OTU found without a name (terminal nodes must be named): $!"
            unless defined $name;
        $$outtree .= $name;

        if ( defined $length )    { $$outtree .= ":$length" }
        if ( defined $bootstrap ) { $$outtree .= "[$bootstrap]" }

        $$outtree .= ',';
    }
    $$outtree =~ s/,\)/)/g;
}

=head2 set_children

 Title   : set_children
 Usage   : $node->set_children($children);
 Function: Sets children
 Returns : $node
 Args    : arrayref of children

=cut

sub set_children {
    my ( $self, $children ) = @_;
    $self->{'children'} = $children;
}

=head2 get_children

 Title   : get_children
 Usage   : @children = @{ $node->get_children() };
 Function: Retrieves list of children
 Returns : array of children (Bio::NEXUS::Node objects)
 Args    : none

=cut

sub get_children {
    my $self = shift;
    return $self->{'children'} if ( $self->{'children'} );
    return [];
}

=head2 walk

 Title   : walk
 Usage   : @descendents = $node->walk();
 Function: Walks through tree and compiles a "clade list" 
     (including $self and all inodes and otus descended from $self)
 Returns : array of nodes
 Args    : generally, none, though walk() calls itself recurseively with 
     2 arguments: the node list so far, and a counting variable for inode-naming

=cut

sub walk {
    my ( $self, $nodes, $i ) = @_;

    my $name = $self->get_name();

    # if the node doesn't have a name, name it inode<number>
    if ( !$name ) {
        $self->set_name( 'inode' . $$i++ );
    }

    # if it's not an otu, and the name is a number ('X'), rename it inodeX
    elsif ( !$self->is_otu() && $name =~ /^\d+$/ ) {
        $self->set_name( 'inode' . $name );
    }

    my @children = @{ $self->get_children() };

    # if $self is not an otu,
    if (@children) {
        for my $child (@children) {
            $child->walk( $nodes, $i ) if $child;
        }
    }

    push @$nodes, $self;
}

=head2 get_otus

 Title   : get_otus
 Usage   : @listOTU = @{$node->get_otu()}; (?)
 Function: Retrieves list of OTUs
 Returns : reference to array of OTUs (Bio::NEXUS::Node objects)
 Args    : none

=cut

sub get_otus {
    my $self = shift;
    my @otus;
    $self->_walk_otus( \@otus );
    return \@otus;
}

=begin comment

 Title   : _walk_otus
 Usage   : $self->_walk_otus(\@otus);
 Function: Walks through tree and retrieves otus; recursive
 Returns : none
 Args    : reference to list of otus

=end comment 

=cut

sub _walk_otus {
    my $self  = shift;
    my $nodes = shift;

    my $children = $self->get_children();
    for my $child (@$children) {
        if ( $child->is_otu ) {
            push @$nodes, $child;
        }
        else {
            $child->_walk_otus($nodes) if @$children;
        }
    }
}

=head2 printall

 Title   : printall
 Usage   : $tree_as_string = $self->printall(); 
 Function: Gets the node properties as a tabbed string for printing nicely 
           formatted trees (developed by Tom)
 Returns : Formatted string
 Args    : Bio::NEXUS::Node object

=cut

sub printall {
    my $self = shift;

    my $children = $self->get_children();
    my $str      = "Name: ";
    $str .= $self->get_name()          if ( $self->get_name() );
    $str .= "   OTU\?: ";
    $str .= $self->is_otu();
    $str .= "    Length: ";
    $str .= $self->get_length()        if $self->get_length();
    $str .= "    bootstrap: ";
    $str .= $self->get_support_value() if $self->get_support_value();
    $str .= "\n";
    carp($str);

    for my $child (@$children) {
        $child->printall();
    }
}

=begin comment

 Title   : _parse_newick
 Usage   : $self->_parse_newick($nexus_words, $pos);
 Function: Parse a newick tree string and build up the NEXPL tree it implies
 Returns : none
 Args    : Ref to array of NEXUS-style words that make up the tree string; ref to current position in array

=end comment 

=cut

sub _parse_newick {
    no warnings qw( recursion );
    my ( $self, $words, $pos ) = @_;
    croak
        'ERROR: Bio::NEXUS::Node::_parse_newick() called without something to parse'
        unless $words && @$words;
    $pos = 0 unless $pos;

    for ( ; $pos < @$words; $pos++ ) {
        my $word = $words->[$pos];

        if ( $word eq '(' ) {
            my $parent_node = $self;

            # start a new clade
            my $new_node = new Bio::NEXUS::Node;
            $parent_node->adopt($new_node);
            $pos = $new_node->_parse_newick( $words, ++$pos );
        }

        # We're starting a sibling of the current node's
        elsif ( $word eq ',' ) {
            my $parent_node = $self->get_parent();
            my $new_node    = new Bio::NEXUS::Node;
            $parent_node->adopt($new_node);
            $pos = $new_node->_parse_newick( $words, ++$pos );
        }

        elsif ( $word eq ')' ) {
            my $parent_node = $self->get_parent();
            $pos = $parent_node->_parse_newick( $words, ++$pos );

            # finish a clade
            last;
        }
        elsif ( $word eq ':' ) {
            $pos = $self->_parse_length( $words, ++$pos );
        }
##      The following would only be required for trees with bootstraps, but not
##      lengths . . . I'm not sure that's worth supporting
##
        #        elsif ( $word =~ /\[(.*)\]/ ) {
        #            $self->_parse_support_value( $words->[ ++$pos ] );
        #        }
        else {
            $self->set_name($word);
        }
    }
    return $pos;
}

=begin comment

 Title   : _parse_length
 Usage   : $self->_parse_length($length);
 Function: parses and stores branch lengths
 Returns : none
 Args    : $distance string, which may contain bootstraps as well

=end comment 

=cut

sub _parse_length {
    my ( $self, $words, $pos ) = @_;

    my $length = $words->[$pos];

    # number may have been split up if there were '-' (negative) signs
    until ( !defined $words->[ $pos + 1 ] || $words->[ $pos + 1 ] =~ /^[),]$/ )
    {
        $length .= $words->[ ++$pos ];
    }

    if ( $length =~ s/\[(.*)\]// ) {
        my $support_value = $1;
        $self->_parse_support_value($support_value);
    }

    croak
        "Bad branch length found in tree string: <$length> is not a valid number: $!"
        unless _is_number($length);

    if ( $length =~ /e/i ) {
        $length = _sci_to_dec($length);
    }
    $self->set_length($length);
    return $pos;
}

=begin comment

 Title   : _parse_support_value
 Usage   : $self->_parse_support_value($boostrap_value);
 Function: Unsure
 Returns : none
 Args    : unsure

=end comment 

=cut

sub _parse_support_value {
    my ( $self, $bootstrap ) = @_;

    croak
        "Bad branch support value found in tree string: <$bootstrap> is not a valid number: $!"
        unless _is_number($bootstrap);

    $self->set_support_value( _sci_to_dec($bootstrap) ) if defined _sci_to_dec($bootstrap);
    return $bootstrap;
}

=head2 find

 Title   : find
 Usage   : $node = $node->find($name);
 Function: Finds the first occurrence of a node called 'name' in the tree
 Returns : Bio::NEXUS::Node object
 Args    : name (string)

=cut

sub find {
    my ( $self, $name ) = @_;
    my $nodename = $self->get_name();

    #    carp("Starting the node find at node $nodename\n");
    my $children = $self->get_children();
    return $self if ( $self->get_name() eq $name );
    for my $child (@$children) {
        my $result = $child->find($name);
        return $result if $result;
    }
    return undef;
}

=head2 prune

 Name    : prune
 Usage   : $node->prune($OTUlist);
 Function: Removes everything from the tree except for OTUs specified in $OTUlist
 Returns : none
 Args    : list of OTUs (string)

=cut

sub prune {
    my ( $self, $OTUlist ) = @_;
    my $name = $self->get_name();
    if ( $self->is_otu() ) {
        if ( $OTUlist =~ /\s+$name\s+/ ) {

            # if in the list, keep this OTU
            return "keep";
        }
        else {

            # otherwise, delete it
            return "delete";
        }
    }
    my @children    = @{ $self->get_children() };
    my @newchildren = ();
    for my $child (@children) {
        my $result = $child->prune($OTUlist);
        if ( $result eq "keep" ) {
            push @newchildren, $child;
        }
    }
    $self->{'children'} = \@newchildren;
    if ( $#newchildren == -1 ) {

        # delete the inode because it doesn't have any children
        $self->{'children'} = undef;
        return "delete";
    }
    @children = @{ $self->get_children() };
    if ( $#children == 0 ) {
        my $child     = $children[0];
        my $childname = $children[0]->get_name();

        $self->set_name( $child->get_name() );
        $self->set_seq( $child->get_seq() );
        my $self_length = $self->get_length() || 0;
        $self->set_length( $self_length + $child->get_length() );
        $self->set_support_value( $child->get_support_value() );
        $self->_set_xcoord( $child->_get_xcoord() );
        $self->_set_ycoord( $child->_get_ycoord() );
        $self->{'children'} = $child->{'children'};
        if ( $child->is_otu() ) {
            $self->{'children'} = undef;
            undef $self->{'children'};
        }

        # assigning inode $name to child $childname
        return "keep";
    }

    # keeping this inode as is, since it has multiple children
    return "keep";
}

=head2 equals

 Name    : equals
 Usage   : $node->equals($another_node);
 Function: compare if two nodes (and their subtrees) are equivalent
 Returns : 1 if equal or 0 if not
 Args    : another Node object

=cut

sub equals {
    my ( $self, $node ) = @_;

    # if both OTUs
    if ( $self->is_otu() && $node->is_otu() ) {
        if ( $self->get_name() ne $node->get_name() ) { return 0; }
        if ( $self->get_length() && $node->get_length() ) {
            if ( $self->get_length() != $node->get_length() ) { return 0; }
        }
        elsif ( $self->get_length() || $node->get_length() ) { return 0; }
        return 1;
    }

    # if one is OTU
    if ( $self->is_otu() || $node->is_otu() ) { return 0; }

    # if both are not OTUs, check value first
    if (   ( $self->get_name() && $node->get_name() )
        && ( $self->get_name() ne $node->get_name() )
        || ( $self->get_support_value() && $node->get_support_value() )
        && ( $self->get_support_value() != $node->get_support_value() )
        || ( $self->get_length() && $node->get_length() )
        && ( $self->get_length() != $node->get_length() ) )
    {
        return 0;
    }

    # check children
    my @ch1 = @{ $self->get_children() };
    my @ch2 = @{ $node->get_children() };

    # check children number
    if ( scalar @ch1 != scalar @ch2 ) { return 0; }

    # compare each pair of children (cannot sort -- some no name)
    for ( my $i = 0; $i < scalar @ch1; $i++ ) {
        my $match = 0;
        for ( my $j = $i; $j < scalar @ch2; $j++ ) {
            if ( $ch1[$i]->equals( $ch2[$j] ) ) {

                # reoder children if found two equal
                my @temp = splice( @ch2, $j );
                my $temp = shift @temp;
                @ch2 = ( $temp, @ch2, @temp );
                $match = 1;
                last;
            }
        }
        if ( !$match ) { return 0; }
    }
    return 1;
}

=head2 get_siblings

 Name    : get_siblings
 Usage   : $node->get_siblings();
 Function: get sibling nodes of this node
 Returns : array ref of sibling nodes
 Args    : none

=cut

sub get_siblings {
    my $self       = shift;
    my $generation = $self->get_parent()->get_children();
    my $siblings   = [];
    for my $potential_sibling ( @{$generation} ) {
        if ( $potential_sibling ne $self ) {
            push( @$siblings, $potential_sibling );
        }
    }
    return $siblings;
}

=head2 is_sibling

 Name    : is_sibling
 Usage   : $node1->is_sibling($node2);
 Function: tests whether node1 and node2 are siblings
 Returns : 1 if true, 0 if false
 Args    : second node

=cut

sub is_sibling {
    my ( $self, $node2 ) = @_;
    my $parent1 = $self->get_parent();
    my $parent2 = $node2->get_parent();
    return "1" if $parent1 eq $parent2;
    return "0";
}

=begin comment

 Name    : _rearrange
 Usage   : $node->_rearrange($newparentnode);
 Function: re-arrange this node's parent and children (used in rerooting)
 Returns : this node after rearrangement
 Args    : this node's new parent node, $newparentnode must be this node's old child

=end comment 

=cut

sub _rearrange {
    my ( $self, $newparent ) = @_;

    # Remove the newparent from this node's children
    $self->set_children( $newparent->get_siblings() );

    # Recursively work up the tree until you get to the node
    my $oldparent = $self->get_parent();
    if ($oldparent) { $oldparent->_rearrange($self); }

    # set new parent as parent, self as child
    $newparent->adopt( $self, 0 );
    $self->set_support_value( $newparent->get_support_value() );
    $self->set_length( $newparent->get_length() );

    return $self;
}

=head2 adopt

 Title   : adopt
 Usage   : $parent->adopt($child, $overwrite_children);
 Function: make a parent-child relationship between two nodes
 Returns : none
 Args    : the child node, boolean clobber flag

=cut

sub adopt {
    my ( $parent, $child, $overwrite_children ) = @_;
    $child->set_parent_node($parent);
    if ($overwrite_children) {
        $parent->set_children( [$child] );
    }
    else {
        $parent->add_child($child);
    }
}

=head2 combine

 Title   : combine
 Usage   : my $newblock = $node->combine($child);
 Function: removes a node from the tree, effectively by sliding its only child up the branch to its former position
 Returns : none
 Args    : the child node
 Methods : Combines the child node and the current node by assigning the
           name, bootstrap value, children and other properties of the child.  The branch length
	   of the current node is added to the child node's branch length.

=cut

sub combine {
    my ( $self, $child ) = @_;
    $self->set_name( $child->get_name() );
    $self->set_support_value( $child->get_support_value() );
    $self->set_length( ( $self->get_length() || 0 ) + $child->get_length() );
    $self->set_children();
    $self->set_children( $child->get_children() ) if @{ $child->get_children } > 0;
}

=begin comment

 Title   : _assign_otu_ycoord
 Usage   : $root->_assign_otu_ycoord(\$ypos, \$spacing);
 Function: Assign y coords of OTUs
 Returns : none
 Args    : references to initial y position and space between each OTU

=end comment 

=cut

# Traverses tree and determines y position of every OTU it finds. If it finds
# an OTU, it adds the current y position to a hash of y coordinates (one key
# for each OTU) and increments the y position.
sub _assign_otu_ycoord {
    my ( $self, $yposref, $spacingref ) = @_;
    return if $self->is_otu();
    for my $child ( @{ $self->get_children() } ) {
        if ( $child->is_otu() ) {
            $child->_set_ycoord($$yposref);
            $$yposref += $$spacingref;
        }
        else {
            $child->_assign_otu_ycoord( $yposref, $spacingref );
        }
    }
}

=begin comment

 Title   : _assign_inode_ycoord
 Usage   : $root->_assign_inode_ycoord();
 Function: Get y coords of internal nodes based on OTU position (see _assign_otu_ycoord)
 Returns : none
 Args    : none

=end comment 

=cut

# Determines position of an internal node (halfway between all its children). Recursive.
sub _assign_inode_ycoord {
    my $self = shift;

    my @tmp;
    for my $child ( @{ $self->get_children() } ) {
        $child->_assign_inode_ycoord() unless ( defined $child->_get_ycoord() );
        push @tmp, $child->_get_ycoord();
    }
    my @sorted = sort { $a <=> $b } @tmp;
    my $high   = pop @sorted;
    my $low    = shift @sorted || $high;
    $self->_set_ycoord( $low + 1 / 2 * ( $high - $low ) );
}

=head2 set_depth

 Title   : set_depth
 Usage   : $root->set_depth();
 Function: Determines depth in tree of every node below this one
 Returns : none
 Args    : This node's depth

=cut

sub set_depth {
    my ( $self, $depth ) = @_;
    $self->{'depth'} = $depth;
    return if $self->is_otu();
    for my $child ( @{ $self->get_children() } ) {
        $child->set_depth( $depth + 1 );
    }
}

=head2 get_depth

 Title   : get_depth
 Usage   : $depth = $node->get_depth();
 Function: Returns the node's depth (number of 'generations' removed from the root) in tree
 Returns : integer representing node's depth
 Args    : none

=cut

sub get_depth {
    my $self = shift;
    return $self->{'get_depth'};
}

=head2 find_lengths

 Title   : find_lengths
 Usage   : $cladogram = 1 unless $root->find_lengths();
 Function: Tries to determine if branch lengths are present in the tree
 Returns : 1 if lengths are found, 0 if not
 Args    : none

=cut

sub find_lengths {
    my $self   = shift;
    my $length = $self->get_length();
    return 1 if ( $length || ( $length = 0 ) );
    for my $child ( @{ $self->get_children() } ) {
        return 1 if $child->find_lengths();
    }
    return 0;
}

=head2 mrca

 Title     : mrca
 Usage     : $mrca = $otu1-> mrca($otu2, $treename);
 Function: Finds most recent common ancestor of otu1 and otu2
 Returns : Node object of most recent common ancestor
 Args     : Nexus object, two otu objects, name of tree to look in

=cut

sub mrca {
    my ( $otu1, $otu2, $treename ) = @_;

    my $currentnode = $otu1;
    my @ancestors;
    my $mrca;
    until ( $currentnode->get_name() eq 'root' ) {
        $currentnode = $currentnode->get_parent();
        push( @ancestors, $currentnode );
    }
    $currentnode = $otu2;
    until ( $currentnode->get_name() eq 'root' ) {
        $currentnode = $currentnode->get_parent();
        for my $inode (@ancestors) {
            if ( $inode eq $currentnode ) {
                return $inode;
            }
        }
    }
}

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /DESTROY$/;
    my $package_name = 'Bio::NEXUS::Node::';

    # The following methods are deprecated and are temporarily supported
    # via a warning and a redirection
    my %synonym_for = (
        "${package_name}depth"       => "${package_name}get_depth",
        "${package_name}boot"        => "${package_name}get_support_value",
        "${package_name}_parse_boot" => "${package_name}_parse_support_value",
        "${package_name}set_boot"    => "${package_name}set_support_value",
        "${package_name}name"        => "${package_name}get_name",
        "${package_name}children"    => "${package_name}get_children",
        "${package_name}length"      => "${package_name}get_length",
        "${package_name}seq"         => "${package_name}get_seq",
        "${package_name}xcoord"      => "${package_name}_get_xcoord",
        "${package_name}ycoord"      => "${package_name}_get_ycoord",
        "${package_name}set_xcoord"  => "${package_name}_set_xcoord",
        "${package_name}set_ycoord"  => "${package_name}_set_ycoord",
        "${package_name}parent_node" => "${package_name}get_parent",
        "${package_name}isOTU"       => "${package_name}is_otu",
        "${package_name}walk_OTUs"   => "${package_name}_walk_otus",
        "${package_name}rearrange"   => "${package_name}_rearrange",
        "${package_name}parse"       => "${package_name}_parse_newick",
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
