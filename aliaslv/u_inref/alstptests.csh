#!/usr/local/bin/tcsh -f
#
# Testing TP restart save/restore of local vars in an aliasing environment
#

# data base is not really used but needs to be present for TP restart testing
$gtm_tst/com/dbcreate.csh .
$gtm_dist/mumps -run ^tptests
$gtm_tst/com/dbcheck.csh
