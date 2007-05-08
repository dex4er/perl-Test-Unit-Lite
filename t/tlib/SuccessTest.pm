package SuccessTest;

use strict;
use warnings;

use base 'Test::Unit::Lite::TestCase';

sub test_success {
  my $self = shift;
  $self->assert(1);
}

1;
