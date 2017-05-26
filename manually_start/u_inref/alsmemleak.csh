#!/usr/local/bin/tcsh -f
#
# Testing for aliasing memory leaks by testing heavy rev long running flavor
# of the aliaslv tptests.m test.
#

# Data base is not really used but needs to be present for TP restart testing
$gtm_tst/com/dbcreate.csh .

# Fetch current version of test from aliaslv suite
cp $gtm_tst/aliaslv/inref/tptests.m .
$gtm_dist/mumps -run autolvgc^tptests

$gtm_tst/com/dbcheck.csh
