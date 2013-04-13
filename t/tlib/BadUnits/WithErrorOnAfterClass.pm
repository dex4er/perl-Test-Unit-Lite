package BadUnits::WithErrorOnAfterClass;

use strict;
use warnings;

use base 'Test::Unit::TestCase';

sub test_unit_with_after_class_error {
    my $self = shift;
    $self->assert(1);
}

sub after_class {
    die "Problem with after_class";
}

1;
