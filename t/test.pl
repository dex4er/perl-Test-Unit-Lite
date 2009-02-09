#!/usr/bin/perl

use 5.006;

use strict;
use warnings;

use File::Basename;

BEGIN {
    chdir dirname(__FILE__) or die "$!";
    chdir '..' or die "$!";
};

use Test::Unit::Lite;

local $SIG{__WARN__} = sub { require Carp; Carp::confess("Warning: $_[0]") };

all_tests;
