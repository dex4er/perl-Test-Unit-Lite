#!/usr/bin/perl

use strict;
use warnings;

use lib 'inc', 'lib';

use Test::Unit::Lite;

local $SIG{__WARN__} = sub { require Carp; Carp::confess("Warning: $_[0]") };

Test::Unit::HarnessUnit->new->start('Test::Unit::Lite::AllTests');
