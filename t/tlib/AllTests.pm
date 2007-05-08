package AllTests;

use base 'Test::Unit::TestSuite';

use File::Find ();
use File::Basename ();
use File::Spec ();

sub suite {
    my $class = shift;
    my $suite = Test::Unit::TestSuite->empty_new("Framework Tests");

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
            return unless eval "use $class; $class->isa('Test::Unit::TestCase');";
            $suite->add_test($class);
        },
        no_chdir => 1,
    }, $dir || '.');

    return $suite;
}

1;
