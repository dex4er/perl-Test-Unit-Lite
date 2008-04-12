#!/usr/bin/perl

use 5.006;
use Module::Build;

use strict;
use warnings;

my $build = Module::Build->new(
    module_name => 'Test::Unit::Lite',
    dist_author => 'Piotr Roszatycki <dexter@debian.org>',
    license => 'perl',
    requires => {
        'perl'               => 5.006,
    },
    optional => {
    },
    build_requires => {
    },
    create_makefile_pl => 'traditional',
    create_readme => 1,
    recursive_test_files => 1,
    add_to_cleanup => [
        'META.yml', '*.bak', '*.gz', '*.tgz', '*.ppd',
        'Makefile.PL', 'Makefile', 'pm_to_blib', 'README', 'cover_db',
	'Test-Unit-Lite-*',
    ],
);

$build->create_build_script;
