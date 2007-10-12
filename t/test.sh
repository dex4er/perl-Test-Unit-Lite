#!/bin/sh
set -e
cd `dirname $0`
cd ..
PERL=${PERL:-perl}
find t/tlib -name '*Test.pm' -print | while read pm; do
    $PERL -Ilib -It/tlib -MTest::Unit::Lite -c "$pm"
done
$PERL -w -Ilib -It/tlib t/all_tests.t "$@"
