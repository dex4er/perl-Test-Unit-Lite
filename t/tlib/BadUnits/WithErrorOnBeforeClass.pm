package BadUnits::WithErrorOnBeforeClass;

use strict;
use warnings;

use base 'Test::Unit::TestCase';

sub before_class {
    die "Problem with before_class";
}

sub test_unit_with_before_class_error {
    my $self = shift;
    $self->assert(1);
}

1;
