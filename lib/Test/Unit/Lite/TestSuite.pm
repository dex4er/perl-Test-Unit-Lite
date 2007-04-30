#!/usr/bin/perl -c

package Test::Unit::Lite::TestSuite;

sub empty_new {
    my $class = shift;
    my $self = {
        'units' => [],
    };
    
    return bless $self => $class;
}

sub add_test {
    my $self = shift;
    my $unit = shift;

    eval "use $unit;";
    return push @{ $self->{units} }, $unit->new;
}

sub count_test_cases {
    my $self = shift;

    my $plan = 0;

    foreach my $unit (@{ $self->{units} }) {
        $plan += scalar @{ $unit->list_tests };
    }
    return $plan;
}

sub run {
    my $self = shift;

    foreach my $unit (@{ $self->{units} }) {
        $unit->set_up;
        foreach my $test (@{ $unit->list_tests }) {
            eval {
                $unit->$test;
            };
            if ("$@" eq '') {
                print "ok PASS $test\n";
            }
            else {
                print "\nnot ok ERROR $test\n", $@;
            }
        }
        $unit->tear_down;
    }
    return;
}

1;
