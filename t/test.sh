cd $(dirname $0)
cd ..
PERL=${PERL:-perl}
find t/tlib -name '*.pm' -print | while read pm; do
    $PERL -Ilib -It/tlib -c "$pm"
done
$PERL -w -Ilib -It/tlib t/all_tests.t "$@"
