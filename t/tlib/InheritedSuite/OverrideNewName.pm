package InheritedSuite::OverrideNewName;

use strict;
use warnings;

use base qw(Test::Unit::TestSuite);

sub new {
  my $class = shift;
  my $self = $class->SUPER::empty_new();
  $self->add_test(Test::Unit::TestSuite->new('SuccessTest'));
  return $self;
}

sub name { 'Inherited suite overriding new() and name()' }

1;
