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

local $SIG{__WARN__} = sub { require Carp; Carp::confess("Warning: $_[0]") };

all_tests;
