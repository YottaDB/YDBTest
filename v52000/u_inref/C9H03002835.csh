#! /usr/local/bin/tcsh -f
echo ENTERING C9H03002835 Testing of MOREREADTIME socket device parameter
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << setupconfiguration
s ^config("hostname")="$tst_org_host"
s ^config("portno")=$portno
h
setupconfiguration

$gtm_dist/mumps -run tsockmrt >&! tsockmrt.out
$grep -vE '^$' tsockmrt.out

sleep 5
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING C9H03002835 Testing of MOREREADTIME socket device parameter
