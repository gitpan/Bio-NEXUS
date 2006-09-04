#!/usr/bin/perl -Tw
# Written by Gopalan Vivek (gopalan@umbi.umd.edu.sg)
# Reference : perldoc Test::Tutorial, Test::Simple, Test::More
# Date : 28th July 2006

# To test the effect of taxa label strings.

#use Test::More tests => 4;
use Test::More 'no_plan';
use strict;
use Data::Dumper;

use Bio::NEXUS;

my ($nexus, $tree, $tree_block, $taxa_block, $text_value);

################## 1. very long names in various places (OTU, char, tree labels)  #####################################

print "\n---- very long names in various places (OTU, char, tree labels)\n"; 
$text_value =<<STRING;
#NEXUS

BEGIN TAXA;
      dimensions ntax=8;
      taxlabels A B C D E F SupercalifragilisticexpialidociousOTU H;  
END;

BEGIN CHARACTERS;
      dimensions nchar=5;
      charlabels SupercalifragilisticexpialidociousLabel Two Three
      Four Five;
      format datatype=protein missing=? gap=-;
      matrix
A     --ONE
B     --ONE
C     TWO--
D     THREE
E     F-OUR
F     FIVE-
SupercalifragilisticexpialidociousOTU     SIX--
H     SEVEN;
END;

BEGIN TREES;
       tree SupercalifragilisticexpialidociousTree = (((((((A:1,B:1):1,C:2):1,D:3):1,E:4):1,F:5):1,SupercalifragilisticexpialidociousOTU:6):1,H:7);
END;

STRING

eval {
   $nexus      = new Bio::NEXUS(); 					    # create an object
   $nexus->read({'format'=>'string','param' => $text_value});
};

is( $@,'', 'NEXUS object created and parsed');                # check that we got something

$tree_block = $nexus->get_block("trees");
$taxa_block = $nexus->get_block("Taxa");
$tree = $tree_block->get_tree();
is(@{$tree->get_nodes},15,"15 nodes defined: 8 otus + 7 root");
is(@{$tree->get_node_names},8,"8 OTUs defined ");
ok(grep(/SupercalifragilisticexpialidociousOTU/, @{$taxa_block->get_taxlabels}) > 0,"Long string properly set in Taxa block");
ok(grep(/SupercalifragilisticexpialidociousOTU/, @{$nexus->get_block("Characters")->get_taxlabels}) > 0,"Long string properly set in Characters block");
ok(grep(/SupercalifragilisticexpialidociousOTU/, @{$nexus->get_block("Trees")->get_tree->get_node_names}) > 0,"Long string properly set in node of the Tree");
is($nexus->get_block("Trees")->get_tree->get_name ,'SupercalifragilisticexpialidociousTree',"Long string properly set in Tree name");

