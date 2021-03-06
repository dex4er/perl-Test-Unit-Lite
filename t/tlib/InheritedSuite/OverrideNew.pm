package InheritedSuite::OverrideNew;

use strict;
use warnings;

use base qw(Test::Unit::TestSuite);

sub new {
  my $class = shift;
  my $self = $class->SUPER::empty_new('Inherited suite overriding new()');
  $self->add_test(Test::Unit::TestSuite->new('SuccessTest'));
  return $self;
}

1;
