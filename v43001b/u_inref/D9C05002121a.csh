#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "==================================================================="
echo "The temporary file should go to /tmp for non-file backups:"
$MUPIP backup -nonew -o -nettimeout=120 -i -t=1 -dbg DEFAULT "tcp://`hostname`:6200"
$MUPIP integ -reg "*" >& integ.log
echo "==================================================================="
echo "try a bad gtm_baktmpdir:"
setenv gtm_baktmpdir junkdir
$MUPIP backup -nonew -o "*" ./bak -dbg
$MUPIP integ -noonline -reg "*" >>& integ.log
unsetenv gtm_baktmpdir
echo "==================================================================="
echo "Try a relative pathname for mupip (mumps and mupip called from different directories):"
$gtm_tst/$tst/u_inref/gtmmnset.csh  >& gtmmnset.out
echo "Give it some time..."
$gtm_tst/com/wait_for_log.csh -log job.txt -waitcreation -duration 120
# at this point job.txt should have exist and have non-zero pid written into it.
set pid = `cat job.txt`

cd bak

# the following commands can be run simultaneously as well
$gtm_tst/$tst/u_inref/D9C05002121b.csh
if ($status != 0) then
	echo "D9C05002121b.csh invocation errored out. Exiting"
	exit -1
endif
if ($?test_replic) then
	# Note: Need to setenv gtmgbldir below to point to secondary side as otherwise we would get an EXDEV error
	# from "copy_file_range()" (invoked by "mupip backup" which is run a lot inside D9C05002121b.csh). It would
	# translate to the below user-visible error.
	#	%YDB-I-TEXT, Error occurred during the copy phase of MUPIP BACKUP
	#	%YDB-I-TEXT, Error code: 18, Invalid cross-device link
	#	%YDB-E-MUNOFINISH, MUPIP unable to finish all requested actions
	$sec_shell "$sec_getenv; cd $SEC_SIDE/bak; setenv gtmgbldir $SEC_SIDE/mumps.gld; $gtm_tst/$tst/u_inref/D9C05002121b.csh > ../D9C05002121b.out"
	echo "And on the secondary side:"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; cat D9C05002121b.out"
endif

$MUPIP stop $pid
set waittime = 60
$gtm_tst/com/wait_for_proc_to_die.csh $pid $waittime # 60 second wait
if ($status != 0) then
	#still alive
	echo "TEST-E-Process did not die in the time given ($waittime seconds)"
endif
echo "==================================================================="
