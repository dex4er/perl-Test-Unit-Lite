#!/usr/bin/perl -c

package Test::Unit::Lite;
use 5.006;
our $VERSION = '0.02';

=head1 NAME

Test::Unit::Lite - Unit testing without external dependencies

=head1 SYNOPSIS

Bundling the L<Test::Unit::Lite> as a part of package distribution:

  perl -MTest::Unit::Lite -e bundle

Using as a replacement for Test::Unit:

  package FooBarTest;
  use Test::Unit::Lite;   # unnecessary if module isn't directly used
  use base qw(Test::Unit::TestCase);

  sub new {
      my $self = shift()->SUPER::new(@_);
      # your state for fixture here
      return $self;
  }

  sub set_up {
      # provide fixture
  }
  sub tear_down {
      # clean up after test
  }
  sub test_foo {
      my $self = shift;
      my $obj = ClassUnderTest->new(...);
      $self->assert_not_null($obj);
      $self->assert_equals('expected result', $obj->foo);
      $self->assert(qr/pattern/, $obj->foobar);
  }
  sub test_bar {
      # test the bar feature
  }

=head1 DESCRIPTION

This framework provides lighter version of L<Test::Unit> framework.  It
implements some of the L<Test::Unit> classes and methods needed to run test
units.  The L<Test::Unit::Lite> tries to be compatible with public API of
L<Test::Unit>. It doesn't implement all classes and methods at 100% and only
those necessary to run tests are available.

The L<Test::Unit::Lite> can be distributed as a part of package distribution,
so the package can be distributed without dependency on modules outside
standard Perl distribution.

=head2 Bundling the L<Test::Unit::Lite> as a part of package distribution

The L<Test::Unit::Lite> framework can be bundled to the package distribution.
Then the L<Test::Unit::Lite> module is copied to the F<inc> directory of the
source directory for the package distribution.

=cut


use strict;

use Exporter ();
use File::Spec ();
use File::Basename ();
use File::Copy ();
use File::Path ();


our @EXPORT = qw[bundle];


# Call import from Exporter
sub import {
    my $pkg = shift;
    my $callpkg = caller;
    Exporter::export($pkg, $callpkg, @_);
}


# Copy this module to inc subdirectory of the source distribution
sub bundle {
    -f 'Makefile.PL' or -f 'Build.PL'
        or die "Cannot find Makefile.PL or Build.PL in current directory\n";

    my $src = __FILE__;
    my $dst = "inc/Test/Unit/Lite.pm";


    my @src = split m"/", $src;
    my @dst = split m"/", $dst;
    my $srcfile = File::Spec->catfile(@src);
    my $dstfile = File::Spec->catfile(@dst);

    die "Cannot bundle to itself: $srcfile\n" if $srcfile eq $dstfile;
    print "Copying $srcfile -> $dstfile\n";

    my $dstdir = File::Basename::dirname($dstfile);

    -d $dstdir or File::Path::mkpath([$dstdir], 0, 0777 & ~umask);

    File::Copy::cp($srcfile, $dstfile) or die "Cannot copy $srcfile to $dstfile: $!\n";
}


1;


=head1 FUNCTIONS

=over

=item bundle

Copies L<Test::Unit::Lite> modules into F<inc> directory.  Creates missing
subdirectories if needed.  Silently overwrites previous module if was
existing.

=back

=head1 EXAMPLES

=head2 t/tlib/SuccessTest.pm

This is the simple unit test module.

  package SuccessTest;

  use strict;
  use warnings;

  use base 'Test::Unit::TestCase';

  sub test_success {
    my $self = shift;
    $self->assert(1);
  }

  1;

=head2 t/tlib/AllTests.pm

This is the test suite which calls all test cases located in F<t/tlib>
directory.

  package AllTests;

  use base 'Test::Unit::TestSuite';

  use File::Find ();
  use File::Basename ();
  use File::Spec ();

  sub new {
      return bless {}, shift;
  }

  sub suite {
      my $class = shift;
      my $suite = Test::Unit::TestSuite->empty_new("Tests");

      my $dir = (File::Basename::dirname(__FILE__));
      my $depth = scalar File::Spec->splitdir($dir);

      File::Find::find({
          wanted => sub {
              my $path = File::Spec->canonpath($File::Find::name);
              return unless $path =~ s/\.pm$//;
              my @path = File::Spec->splitdir($path);
              splice @path, 0, $depth;
              return unless scalar @path > 0;
              my $class = join '::', @path;
              return unless $class;
              return if $class =~ /^Test::Unit::/;
              return if @ARGV and $class !~ $ARGV[0];
              return unless eval "use $class; "
                  . "$class->isa('Test::Unit::TestCase');";
              $suite->add_test($class);
          },
          no_chdir => 1,
      }, $dir || '.');

      return $suite;
  }

  1;

=head2 t/all_tests.t

This is the test script for L<Test::Harness> called with "make test".

  #!/usr/bin/perl -w

  use strict;
  use lib 'inc', 't/tlib', 'tlib';  # inc is needed for bundled T::U::L

  use Test::Unit::Lite;  # load the Test::Unit replacement
  use Test::Unit::HarnessUnit;

  my $testrunner = Test::Unit::HarnessUnit->new();
  $testrunner->start("AllTests");

=head2 t/test.sh

This is the optional shell script for calling test suite directly.

  #!/bin/sh
  set -e
  cd `dirname $0`
  cd ..
  PERL=${PERL:-perl}
  find t/tlib -name '*.pm' -print | while read pm; do
      $PERL -Iinc -Ilib -It/tlib -MTest::Unit::Lite -c "$pm"
  done
  $PERL -w -Iinc -Ilib -It/tlib t/all_tests.t "$@"

=head1 SEE ALSO

L<Test::Unit>, L<Test::Unit::TestCase>, L<Test::Unit::TestSuite>,
L<Test::Unit::Assert>, L<Test::Unit::TestRunner>, L<Test::Unit::HarnessUnit>.

=head1 TESTS

The L<Test::Unit::Lite> was tested as a L<Test::Unit> replacement for following
distributions: L<Test::C2FIT>, L<XAO::Base>, L<Exception::Base>.

=head1 BUGS

If you find the bug or need new feature, please report it.

=head1 AUTHORS

Piotr Roszatycki E<lt>dexter@debian.orgE<gt>

=head1 LICENSE

Copyright 2007 by Piotr Roszatycki E<lt>dexter@debian.orgE<gt>.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut


package Test::Unit::TestCase;
use 5.006;
our $VERSION = $Test::Unit::Lite::VERSION;

our %Seen_Refs = ();
our @Data_Stack;
my $DNE = bless [], 'Does::Not::Exist';

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    my $self = {};
    return bless $self => $class;
}

sub set_up { }

sub tear_down { }

sub list_tests {
    my $self = shift;

    my $class = ref $self || $self;

    no strict 'refs';
    my @tests = sort grep { /^test_/ } keys %{$class.'::'};
    return wantarray ? @tests : [ @tests ];
}

sub __croak {
    my $message = shift;
    my $n = 1;

    my($file, $line) = (caller($n++))[1,2];
    my $caller;
    $n++ while (defined($caller = caller($n)) and $caller ne 'Test::Unit::TestSuite');

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

BEGIN { $INC{'Test/Unit/TestCase.pm'} = __FILE__; }

1;


package Test::Unit::TestSuite;
use 5.006;
our $VERSION = $Test::Unit::Lite::VERSION;

sub empty_new {
    my $class = shift;
    my $name = shift;
    my $self = {
        'name' => defined $name ? $name : 'Test suite',
        'units' => [],
    };

    return bless $self => $class;
}

sub new {
    my $class = shift;
    my $test = shift;

    my $self = {
        'name' => 'Test suite',
        'units' => [],
    };

    if (not ref $test) {
        eval "use $test;";
    }
    if (defined $test and $test->isa('Test::Unit::TestSuite')) {
        $class = ref $test ? ref $test : $test;
        $self->{name} = $test->{name} if ref $test;
        $self->{units} = $test->{units} if ref $test;
    }
    elsif (defined $test and $test->isa('Test::Unit::TestCase')) {
        $class = ref $test ? ref $test : $test;
        $self->{units} = [ $test->list_tests ];
    }
    else {
        require Carp;
        Carp::croak(sprintf("usage: %s->new([CLASSNAME | TEST])\n", __PACKAGE__));
    }

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

BEGIN { $INC{'Test/Unit/TestSuite.pm'} = __FILE__; }

1;


package Test::Unit::TestRunner;
use 5.006;
our $VERSION = $Test::Unit::Lite::VERSION;

sub new {
    my $class = shift;
    my $self = {
        'suite' => undef
    };
    return bless $self => $class;
}

sub start {
    my $self = shift;
    my $test = shift;

    eval "use $test;";
    die $@ if $@ ne '';

    if ($test->isa('Test::Unit::TestSuite')) {
        $self->{suite} = $test->suite;
    }
    elsif ($test->isa('Test::Unit::TestCase')) {
        $self->{suite} = Test::Unit::TestSuite->empty_new;
        $self->{suite}->add_test($test);
    }
    else {
        print "# skipping unknown test $test\n";
    }

    print "STARTING TEST RUN\n";
    printf "1..%d\n", $self->{suite}->count_test_cases;
    $self->{suite}->run;
}

BEGIN { $INC{'Test/Unit/TestRunner.pm'} = __FILE__; }

1;


package Test::Unit::HarnessUnit;
use 5.006;
our $VERSION = $Test::Unit::Lite::VERSION;

use base 'Test::Unit::TestRunner';

BEGIN { $INC{'Test/Unit/HarnessUnit.pm'} = __FILE__; }

1;


package Test::Unit::Debug;
use 5.006;
our $VERSION = $Test::Unit::Lite::VERSION;

BEGIN { $INC{'Test/Unit/Debug.pm'} = __FILE__; }

1;
