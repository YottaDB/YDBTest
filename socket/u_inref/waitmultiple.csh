#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo ENTERING SOCKET WAITMULTIPLE
setenv gtmgbldir mumps.gld
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
$gtm_tst/com/dbcreate.csh mumps 1 125 500 >& dbcreate_detail.out
source $gtm_tst/com/portno_acquire.csh >>& portno2.out
setenv portno2 $portno
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF >& config.out
s ^config("hostname")="$randhost"
s ^config("delim")=\$C(65)
s ^config("portno")=$portno
s ^config("portno2")=$portno2
h
EOF
$gtm_exe/mumps -r waitmultiple
$gtm_tst/com/portno_release.csh
cp portno2.out portno.out
$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh saveip "mumps.dat *.out *.err" mv
echo now with LOCAL sockets so recreate database
$MUPIP create
$GTM << EOF >& config.out
s ^config("hostname")="LOCAL"
s ^config("delim")=\$C(65)
s ^config("portno")="local1.sock"
s ^config("portno2")="local2.sock"
h
EOF
$gtm_exe/mumps -r waitmultiple
echo LEAVING SOCKET WAITMULTIPLE
$gtm_tst/com/dbcheck.csh
