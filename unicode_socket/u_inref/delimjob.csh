#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
$switch_chset UTF-8
echo ENTERING SOCKET DELIMJOB
#
setenv gtmgbldir mumps.gld
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
$gtm_tst/com/dbcreate.csh mumps
source $gtm_tst/com/portno_acquire.csh  >>& portno.out
$GTM << EOF
do ^delimjob("$tst_org_host",$portno)
h
EOF
#
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET DELIMJOB
