#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2007, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo ENTERING C9H04002843 Testing of socket READ \*
setenv gtmgbldir mumps.gld
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
$gtm_tst/com/dbcreate.csh mumps
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << setupconfiguration
s ^config("hostname")="$randhost"
s ^config("portno")=$portno
h
setupconfiguration

$gtm_dist/mumps -run socrdone >&! socrdone.out
$grep -vE '^$' socrdone.out

sleep 5
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING C9H04002843 Testing of socket READ \*
