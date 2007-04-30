#!/usr/bin/perl -c

package Test::Unit::Lite::HarnessUnit;

sub new {
    my $class = shift;
    my $self = {
        'suite' => undef
    };
    return bless $self => $class;
}

sub start {
    my $self = shift;
    my $suite = shift;
    
    eval "use $suite;";
    die $@ if $@ ne '';

    $self->{suite} = $suite->suite;

    print "STARTING TEST RUN\n";
    printf "1..%d\n", $self->{suite}->count_test_cases; 
    $self->{suite}->run;
}

1;
