#!/usr/bin/perl

use strict;
use warnings;

use File::Basename ();

BEGIN {
    chdir File::Basename::dirname(__FILE__) or die "$!";
    chdir '..' or die "$!";
}

use lib 'inc', 'lib';

use Test::Unit::Lite;

all_tests;
