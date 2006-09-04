#!/usr/bin/perl -Tw
# Written by Gopalan Vivek (gopalan@umbi.umd.edu.sg)
# Reference : perldoc Test::Tutorial, Test::Simple, Test::More
# Date : 28th July 2006

use Test::More 'no_plan';
use strict;
use Data::Dumper;

use Bio::NEXUS;
my ($nexus,$blocks,$character_block,$taxa_block,$tree_block,$text_value);

################## 1.  Quoted string - 1 ; a) OTU name 'OTU C',b) charlabel 'Char 3',and c) tree name 'the ladder tree'  #####################################

print "\n---- Quoted string - 1 ; a) OTU name \'OTU C\' (single quotes) ,b) charlabel \"Char 3\",and c) tree name \"the ladder tree\" \n"; 

$text_value =<<STRING;
#NEXUS

BEGIN TAXA;
      dimensions ntax=8;
      taxlabels A B 'OTU C' D E F G H;
END;

BEGIN CHARACTERS;
      dimensions nchar=5;
      format datatype=protein missing=? gap=-;
      charlabels One Two 'Char 3' Four Five;
      matrix
A     --ONE
B     --ONE
'OTU C'     TWO--
D     THREE
E     F-OUR
F     FIVE-
G     SIX--
H     SEVEN;
END;

BEGIN TREES;
       tree 'the ladder tree' =
       (((((((A:1,B:1):1,'OTU C':2):1,D:3):1,E:4):1,F:5):1,G:6):1,H:7);
END;

STRING

eval {
   $nexus      = new Bio::NEXUS(); 					    # create an object
      $nexus->read({'format'=>'string','param' => $text_value});
};

print "\n$@\n" if $@ ne '';;
is( $@,'', 'NEXUS object created and parsed');                # check that we got something
ok(grep(/OTU_C/, @{$nexus->get_block('taxa')->get_taxlabels}),"taxa label 'OTU C' parsed correctly in Taxa block");
ok(grep(/OTU_C/, @{$nexus->get_block("Characters")->get_taxlabels}) > 0,"taxa label 'OTU C' parsed correctly in  Characters Block");
ok(grep(/OTU_C/, @{$nexus->get_block("Trees")->get_tree->get_node_names}) > 0,"taxa label 'OTU C' parsed correctly in the Tree");
is($nexus->get_block("Trees")->get_tree->get_name ,'the_ladder_tree',"the quoted tree name \'the ladder tree\' parsed correctly");
