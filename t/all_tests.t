#!/usr/bin/perl -w

use strict;

use lib 't/tlib', 'tlib';

use Test::Unit::Lite::HarnessUnit;

my $testrunner = Test::Unit::Lite::HarnessUnit->new();
$testrunner->start("AllTests");
