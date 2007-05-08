#!/usr/bin/perl -w

use strict;

use lib 't/tlib', 'tlib';

use Test::Unit::Lite;

use Test::Unit::HarnessUnit;

my $testrunner = Test::Unit::HarnessUnit->new();
$testrunner->start("AllTests");
