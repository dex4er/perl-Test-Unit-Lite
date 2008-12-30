#!/usr/bin/perl

use strict;
use warnings;

use Test::Unit::Lite;

local $SIG{__WARN__} = sub { require Carp; Carp::confess("Warning: $_[0]") };

all_tests;
