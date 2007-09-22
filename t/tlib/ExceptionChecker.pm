package ExceptionChecker;

use strict;
use warnings;

sub check_failures {
    my ($self, @tests) = @_;
    while (@tests) {
        my $expected        = shift @tests;
        my $test_components = shift @tests;
        my ($test_code_line, $test) = @$test_components;
	eval {
	    $self->$test();
	};
	my $exception = $@;

        # Parse the exception message: get number of file source line
        # and last line of message
        #
        # t/tlib/AssertTest.pm:223 - AssertTest(test_fail_assert_not_equals)
        # 0 and 0 should be differ
        # customised message
        if ($exception ne '' and $exception =~ /^.*:(\d+) - (?:.*\n)?(.*)\n/s) {
            my ($line, $message) = ($1, $2);

#warn "<<$message>><<$expected>>";
            if ($line != $test_code_line or 
                   (ref $expected eq 'Regexp' and $message !~ /$expected/ or
                    ref $expected ne 'Regexp' and $message ne $expected))
            {
                $self->fail($exception);
            }
        }
    }
}

1;