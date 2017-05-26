#! /usr/local/bin/tcsh -f
# The following programs do not access a database.
#
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
$gtm_tst/$tst/u_inref/per1831.csh
#
$GTM << xyz
Write "Do ^per2482",! Do ^per2482
Write "Do ^per2733",! Do ^per2733
Write "Do ^per2739",! Do ^per2739
Write "Do ^per2745",! Do ^per2745
Write "Do ^D000201",! Do ^D000201
h
xyz
#
# The following programs access the database
#
#$gtm_tst/com/dbcreate.csh .
#gtm << zyx
#;Write "Do ^per2601",! Do ^per2601
#Write "Do ^per2607f",! Do ^per2607f
#Write "Do ^per2607g",! Do ^per2607g
#h
#zyx
#$gtm_tst/com/dbcheck.csh
#
# The following are tests related to Journalling
#
#$shell $gtm_tst/$tst/u_inref/per1633.csh
#
$gtm_tst/$tst/u_inref/per2416.csh
#$gtm_tst/$tst/u_inref/per2607a.csh
rm *.dat
if ($?test_replic == 0) $tst_tcsh $gtm_tst/$tst/u_inref/per2422.csh
