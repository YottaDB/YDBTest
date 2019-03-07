#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#shmsemremlog: 	Test if removed shared memory ID and semaphore ID is logged in
#		operator log.

set syslog_before = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << GTM_EOF
	set ^x=1
	zsy "dse all -buff"
	zsy "$kill9 "_\$j
GTM_EOF

#Get the shared memory ID and semaphore ID from database file
set semid = `$gtm_exe/mupip ftok mumps.dat | $tst_awk '/mumps/ {print $3}'`
set shmid = `$gtm_exe/mupip ftok mumps.dat | $tst_awk '/mumps/ {print $6}'`

$MUPIP rundown -region "*" >&! rundown.txt
#Check if the removal of semaphore is logged in the operator log.
$gtm_tst/com/getoper.csh "$syslog_before" "" "semid.txt" "" "Semaphore id $semid removed from the system"
if (  $status == 0 ) then
        echo "Semaphore id $semid removed successfully"
endif

$grep -E "YDB-I-SEMREMOVED, Semaphore id $semid removed from the system"
if ( $status == 0 ) then
	echo "ERROR: semid removal message should not present MUPIP RUNDOWN output"
endif

#Check if the removal of shared memory is logged in the operator log.
$grep -E "SHMREMOVED.* id $shmid " rundown.txt
if ($status != 0) then
        echo "No SHMREMOVED message found for shmid = $shmid"
endif
$gtm_tst/com/ipcs -m | $tst_awk '{print $2}' | $grep -w $shmid
if (  $status == 0 ) then
        echo "ipcs -a output still shows shmid = $shmid existing"
endif

$gtm_tst/com/dbcheck.csh
