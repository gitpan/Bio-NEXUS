#!/usr/bin/perl -Tw
# Written by Gopalan Vivek (gopalan@umbi.umd.edu.sg)
# Refernce : http://www.perl.com/pub/a/2004/05/07/testing.html?page=2
# Date : 28th July 2006

use strict;
use Test::More;
eval "use Test::Pod";

plan skip_all => "Test::Pod required for testing POD" if $@;
all_pod_files_ok();
