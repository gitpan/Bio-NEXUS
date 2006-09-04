#!/usr/bin/perl -Tw
# Written by Gopalan Vivek (gopalan@umbi.umd.edu.sg)
# Reference : perldoc Test::Tutorial, Test::Simple, Test::More
# Date : 28th July 2006

#use Test::More tests => 4;
use Test::More 'no_plan';
use strict;
use Data::Dumper;
use lib '../lib';

use Bio::NEXUS;
my ($nexus,$blocks,$character_block,$taxa_block,$tree_block,$text_value);

##################  Radical White space (legal) in the NEXUS data #####################################

print "\n---- Radical white-space (legal) in the NEXUS data \n"; 

$text_value =<<STRING;
#NEXUS

BEGIN TAXA;
      dimensions ntax=7;
      taxlabels A 

B 
C 
             D      E     F      G;  
END;

BEGIN CHARACTERS;
      dimensions nchar=5;
      format datatype=protein missing=? gap=-;
      charlabels 1

 2

 3

 4

5

;
      matrix
A     --O
NE
B     --ONE
C     T


WO--
D     THREE
E     F-O
UR
F     FIVE-
G     SIX--;
END; 

BEGIN TREES;
       tree radical_whitespace = (
(
 (
  (
   (
    (A:1,
         B:1):1,
                C:2):1,
                       D:3):1,
                              E:4):1,
                                     F:5):1,
                                            G:6)
;
END;

STRING

eval {
   $nexus      = new Bio::NEXUS(); 					    # create an object
      $nexus->read({'format'=>'string','param' => $text_value});
};
print "\n$@\n" if $@ ne '';
is( $@,'', 'NEXUS object created and parsed');                # check that we got something
ok(grep(/C/, @{$nexus->get_block('taxa')->get_taxlabels}),"taxa label C parsed correctly in Taxa block");
ok(grep(/NE/, @{$nexus->get_block('taxa')->get_taxlabels}) <= 0,"taxa label 'NE' not present in Taxa block");
ok(grep(/C/, @{$nexus->get_block("Characters")->get_taxlabels}) > 0,"taxa label C parsed correctly in  Characters Block");
ok(grep(/5/, @{$nexus->get_block("Characters")->get_charlabels}) > 0,"character label '5' parsed correctly in  Characters Block");
ok(grep(/C/, @{$nexus->get_block("Trees")->get_tree->get_node_names}) > 0,"taxa label C parsed correctly in the Tree");
is($nexus->get_block("Trees")->get_tree->get_name ,'radical_whitespace',"tree name 'radical_whitespace' parsed correctly");

