#!/usr/local/bin/tcsh -f
#
# Testing xnew scenarios with aliasing
#

# data base is not really used but needs to be present for TP restart testing in conjunction with XNEW
$gtm_tst/com/dbcreate.csh .
$gtm_dist/mumps -run ^xnewtests
$gtm_tst/com/dbcheck.csh
