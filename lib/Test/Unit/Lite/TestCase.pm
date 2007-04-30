#!/usr/bin/perl -c

package Test::Unit::Lite::TestCase;

sub new {
    my $class = shift;
    my $self = {};
    return bless $self => $class;
}

sub set_up { }

sub tear_down { }

sub list_tests {
    my $self = shift;

    my $class = ref $self || $self;

    my @tests = grep { /^test_/ } keys %{$class.'::'};
    return wantarray ? @tests : [ @tests ];
}

sub __croak {
    my $message = shift;
    my $n = 1;

    my($file, $line) = (caller($n++))[1,2];
    my $caller;
    $n++ while (defined($caller = caller($n)) and $caller ne 'Test::Unit::Lite::TestSuite');

    my $sub = (caller($n))[3];
    $sub =~ /^(.*)::([^:]*)$/;
    my($test, $unit) = ($1, $2);

    die sprintf "%s:%s - %s(%s)\n%s\n", $file, $line, $test, $unit, $message;
}

sub assert {
    my $self = shift;
    my $arg1 = shift;
    if (ref $arg1 eq 'Regexp') {
        my $arg2 = shift;
        __croak "$arg2 didn't match /$arg1/" unless $arg2 =~ $arg1;
    }
    else {
        __croak unless $arg1;
    }
}

sub assert_null {
    my $self = shift;
    my $arg = shift;
    __croak "$arg is defined" unless not defined $arg;
}

sub assert_not_null {
    my $self = shift;
    my $arg = shift;
    __croak "<undef> unexpected" unless defined $arg;
}

sub assert_equals {
    my $self = shift;
    my $arg1 = shift;
    __croak "expected value was undef; should be using assert_null?" unless defined $arg1;
    my $arg2 = shift;
    __croak "expected '$arg1', got undef" unless defined $arg2;
    if ($arg1 =~ /^([+-]?(\d+\.\d+|\d+\.|\.\d+|\d+)([eE][+-]?\d+)?)?$/ and
        $arg2 =~ /^([+-]?(\d+\.\d+|\d+\.|\.\d+|\d+)([eE][+-]?\d+)?)?$/)
    {
        local $^W;
        __croak "expected $arg1, got $arg2" unless $arg1 == $arg2;
    }
    else {
        __croak "expected '$arg1', got '$arg2'" unless $arg1 eq $arg2;
    }
}

sub assert_not_equals {
    my $self = shift;
    my $arg1 = shift;
    __croak "expected value was undef; should be using assert_null?" unless defined $arg1;
    my $arg2 = shift;
    __croak "expected '$arg1', got undef" unless defined $arg2;
    if ($arg1 =~ /^([+-]?(\d+\.\d+|\d+\.|\.\d+|\d+)([eE][+-]?\d+)?)?$/ and
        $arg2 =~ /^([+-]?(\d+\.\d+|\d+\.|\.\d+|\d+)([eE][+-]?\d+)?)?$/)
    {
        local $^W;
        __croak "$arg1 and $arg2 should be differ" unless $arg1 != $arg2;
    }
    else {
        __croak "'$arg1' and '$arg2' should be differ'" unless $arg1 ne $arg2;
    }
}

sub assert_num_equals {
    my $self = shift;
    my $arg1 = shift;
    __croak "expected value was undef; should be using assert_null?" unless defined $arg1;
    my $arg2 = shift;
    __croak "expected '$arg1', got undef" unless defined $arg2;
    local $^W;
    __croak "expected $arg1, got $arg2" unless $arg1 == $arg2;
}

sub assert_num_not_equals {
    my $self = shift;
    my $arg1 = shift;
    __croak "expected value was undef; should be using assert_null?" unless defined $arg1;
    my $arg2 = shift;
    __croak "expected '$arg1', got undef" unless defined $arg2;
    local $^W;
    __croak "$arg1 and $arg2 should be differ" unless $arg1 != $arg2;
}

sub assert_str_equals {
    my $self = shift;
    my $arg1 = shift;
    __croak "expected value was undef; should be using assert_null?" unless defined $arg1;
    my $arg2 = shift;
    __croak "expected '$arg1', got undef" unless defined $arg2;
    __croak "expected '$arg1', got '$arg2'" unless $arg1 eq $arg2;
}

sub assert_str_not_equals {
    my $self = shift;
    my $arg1 = shift;
    __croak "expected value was undef; should be using assert_null?" unless defined $arg1;
    my $arg2 = shift;
    __croak "expected '$arg1', got undef" unless defined $arg2;
    __croak "'$arg1' and '$arg2' should be differ'" unless $arg1 ne $arg2;
}

sub assert_matches {
    my $self = shift;
    my $arg1 = shift;
    __croak "arg 1 to assert_matches() must be a regexp" unless ref $arg1 eq 'Regexp';
    my $arg2 = shift;
    __croak "$arg2 didn't match /$arg1/" unless $arg2 =~ $arg1;
}

sub assert_does_not_match {
    my $self = shift;
    my $arg1 = shift;
    __croak "arg 1 to assert_does_not_match() must be a regexp" unless ref $arg1 eq 'Regexp';
    my $arg2 = shift;
    __croak "$arg2 matched /$arg1/" unless $arg2 !~ $arg1;
}

sub assert_deep_equals {
    my $self = shift;
    my $arg1 = shift;
    my $arg2 = shift;

    __croak 'Both arguments were not references' unless ref $arg1 and ref $arg2;

    local @Data_Stack = ();
    local %Seen_Refs = ();
    __croak $self->_format_stack(@Data_Stack) unless $self->_deep_check($arg1, $arg2);
}

sub _deep_check {
    my $self = shift;
    my ($e1, $e2) = @_;

    if ( ! defined $e1 || ! defined $e2 ) {
        return 1 if !defined $e1 && !defined $e2;
        push @Data_Stack, { vals => [$e1, $e2] };
        return 0;
    }

    return 1 if $e1 eq $e2;
    if ( ref $e1 && ref $e2 ) {
        my $e2_ref = "$e2";
        return 1 if defined $Seen_Refs{$e1} && $Seen_Refs{$e1} eq $e2_ref;
        $Seen_Refs{$e1} = $e2_ref;
    }

    if (ref $e1 eq 'ARRAY' and ref $e2 eq 'ARRAY') {
        return $self->_eq_array($e1, $e2);
    }
    elsif (ref $e1 eq 'HASH' and ref $e2 eq 'HASH') {
        return $self->_eq_hash($e1, $e2);
    }
    elsif (ref $e1 eq 'REF' and ref $e2 eq 'REF') {
        push @Data_Stack, { type => 'REF', vals => [$e1, $e2] };
        my $ok = $self->_deep_check($$e1, $$e2);
        pop @Data_Stack if $ok;
        return $ok;
    }
    elsif (ref $e1 eq 'SCALAR' and ref $e2 eq 'SCALAR') {
        push @Data_Stack, { type => 'REF', vals => [$e1, $e2] };
        return $self->_deep_check($$e1, $$e2);
    }
    else {
        push @Data_Stack, { vals => [$e1, $e2] };
        return 0;
    }
}

sub _eq_array  {
    my $self = shift;
    my($a1, $a2) = @_;
    return 1 if $a1 eq $a2;

    my $ok = 1;
    my $max = $#$a1 > $#$a2 ? $#$a1 : $#$a2;
    for (0..$max) {
        my $e1 = $_ > $#$a1 ? $DNE : $a1->[$_];
        my $e2 = $_ > $#$a2 ? $DNE : $a2->[$_];

        push @Data_Stack, { type => 'ARRAY', idx => $_, vals => [$e1, $e2] };
        $ok = $self->_deep_check($e1,$e2);
        pop @Data_Stack if $ok;

        last unless $ok;
    }
    return $ok;
}

sub _eq_hash {
    my $self = shift;
    my($a1, $a2) = @_;
    return 1 if $a1 eq $a2;

    my $ok = 1;
    my $bigger = keys %$a1 > keys %$a2 ? $a1 : $a2;
    foreach my $k (keys %$bigger) {
        my $e1 = exists $a1->{$k} ? $a1->{$k} : $DNE;
        my $e2 = exists $a2->{$k} ? $a2->{$k} : $DNE;

        push @Data_Stack, { type => 'HASH', idx => $k, vals => [$e1, $e2] };
        $ok = $self->_deep_check($e1, $e2);
        pop @Data_Stack if $ok;

        last unless $ok;
    }

    return $ok;
}

sub _format_stack {
    my $self = shift;
    my @Stack = @_;

    my $var = '$FOO';
    my $did_arrow = 0;
    foreach my $entry (@Stack) {
        my $type = $entry->{type} || '';
        my $idx  = $entry->{'idx'};
        if( $type eq 'HASH' ) {
            $var .= "->" unless $did_arrow++;
            $var .= "{$idx}";
        }
        elsif( $type eq 'ARRAY' ) {
            $var .= "->" unless $did_arrow++;
            $var .= "[$idx]";
        }
        elsif( $type eq 'REF' ) {
            $var = "\${$var}";
        }
    }

    my @vals = @{$Stack[-1]{vals}}[0,1];
    
    my @vars = ();
    ($vars[0] = $var) =~ s/\$FOO/  \$a/;
    ($vars[1] = $var) =~ s/\$FOO/  \$b/;

    my $out = "Structures begin differing at:\n";
    foreach my $idx (0..$#vals) {
        my $val = $vals[$idx];
        $vals[$idx] = !defined $val ? 'undef' 
                                    : "'$val'";
    }

    $out .= "$vars[0] = $vals[0]\n";
    $out .= "$vars[1] = $vals[1]\n";

    return $out;
}

1;
