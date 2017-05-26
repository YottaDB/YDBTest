#! /usr/local/bin/tcsh -f
echo "Test for query() for local variables"
set GTM = "$gtm_exe/mumps -dir"
echo "========================================"
echo "With standard null collation"
$GTM << \aa
view "YLCT":-1:1
d numeric^lvquery
d string^lvquery
d mixed^lvquery
\aa
echo "========================================"
echo "With GTM null collation"
$GTM << \aa
d numeric^lvquery
d string^lvquery
d mixed^lvquery
\aa
echo "End of test"

