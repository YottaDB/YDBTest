#!/usr/local/bin/tcsh -f
# the zsystem updates are replicated separately to the secondary. But that
# means the restart behavior will not be reproduced on the secondary because
# the conflicting update will all have happened BEFORE the TP transaction on
# the secondary. Which means the update process will NOT hit the TPNOTACID
# issue and so will behave differently from the primary. 
setenv gtm_tpnotacidtime 0
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run zsyconflict
$gtm_tst/com/dbcheck.csh -extract
