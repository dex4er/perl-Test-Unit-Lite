#!/usr/bin/perl -c

package Test::Unit::Lite;
use 5.006;
our $VERSION = '0.01';

=head1 NAME

Test::Unit::Lite - Unit testing without external dependencies

=head1 SYNOPSIS

Bundling the L<Test::Unit::Lite> as a part of package distribution:

  perl -MTest::Unit::Lite -e bundle

=head1 DESCRIPTION

This framework provides lighter version of L<Test::Unit> framework.  It
implements some of the L<Test::Unit> classes and methods needed to run test
units.  The L<Test::Unit::Lite> tries to be compatible with public API of
L<Test::Unit> only.  The inside mechanisms are much simpler.

The L<Test::Unit::Lite> can be distributed as a part of package distribution,
so the package can be distributed without dependency on modules outside
standard Perl distribution.

=head2 Bundling the L<Test::Unit::Lite> as a part of package distribution

The L<Test::Unit::Lite> framework can be bundled to the package distribution. 
Then the L<Test::Unit::Lite> modules are copied to the F<inc> directory of
the source directory for the package distribution.

=cut


use strict;

use Exporter 'import';
use File::Spec ();
use File::Basename ();
use File::Copy ();
use File::Path ();


our @EXPORT = qw[bundle];


sub bundle {
    require Test::Unit::Lite::HarnessUnit;
    require Test::Unit::Lite::TestCase;
    require Test::Unit::Lite::TestSuite;
    
    foreach my $mod (grep { m"^Test/Unit/Lite/" } keys %INC) {
        my $src = $INC{$mod};
        my $dst = "inc/$mod";

        die "Cannot bundle to itself: $src\n" if $src eq $dst;

        my @src = split m"/", $src;
        my @dst = split m"/", $dst;
        my $srcfile = File::Spec->catfile(@src);
        my $dstfile = File::Spec->catfile(@dst);

        print "Copying $src -> $dst\n";

        my $dstdir = File::Basename::dirname($dstfile);
        
        -d $dstdir or File::Path::mkpath([$dstdir], 0, 0777 & ~umask);
        
        File::Copy::cp($src, $dst) or die "Cannot copy: $src: $!\n";
    }
}


1;


=head1 FUNCTIONS

=over

=item bundle

Copies L<Test::Unit::Lite> modules into F<inc> directory.

=back

=head1 EXAMPLES

=head2 t/tlib/SuccessTest.pm

This is the simple unit test module.

  package SuccessTest;
  
  use strict;
  use warnings;
  
  use base 'Test::Unit::Lite::TestCase';
  
  sub test_success {
    my $self = shift;
    $self->assert(1);
  }
  
  1;

=head2 t/tlib/AllTests.pm

This is the test suite which calls all test cases located in F<t/tlib>
directory.

  package AllTests;
  
  use Test::Unit::Lite::TestSuite;
  
  use File::Find ();
  use File::Basename ();
  use File::Spec ();
  
  sub new {
      return bless {}, shift;
  }
  
  sub suite {
      my $class = shift;
      my $suite = Test::Unit::Lite::TestSuite->empty_new("Tests");
  
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
              return if $class =~ /^Test::Unit::Lite::/;
              return if @ARGV and $class !~ $ARGV[0];
              return unless eval "use $class; "
                  . "$class->isa('Test::Unit::Lite::TestCase');";
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
  
  use lib 'inc', 't/tlib', 'tlib';
  
  use Test::Unit::Lite::HarnessUnit;
  
  my $testrunner = Test::Unit::Lite::HarnessUnit->new();
  $testrunner->start("AllTests");

=head2 t/test.sh

This is the optional shell script for calling test suite directly.

  #!/bin/sh
  set -e
  cd `dirname $0`
  cd ..
  PERL=${PERL:-perl}
  find t/tlib -name '*.pm' -print | while read pm; do
      $PERL -Ilib -It/tlib -c "$pm"
  done
  $PERL -w -Ilib -It/tlib t/all_tests.t "$@"

=head1 AUTHORS

Piotr Roszatycki E<lt>dexter@debian.orgE<gt>

=head1 LICENSE

Copyright 2007 by Piotr Roszatycki E<lt>dexter@debian.orgE<gt>.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>
