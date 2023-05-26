#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
echo '# Shutdown source server using -ZEROBACKLOG -timeout=10 (less than heartbeat period of 15) while receiver server is DOWN'
# Use .outx below to avoid framework from catching the error messages that we expect to see.
$MSR RUN SRC=INST1 '$MUPIP replicate -source -shutdown -timeout=10 -zerobacklog >>& shutdown1.outx'
$MSR REFRESHLINK INST1 INST2
echo "# Expect REPLNORESP/SHUT2QUICK/REPLBACKLOG messages in shutdown output the first time (shutdown1.outx)"
echo "# This is expected because the receiver server is down and there is a non-zero backlog"
cat shutdown1.outx | sed 's/.* : //g'	# the sed strips out the timestamp part (non-deterministic part)
$MSR START INST1 INST2
$MSR SYNC INST1 INST2
echo '# Shutdown source server using -ZEROBACKLOG -timeout=180 (more than heartbeat period of 15) while receiver server is UP'
set timebefore = `date +%s`
$MSR RUN SRC=INST1 '$MUPIP replicate -source -shutdown -timeout=180 -zerobacklog' >>& shutdown2.out
echo "# Expect no error messages in shutdown output the second time (shutdown2.out)"
cat shutdown2.out | sed 's/.* : //g'	# the sed strips out the timestamp part (non-deterministic part)
set timeafter = `date +%s`
@ totaltime = $timeafter - $timebefore
if ( $totaltime >= 180 ) then
	echo "SHUTDOWN-E-ZEROBACKLOG : source server shutdown seemed to have waited for timeout despite zero backlog and passing -zerobacklog"
endif
$MSR REFRESHLINK INST1 INST2

$gtm_tst/com/dbcheck.csh -extract
