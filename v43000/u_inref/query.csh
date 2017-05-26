#!/usr/local/bin/tcsh
$gtm_tst/com/dbcreate.csh second
setenv gtmgbldir second.gld
$gtm_tst/com/dbcheck.csh
mkdir datbak
mv second.dat second.gld datbak/
$gtm_tst/com/dbcreate.csh first
setenv gtmgbldir first.gld
mv datbak/* .
$gtm_exe/mumps -run query 
$gtm_tst/com/dbcheck.csh
