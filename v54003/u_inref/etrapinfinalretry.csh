#!/usr/local/bin/tcsh -f
# Test that an Error Trap which does DB actions (GET / SET) can cause one or more
# restarts even when in a final retry. These restarts should be treated as if
# they happened in the penultimate retry (normal operation of code). We should
# not see any asserts or other issues.
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run etrapinfinalretry
$gtm_tst/com/dbcheck.csh -extract
