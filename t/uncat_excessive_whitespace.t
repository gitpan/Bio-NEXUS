#!/usr/bin/perl -w

######################################################
# Author: Chengzhi Liang, Weigang Qiu, Peter Yang, Thomas Hladish, Brendan
# $Id: uncat_excessive_whitespace.t,v 1.8 2007/09/21 07:30:27 rvos Exp $
# $Revision: 1.8 $


# Written by Gopalan Vivek (gopalan@umbi.umd.edu)
# Reference : perldoc Test::Tutorial, Test::Simple, Test::More
# Date : 28th July 2006

#use Test::More tests => 4;
use Test::More 'no_plan';
use strict;
use warnings;
use Data::Dumper;
use lib 'lib';

use Bio::NEXUS;
my ($nexus,$blocks,$character_block,$taxa_block,$tree_block,$file_name);

##################  Radical White space (legal) in the NEXUS data #####################################

print "\n---- Radical white-space (legal) in the NEXUS data \n"; 

$file_name = 't/data/compliant/radical-whitespace.nex';

eval {
   $nexus      = new Bio::NEXUS( $file_name); 					    # create an object
};
print "\n$@\n" if $@ ne '';
is( $@,'', 'NEXUS object created and parsed');                # check that we got something
ok(grep(/C/, @{$nexus->get_block('taxa')->get_taxlabels}),"taxa label C parsed correctly in Taxa block");
ok(grep(/NE/, @{$nexus->get_block('taxa')->get_taxlabels}) <= 0,"taxa label 'NE' not present in Taxa block");
ok(grep(/C/, @{$nexus->get_block("Characters")->get_taxlabels}) > 0,"taxa label C parsed correctly in  Characters Block");
ok(grep(/5/, @{$nexus->get_block("Characters")->get_charlabels}) > 0,"character label '5' parsed correctly in  Characters Block");
ok(grep(/C/, @{$nexus->get_block("Trees")->get_tree->get_node_names}) > 0,"taxa label C parsed correctly in the Tree");
is($nexus->get_block("Trees")->get_tree->get_name ,'radical_whitespace',"tree name 'radical_whitespace' parsed correctly");

