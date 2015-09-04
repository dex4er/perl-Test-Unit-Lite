package BeforeClassTest;

use strict;
use warnings;

use base 'Test::Unit::TestCase';

my $assert_var;

sub before_class {
	my ($self) = @_;
	$assert_var = 1;
}

sub test_before_class {
	my ($self) = @_;
	$self->assert($assert_var);
}

1;
