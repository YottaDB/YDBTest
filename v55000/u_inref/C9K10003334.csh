#!/usr/local/bin/tcsh -f
#
# Error thrown during job interrupt should not be rethrown after jobinterrupt frame
# resumes (C9K10-003334).
#
$gtm_tst/com/dbcreate.csh .
echo
echo "********* Test 1 ********"
$gtm_dist/mumps -run C9K10003334
#
echo
echo "********* Test 2 ********"
$gtm_dist/mumps -run C9K10003334b
#
$gtm_tst/com/dbcheck.csh
