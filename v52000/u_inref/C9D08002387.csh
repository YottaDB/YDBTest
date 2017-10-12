#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9D08-002387 [Narayanan] VERMISMATCH error should be reported ahead of FILEIDGBLSEC,DBIDMISMATCH error
#
# -------------------------------------------------------------------------------------------------------
# Test that VERMISMATCH error is issued for shared memory created by a different version whether or not
# there are any processes (of the different version) actively accessing the shared memory.
# -------------------------------------------------------------------------------------------------------
#
# Randomly choose a prior version (to simulate a VERMISMATCH error).
set prior_ver = `$gtm_tst/com/random_ver.csh -type any`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
source $gtm_tst/com/ydb_temporary_disable.csh
echo "$prior_ver" > priorver.txt
\rm -f rand.o	# rand.o created by current version might have incompatible object format for older version in dbcreate.csh below

echo "Randomly chosen prior V5 version is : [$prior_ver]"
set linestr = "----------------------------------------------------------------------"
set newline = ""
echo $linestr
echo "# Switch to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
echo "# Start a background job that accesses the db and randomly choose to kill it"
echo $newline
$gtm_tst/com/dbcreate.csh mumps
\rm -f rand.o	# rand.o created by older version might have incompatible object format for newer version in case it is
		# accessed later in this script so be safe and delete it
setenv gtm_test_crash 1	# signal job.m to write script to kill the jobbed off child
$GTM << GTM_EOF
	do oldverstart^c002387
GTM_EOF

echo $linestr
echo "# Check if jobbed off child has to be killed (written to the file killchild.choice)"
echo "# If yes, kill the child and wait for it to die"
echo $newline
set killchild = `cat killchild.choice`
if ($killchild == 1) then
	set crashfile = "gtm_test_crash_jobs.csh"	# file that job.m would have written for crashing jobbed off child
	set childpid = `$tst_awk '{print $NF;exit;}' $crashfile`
	source $crashfile
	$gtm_tst/com/wait_for_proc_to_die.csh $childpid -1
endif
\rm -f c002387.o	# c002387.o created by older version might have incompatible object format for newer version and is better removed

echo $linestr
echo "# Switch to current version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
if ("$test_encryption" == "ENCRYPT") then
	if (-f $gtm_dbkeys) then
		$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
	else
		unsetenv gtm_passwd
		unsetenv gtmcrypt_config
	endif
endif
echo "# Start a foreground job that accesses the db using the new GT.M version"
echo "# Starting GT.M. Expect a VERMISMATCH error"
echo $newline
#Backup the prior version gld. Also upgrade the prior version gld to the new version gld. This is done because the encryption
#versions will have 106 as GDE label instead of 105. Not doing so will cause GDINVALID error instead of the expected VERMISMATCH error.
cp mumps.gld mumps_prior.gld >&! /dev/null
$GDE EXIT >&! /dev/null
$GTM << GTM_EOF
	do newver^c002387
GTM_EOF
echo $linestr
echo "# Starting LKE. Expect a VERMISMATCH error"
echo $newline
$LKE show -all
echo $linestr
echo "# Starting DSE. Expect a VERMISMATCH error"
echo $newline
$DSE crit -all >&! dse_crit_all.logx

set dbnoreg_not_found = 0
$grep "GTM-E-VERMISMATCH" dse_crit_all.logx
$grep "GTM-E-DBNOREGION" dse_crit_all.logx >& /dev/null
if ($status) set dbnoreg_not_found = 1

if ($dbnoreg_not_found) then
	echo "TEST-E-DSE Can not find DBNOREGION message."
	echo "Check dse_crit_all.logx"
endif
echo $linestr
echo "# Starting MUPIP BACKUP. Expect a VERMISMATCH error"
echo $newline
$MUPIP backup DEFAULT bakdir

echo $linestr
echo "# Switch back to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
#Here we switch back to the prior version. So, lets make use of the back'ed up gld here.
cp mumps_prior.gld mumps.gld
echo "# Stop background job and cleanup shared memory"
echo $newline
\rm -f c002387.o	# c002387.o created by current version might have incompatible object format for older version
$GTM << GTM_EOF >&! gtm_output.out
	do oldverstop^c002387
GTM_EOF

echo $linestr
echo "# Check database integs clean"
echo $newline
$gtm_tst/com/dbcheck.csh

# Clean up ftok semaphore which will be left around by $tst_ver from the VERMISMATCH errors above
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$GDE EXIT >&! /dev/null
$MUPIP rundown -file mumps.dat >& mupip_rundown.out
