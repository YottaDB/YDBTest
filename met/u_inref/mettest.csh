#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1 210 900 1024 4000 64
setenv gtmgbldir "./mumps.gld"

if ( $LFE == "L" ) then
	setenv reruns 1
else
	setenv reruns 100
endif

@ currun = 1
@ stoptest = 0
$gtm_exe/mumps -run dtinit^mettest
cp mumps.dat dtinit.dat
echo ""
while ($currun <= $reruns)
	setenv gtm_test_jobid $currun	# to pass to drive.m which in turn uses job.m
	cp dtinit.dat mumps.dat
	$gtm_exe/mumps -run drive^mettest
	#----------------------------------------------------------------------------
	# Do all sorts of checks before starting the next iteration of GT.M updates.
	#----------------------------------------------------------------------------
	if (-e checkdb_err_$currun.txt) then
		echo "FAIL $currun - Application level check (checkdb^mettest) failed. Details follow. Exiting..."
		cat checkdb_err_$currun.txt
		@ stoptest = 1
	endif

	# In case %YDBPROCSTUCKEXEC was invoked in the above "mumps -run drive^mettest" call, we need to
	# wait for potentially jobbed off DSE processes before doing a "mupip integ" that requires standalone access.
	# Hence the below call.
	$gtm_tst/com/wait_for_ydbprocstuckexec_jobbed_pids.csh

	$gtm_exe/mupip integ mumps.dat >>&! integ_report.$currun
	grep "No errors detected by integ." integ_report.$currun | sed 's/^/PASS '$currun' - /g'
	if ( $status != 0) then
		echo "FAIL $currun - Detailed integ report follows. Exiting..."
		cat integ_report.$currun
		@ stoptest = 1
	endif

	set corelistfile = "CORE_list.$currun"	# name CORE chosen instead of core to skip "core*" detection
	find . -type f -a \( -name 'core*' -o -name 'gtmcore*' \) -print >& $corelistfile
	if !(-z $corelistfile) then
		echo "FAIL $currun - Core file(s) found. List follows. Exiting..."
		cat $corelistfile
		@ stoptest = 1
	else
		rm -f $corelistfile
	endif

	foreach file (*${gtm_test_jobid}.mje*)
		if !(-z $file) then
			echo "FAIL $currun - *.mje* file(s) found. List follows. Exiting..."
			cat *${gtm_test_jobid}.mje*
			@ stoptest = 1
			break
		endif
	end

	if (0 != $stoptest) then
		cp mumps.dat mumps_$currun.dat
		exit -1
	else
		rm -f *${gtm_test_jobid}.mj* integ_report.$currun
	endif
	@ currun = $currun + 1
end
echo ""
$gtm_tst/com/dbcheck.csh
echo "PASS from MET test"
