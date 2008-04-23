#!/usr/bin/env perl

######################################################
# Author: Chengzhi Liang, Weigang Qiu, Peter Yang, Thomas Hladish, Brendan
# $Id: charactersblock_methods-02.t,v 1.12 2008/04/14 16:55:01 astoltzfus Exp $
# $Revision: 1.12 $


# Written by Vivek Gopalan (gopalan@umbi.umd.edu)
# Reference : perldoc Test::Tutorial, Test::Simple, Test::More
# Date : 27th November 2006

use Test::More 'no_plan';
use strict;
use warnings;
use Data::Dumper;
use lib 'lib';
use Bio::NEXUS;

print "Testing CharactersBlock.pm module (its methods)...\n";

my $nexus_file= "t/data/compliant/04_charactersblock_methods_01.nex";

my ($nexus_obj, $blocks, $char_block);
eval {
    $nexus_obj = new Bio::NEXUS($nexus_file);    # create an object
    $blocks          = $nexus_obj->get_blocks();
    $char_block = $nexus_obj->get_block("Characters");
};

is($@, '', 'File was parsed without any problems');
isa_ok($char_block, "Bio::NEXUS::CharactersBlock", "char_block is of appropriate data-type: ");

my $A_seq = join('', @{$char_block->{'otuset'}->{'otus'}[0]->{'seq'}});
is($A_seq, "-MQVADISLQG--DAKKGANLFKTRCAQCHTLKAGEGNKI-----------GPELHG-?", "The char sequence of A taxon is correct");

#$char_block->add_states_to_charstates(['x', 'y', 'z']);
#$char_block->add_states_to_charstates('x');

is ($char_block->find_taxon('B'), 1, "Taxon 'B' is present");
is ($char_block->find_taxon('Z'), 0, "Taxon 'Z' is not present");

is ($char_block->get_nchar(), 59, "Number of characters is correct");



#------------------------------------------------------------------------------------------------------------
#### Creating similar files, but changing the characters block in some of them to test the "equals()" method
#------------------------------------------------------------------------------------------------------------

my $nexus_file_2= "t/data/compliant/04_charactersblock_methods_02.nex";


###################### !!!!!!!!!!!!!! #######################
# The 2rd character of 'A' taxon was changed from 'M' to 'Q'

my $nexus_file_3= "t/data/compliant/04_charactersblock_methods_03.nex";


# this file is identical to the original ...
my $nexus_file_4= "t/data/compliant/04_charactersblock_methods_04.nex";

($nexus_obj, $blocks) = (undef, undef);

$nexus_obj = new Bio::NEXUS($nexus_file_2);    # create an object
$blocks          = $nexus_obj->get_blocks();
my $char_block_2 = $nexus_obj->get_block("Characters");

$nexus_obj = new Bio::NEXUS($nexus_file_3);    # create an object
$blocks          = $nexus_obj->get_blocks();
my $char_block_3 = $nexus_obj->get_block("Characters");

$nexus_obj = new Bio::NEXUS($nexus_file_4);    # create an object
$blocks          = $nexus_obj->get_blocks();
my $char_block_4 = $nexus_obj->get_block("Characters");

# And now with the equals() horror...

ok ($char_block->equals($char_block), "char_block == char_block");
ok (!$char_block->equals($char_block_2), "char_block != char_block_2");
ok (!$char_block->equals($char_block_3), "char_block != char_block_3");
ok ($char_block->equals($char_block_4), "char_block == char_block_4");

print "char_block->equals(char_block): ", $char_block->equals($char_block), "\n";
print "char_block->equals(char_block_2): ", $char_block->equals($char_block_2), "\n";
print "char_block->equals(char_block_4): ", $char_block->equals($char_block_4), "\n";


# Testing char-s & states

$nexus_file= "t/data/compliant/04_charactersblock_methods_05.nex";

my $nex_obj = undef;
$char_block = undef;
eval {
	$nex_obj = new Bio::NEXUS($nexus_file);
	$char_block = $nex_obj->get_block("characters");
};
is ($@, '', 'Parsing successful');

# 	charstatelabels 1 hair/absent present, 2 color/red blue, 3 size/small big;

my $labels = $char_block->get_charstatelabels(); 

print "Checking processing of labels from charstatelabels command . . . \n"; 
is ( $$labels[0]{'charlabel'}, 'hair', "Label 'hair' for first character");  
my $states = $$labels[0]{'states'}; 
is ( $$states{'0'}, 'absent', "Label 'absent' for state 0 of first character");  
is ( $$states{'1'}, 'present', "Label 'present' for state 1 of first character");  

is ( $$labels[1]{'charlabel'}, 'color', "Label 'color' for second character");  
$states = $$labels[1]{'states'}; 
is ( $$states{'0'}, 'red', "Label 'red' for state 0 of second character");  

is ( $$labels[2]{'charlabel'}, 'size', "Label 'size' for third char");  
$states = $$labels[2]{'states'}; 
is ( $$states{'1'}, 'big', "Label 'big' for state 1 of third character");  

# print "charstatelabels: ", Dumper $char_block->get_charstatelabels();
#print "charstates: ", Dumper $char_block->get_charstates();
#print "charlables: ", Dumper $char_block->get_charlabels();
#print "statelabels: ", Dumper $char_block->get_statelabels();

print "Renaming an OTU...\n";
$char_block->rename_otus({'taxon_1' => 'homo_sap'});

my $otus = $char_block->get_otus();
my $has_otu= 0;
foreach my $otu (@{$otus}) {
		if ($otu->get_name() eq 'taxon_1') {
				$has_otu= 1;
				last;
		}
}
is ($has_otu, 0, "Renaming successful: taxon_1 is not in the set");
$has_otu = 0;
foreach my $otu (@{$otus}) {
		if ($otu->get_name() eq 'homo_sap') {
				$has_otu= 1;
				last;
		}
}
is ($has_otu, 1, "Renaming successful: homo_sap is in the set");
$has_otu = 0;
foreach my $otu (@{$otus}) {
		if ($otu->get_name() eq 'taxon_2') {
				$has_otu= 1;
				last;
		}
}
is ($has_otu, 1, "Renaming successful: taxon_2 is in the set");

#Added by Vivek (14-Dec- 2006) Based on the BUG submitted by John Bradley
#select_columns && get_nchar methods

$char_block->select_columns([1]);

is ($char_block->get_nchar, 1, "Get nchar successful: When one column is selected");
my $otu_set = $char_block->get_otuset();
is ($char_block->get_nchar, $otu_set->get_nchar, " The nchar in Characters block and no. of characters in MATRIX are equal: When one column is selected");


=methods not tested

# add_states_to_charstates
# create_charstates
# set_otuset
# set_charstatelabels
# set_charlabels
# set_statelabels

=cut

