#!/usr/bin/perl -w

######################################################
# Author: Chengzhi Liang, Weigang Qiu, Peter Yang, Thomas Hladish, Brendan
# $Id: tree_parsing.t,v 1.7 2007/09/21 07:30:27 rvos Exp $
# $Revision: 1.7 $


# Written by Vivek Gopalan (gopalan@umbi.umd.edu)
# Reference : perldoc Test::Tutorial, Test::Simple, Test::More
# Date : 28th July 2006

use Test::More 'no_plan';
use strict;
use warnings;
use Data::Dumper;
use lib '../lib';

use Bio::NEXUS;

my ($tree,$tree_block);

    my $file_names = [
"trees-tree-basal-trifurcation.nex",
"trees-tree-bush.nex",
"trees-tree-bush-branchlength-negative.nex",
"trees-tree-bush-branchlength-scientific.nex",
"trees-tree-bush-branchlength-zero.nex",
"trees-tree-bush-cladogram.nex",
"trees-tree-bush-extended-root-branch.nex",
"trees-tree-bush-inode-labels.nex",
"trees-tree-bush-inode-labels-partial.nex",
"trees-tree-bush-inode-labels-quoted2.nex",
"trees-tree-bush-quoted-string-name2.nex",
"trees-tree-bush-uneven.nex",
"trees-tree-ladder.nex",
"trees-tree-ladder-cladogram.nex",
"trees-tree-ladder-uneven.nex",
"trees-tree-rake-cladogram.nex"
];

my $nexus_obj;
foreach my $file_name (@{$file_names}) {

   my $tree_name = $file_name;
      $tree_name =~ s/trees-tree-//;
      $tree_name =~ s/\.nex//;
      $tree_name =~s/-/_/g; 
   print $file_name," (", $tree_name, ")\n";
   $file_name = "t/data/compliant/".$file_name;
      
eval {
   $nexus_obj = new Bio::NEXUS( $file_name );
   $tree_block = $nexus_obj->get_block('trees');
};

   is( $@,'', 'TreesBlock object created and parsed');                # check that we got something
   plan skip_all => "Problem reading NEXUS file" if $@;

   $tree = $tree_block->get_tree();
   my $no_of_nodes;
   my $otus = 8;
   if ($tree_name =~/rake/) { ## sets the total number of nodes different types of trees
      $no_of_nodes = 9;
   } elsif ($tree_name =~/trifurcation/){
      $no_of_nodes = 14;
   } else {
      $no_of_nodes = 15;
   }

   is(@{$tree->get_nodes},$no_of_nodes,"$no_of_nodes nodes defined: ". $otus. " otus + " . ($no_of_nodes-$otus) . " root");
   is(@{$tree->get_node_names},$otus,"$otus OTUs defined ");
   is($tree->get_name ,$tree_name,"the quoted tree name $tree_name parsed correctly");

# Check the brach length parsing for the tree with branch length in scientific notation
   if ($tree_name =~/scient/) {
      my $node = $tree->find('B');
      ok( defined $node,"Node name 'B' parsed correctly");
 SKIP: {
	  skip "Node not parsed correctly. Hence the branch length checking is skipped", 1 if not defined $node;
	  is(($node->get_length)*1,20,"Branch length (scientific notation) read correctly") if defined $node;
}
   }
}
