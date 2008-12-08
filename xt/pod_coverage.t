#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use lib 't/tlib', 'tlib';

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

all_pod_coverage_ok();
