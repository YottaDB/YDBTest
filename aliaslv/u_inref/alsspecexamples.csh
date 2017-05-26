#!/usr/local/bin/tcsh -f
#
# Running the aliasing examples documented in the alias user spec. These examples
# are representative of many of the areas tested more thoroughly in other 
# tests but it was thought to make a single test of just the documentation
# examples.
#

# data base is not really used but needs to be present for TP restart testing
$gtm_tst/com/dbcreate.csh .
$gtm_dist/mumps -run ^specexamples
$gtm_tst/com/dbcheck.csh
