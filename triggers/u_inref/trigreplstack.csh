#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run trigreplstack
$gtm_tst/com/dbcheck.csh -extract
# When we use $STACK to drop one level below the trigger frame, on the primary
# we see the parent routine that drove the trigger.  On the secondary, we see
# the parent mupip dummy-frame of the update process that is driving the trigger.
# This difference is expected and this test merely documents this case
diff {pri,sec}_*.glo | $grep -E '^(<|>)'
