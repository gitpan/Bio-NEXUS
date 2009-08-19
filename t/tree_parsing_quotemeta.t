#!/usr/bin/perl -w

######################################################
# Author: Arlin Stoltzfus, based on code kindly provided by Jon Hill, jon.hill@imperial.ac.uk
# $Id: tree_parsing_quotemeta.t,v 1.1 2009/08/13 20:35:55 astoltzfus Exp $
# $Revision: 1.1 $
# Reference : perldoc Test::Tutorial, Test::Simple, Test::More
# Date : 13th August 2009

# This test is in regard to a bug report: 
#    [rt.cpan.org #47707] Bug in Bio::NEXUS::Node.pm
# 

use Test::More tests =>1;
use strict;
use warnings;
use Data::Dumper;
use lib '../lib';
use Bio::NEXUS;

################## test case to demonstrate bug in Bio::NEXUS #######################################

print "---- Test for parsing taxon names (in tree) with odd chars such as '+' \n"; 

# Jon Hill writes: 
# 
# apologies for the slightly convlouted example - it's using code snippets
# from my own module which have to handle more complex things :)
#
#
# We're going to try and remove taxa_4, but 'taxa_n+taxa_2' will 
# dissappear too.

my $quote_taxa_tree = "(taxa_1, 'taxa_n+taxa_2', 'taxa_3=taxa5', taxa_4)";

# set up nexus object
my $nexus_obj   = new Bio::NEXUS();
my $trees_block = new Bio::NEXUS::TreesBlock('trees');
$trees_block->add_tree_from_newick( $quote_taxa_tree , "tree_1" );
$nexus_obj->add_block($trees_block);
$nexus_obj->set_taxablock();

# remove taxa
$nexus_obj = $nexus_obj->exclude_otus( ["taxa_4"] );

# get out trees
my @trees;
# generate new newick string
# loop over all trees found in file and return
foreach my $block ( @{ $nexus_obj->get_blocks() } ) {
    my $type = $block->{'type'};
    if ( $type eq "trees" ) {
        foreach my $tree ( @{ $block->get_trees() } ) {
            # add to array after stripping off ;
            push( @trees,substr( $tree->as_string_inodes_nameless(), 0, -1 ) );
        }
    }
}

my $answer = "(taxa_1,'taxa_n+taxa_2','taxa_3=taxa5')";
is ($trees[0], $answer, "Removed correct taxa");
