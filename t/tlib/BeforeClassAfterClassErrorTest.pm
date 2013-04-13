package BeforeClassAfterClassErrorTest;

use strict;
use warnings;

package BeforeClassAfterClassErrorTest::Null::Tie;

sub TIEHANDLE {
    bless {}, shift;
}

sub PRINT {
}

package BeforeClassAfterClassErrorTest;

use base 'Test::Unit::TestCase';

use Test::Unit::Lite;

sub test_suite_with_error_on_before_class {
    my $self = shift;
    select select my $fh_null;
    tie *$fh_null, 'BeforeClassAfterClassErrorTest::Null::Tie';
    my $runner = Test::Unit::TestRunner->new($fh_null, $fh_null);
    eval {
        $runner->start('BadUnits::WithErrorOnBeforeClass');
    };
    $self->assert(qr/^Problem with before_class/s, "$@");
}

sub test_suite_with_error_on_after_class {
    my $self = shift;
    select select my $fh_null;
    tie *$fh_null, 'BeforeClassAfterClassErrorTest::Null::Tie';
    my $runner = Test::Unit::TestRunner->new($fh_null, $fh_null);
    eval {
        $runner->start('BadUnits::WithErrorOnAfterClass');
    };
    $self->assert(qr/^Problem with after_class/s, "$@");
}

1;
