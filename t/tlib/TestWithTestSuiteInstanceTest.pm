package TestWithTestSuiteInstanceTest;

use strict;
use warnings;

package TestWithTestSuiteInstanceTest::Null::Tie;

sub TIEHANDLE {
    bless {}, shift;
}

sub PRINT {
}

sub PRINTF {
}

package TestWithTestSuiteInstanceTest;

use base 'Test::Unit::TestCase';

use Test::Unit::Lite;

sub test_init_test_runner_with_instance {
    my ($self) = @_;

    select select my $fh_null;
    tie *$fh_null, 'TestWithTestSuiteInstanceTest::Null::Tie';
    my $runner = Test::Unit::TestRunner->new($fh_null, $fh_null);
    my $suite = Test::Unit::TestSuite->empty_new;

    $runner->start($suite);

    my $runner_suite = $runner->suite;

    $self->assert(ref $runner_suite && $runner_suite->isa('Test::Unit::TestSuite'));
    $self->assert("$suite" eq "$runner_suite", "$suite vs $runner_suite");
}

1;
