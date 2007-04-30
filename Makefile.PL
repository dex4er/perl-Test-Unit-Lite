#!/usr/bin/perl
use ExtUtils::MakeMaker;
use strict;

WriteMakefile (
    NAME            => 'Test::Unit::Lite',
    VERSION_FROM    => 'lib/Test/Unit/Lite.pm', # finds $VERSION
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    PMLIBDIRS       => [ 'lib' ],
    PREREQ_PM       => {
    },
    AUTHOR          => 'Piotr Roszatycki <dexter@debian.org>',
    ABSTRACT        => 'Unit testing without external dependencies',
    NO_META         => 1,
);
