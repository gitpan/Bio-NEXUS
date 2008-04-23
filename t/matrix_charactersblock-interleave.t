#!/usr/bin/perl -w

######################################################
# Author: Chengzhi Liang, Weigang Qiu, Peter Yang, Thomas Hladish, Brendan
# $Id: matrix_charactersblock-interleave.t,v 1.6 2007/02/22 20:46:50 vivek Exp $
# $Revision: 1.6 $


# Written by Gopalan Vivek (gopalan@umbi.umd.edu)
# Refernce : http://www.perl.com/pub/a/2004/05/07/testing.html?page=2
# Date : 2nd November 2006

use strict;
use warnings;
use Test::More 'no_plan';

use lib 'lib';
use Bio::NEXUS;
use Data::Dumper;


####################################
#  Test the [transpose,] Interleave and Statesformat subcommands in the FORMAT command in CHARACTERS Block
######################################

my ( $nexus, $blocks, $character_block, $taxa_block, $tree_block );

print "\n";
print "--- Testing interleave, statesformat [,transpose] ---\n";
my $file_name = "t/data/compliant/characters-block-interleave.nex";

###### 
eval {
		$nexus      = new Bio::NEXUS($file_name); 					    # create an object
        $blocks          = $nexus->get_blocks;
        $character_block = $nexus->get_block("Characters");
};

## Check whether the files are read successfully
    is( $@, '', 'Parsing nexus files' );
    isa_ok( $nexus, 'Bio::NEXUS', 'NEXUS object defined' );

## Check for all the blocks

    is( @{$blocks}, 2, "2 blocks are present" );
    isa_ok( $character_block, "Bio::NEXUS::CharactersBlock",'Bio::NEXUS::CharactersBlock object present' );
    my $seq_array_hash = $character_block->get_otuset->get_seq_array_hash;
    my $chars = $seq_array_hash->{'A'};
    is( @{$chars}, 59, "59 characters are present in 'A'" );
exit;
