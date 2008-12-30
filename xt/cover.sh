cd $(dirname $0)
cd ..
perl Makefile.PL
cover -delete
HARNESS_PERL_SWITCHES=-MDevel::Cover make test
cover
