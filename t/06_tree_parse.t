#!/usr/bin/perl -Tw
# Written by Vivek Gopalan (gopalan@umbi.umd.edu.sg)
# Reference : perldoc Test::Tutorial, Test::Simple, Test::More
# Date : 28th July 2006

use Test::More 'no_plan';
use strict;
use Data::Dumper;
use lib '../lib';

use Bio::NEXUS;

my ($tree,$tree_block,$text_value);


    my $tree_strings = [
    "tree 'basal-trifurcation' = (((A:1,B:1):1,(C:1,D:1):1):1,(E:1,F:1):2,(G:1,H:1):2);",
    "tree bush = (((A:1,B:1):1,(C:1,D:1):1):1,((E:1,F:1):1,(G:1,H:1):1):1);",
    "tree 'bush-branchlength-negative' = (((A:1,B:1):1,(C:1,D:1):-0.25):1,((E:1,F:1):1,(G:1,H:1):1):1);",
    "tree 'bush-branchlength-scientific' = (((A:1,B:2e+01):1,(C:9e-01,D:1):1):1,((E:1,F:9E-01):1,(G:2E+01,H:1):1):1);",
    "tree 'bush-branchlength-zero' = (((A:1,B:1):1,(C:0,D:1):1):1,((E:1,F:1):1,(G:1,H:1):1):1);",
    "tree 'bush-cladogram' = (((A,B),(C,D)),((E,F),(G,H)));",
    "tree 'bush-extended-root-branch' = (((A:1,B:1):1,(C:1,D:1):1):1,((E:1,F:1):1,(G:1,H:1):1):1):1;",
    "tree 'bush-inode-labels' = (((A:1,B:1)AB:1,(C:1,D:1)CD:1)ABCD:1,((E:1,F:1)EF:1,(G:1,H:1)GH:1)EFGH:1);",
    "tree 'bush-inode-labels-partial' = (((A:1,B:1):1,(C:1,D:1):1):1,((E:1,F:1)EF:1,(G:1,H:1)GH:1)EFGH:1);",
    "tree 'bush-inode-labels-quoted1' = (((A:1,B:1)'inode AB':1,(C:1,D:1)'inode CD':1)'inode ABCD':1,((E:1,F:1)'inode EF':1,(G:1,H:1)'inode GH':1)'inode EFGH':1);",
    "tree 'bush quoted string name1' = (((A:1,B:1):1,(C:1,D:1):1):1,((E:1,F:1):1,(G:1,H:1):1):1);",
    "tree 'bush-uneven' = (((A:1,B:2):1,(C:1,D:2):1):1,((E:1,F:2):1,(G:1,H:2):1):1);",
    "tree ladder = (((((((A:1,B:1):1,C:2):1,D:3):1,E:4):1,F:5):1,G:6):1,H:7);",
    "tree 'ladder-cladogram' = (((((((A,B),C),D),E),F),G),H);",
    "tree 'ladder-uneven' = (((((((A:1,B:2):1,C:2):1,D:4):1,E:4):1,F:6):1,G:6):1,H:8);",
    "tree rake = (A:1,B:1,C:1,D:1,E:1,F:1,G:1,H:1);",
    "tree 'rake-cladogram' = (A,B,C,D,E,F,G,H);"
];

my $nexus_obj;
foreach my $tree_str (@{$tree_strings}) {


   print $tree_str,"\n";
   $tree_str =~/tree (.*) =/;
   my $tree_name = $1;
      $tree_name =~s/['"]//g;
      $tree_name =~s/ /_/g; ## According to NEXUS standard, the whitespace in the tree name or node name is equivalent to "-"(underscore)

$text_value =<<STRING;
#NEXUS

BEGIN TAXA;
      dimensions ntax=8;
      taxlabels A B C D E F G H;  
END;

BEGIN TREES;
   $tree_str
END;
STRING

eval {
   $nexus_obj = new Bio::NEXUS;
   $nexus_obj->read({'format'=>'string','param'=>$text_value}); 			    # create an object
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
