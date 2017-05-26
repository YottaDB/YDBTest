#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$MULTISITE_REPLIC_PREPARE 2

$gtm_tst/com/dbcreate.csh mumps 1

$MSR START INST1 INST2
echo '# Update 3 globals in to primary'
$gtm_exe/mumps -run %XCMD 'set (^x,^y,^z)=1'
$MSR SYNC INST1 INST2

echo '# Stop receviver server'
$MSR STOPRCV INST1 INST2

echo '# Update 2 globals in to primary'
$gtm_exe/mumps -run %XCMD 'set (^a,^b)=1'
$MSR SHOWBACKLOG INST1 INST2 SRC
echo '# Shutdown source server using timeout or zerobacklog'
$MSR RUN SRC=INST1 '$MUPIP replicate -source -shutdown -timeout=10 -zerobacklog' >>& shutdown1.log
$MSR REFRESHLINK INST1 INST2
$grep "Shutting down with a backlog due to timeout" shutdown1.log
$MSR START INST1 INST2
$MSR SYNC INST1 INST2
echo '# Shutdown source server using timeout or zerobacklog'
set timebefore = `date +%s`
$MSR RUN SRC=INST1 '$MUPIP replicate -source -shutdown -timeout=180 -zerobacklog' >>& shutdown2.log
set timeafter = `date +%s`
$grep "Shutting down with zero backlog" shutdown2.log
@ totaltime = $timeafter - $timebefore
if ( $totaltime >= 180 ) then
	echo "SHUTDOWN-E-ZEROBACKLOG : source server shutdown seemed to have waited for timeout despite zero backlog and passing -zerobacklog"
endif
$MSR REFRESHLINK INST1 INST2

$gtm_tst/com/dbcheck.csh -extract
