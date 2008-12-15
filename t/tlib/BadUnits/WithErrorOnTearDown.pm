package BadUnits::WithErrorOnTearDown;

use strict;
use warnings;

use base qw(Test::Unit::TestCase);

sub tear_down {
    die "Problem with tear_down";
}

sub test_unit_with_error {
    my $self = shift;
    $self->assert(0);
}

1;
