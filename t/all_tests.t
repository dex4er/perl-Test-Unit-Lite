#!/usr/bin/perl

use strict;
use warnings;

use lib 'inc', 'lib';

use Test::Unit::Lite;

Test::Unit::HarnessUnit->new->start('Test::Unit::Lite::AllTests');
