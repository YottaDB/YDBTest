#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Lack permissions to write to the $ydb_dist directory, so we are creating a temp directory
# and copying all files from $ydb_dist to temp, changing the ydb_dist environment variable
# and putting restrict.txt in temp

source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
cat > $ydb_dist/restrict.txt << EOF
ZHALT
HALT
EOF
chmod -w $ydb_dist/restrict.txt

# Creating trigger file
cat > trigger.txt << EOF
+^X -name=triggerx -command=set -xecute="do triggerfnx^gtm8844"
+^Y -name=triggery -command=set -xecute="do triggerfny^gtm8844"
EOF

echo "# Running functions that violate our restrictions"
echo "# -------------------------------------------------------------------------------------------"
setenv pause 0
echo "# Two consecutive halts"
$ydb_dist/mumps -run haltfn^gtm8844
ls *FATAL*
rm *FATAL*
echo "# -------------------------------------------------------------------------------------------"
echo "# Two consecutive zhalts"
$ydb_dist/mumps -run zhaltfn^gtm8844
ls *FATAL*
rm *FATAL*
echo "# -------------------------------------------------------------------------------------------"
echo "# Two consecutive halts with a pause"
setenv pause 1
$ydb_dist/mumps -run haltfn^gtm8844
ls *FATAL*
echo "# -------------------------------------------------------------------------------------------"
echo "# Two consecutive zhalts with a pause"
$ydb_dist/mumps -run zhaltfn^gtm8844
ls *FATAL*
echo "# -------------------------------------------------------------------------------------------"
echo "# Confirming ZHALT,ZGOTO 0 produces an error in the shell"
$ydb_dist/mumps -run zgotofn^gtm8844
set exitstatus=$status
echo "Status After ZGOTOFN=$exitstatus"
if ($exitstatus) then
	echo "Error Detected"
endif
echo "# -------------------------------------------------------------------------------------------"
$MULTISITE_REPLIC_PREPARE 2
# Set up a non replicated region HREG for our trigger activities (the 9th region from the dbcreate)
setenv gtm_test_repl_norepl 1
$gtm_tst/com/dbcreate.csh mumps 9 >>& dbcreate.out
$MSR START INST1 INST2 >>& MSRStart.out

# Creating initial values for global variables X and Y, uploading triggers
$MSR RUN INST1 '$ydb_dist/mumps -run ^%XCMD "set ^X=0  set ^Y=0"'
$MUPIP trigger -triggerfile=trigger.txt

echo ""

echo "# Test ZHALT in a trigger takes down the update process"
# We use the global variable ^H in HREG (unreplicated in instance 2) to ensure that when we turn the database back on, the update in the backlog
# can go through without error

foreach var (^X ^Y)
	$MSR RUN INST2 '$ydb_dist/mumps -run ^%XCMD "set ^H=0;write ^H"' >>& extrastuff.out
	echo "# Setting off Trigger"
	$MSR RUN INST1 '$ydb_dist/mumps -run ^%XCMD "set '$var'=1"'
	echo "# Check primary"
	$MSR RUN INST1 '$ydb_dist/mumps -run ^%XCMD "write '$var'"'
	echo "# Check secondary"
	$MSR RUN INST2 '$ydb_dist/mumps -run ^%XCMD "write '$var',!"'
	$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth >& checkhealth.tmp ; cat checkhealth.tmp' >& checkhealth.out
	set updprocpid = `$tst_awk '/PID.*Update process/{print $2}' checkhealth.out`
	$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/wait_for_proc_to_die.csh' $updprocpid
	$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth >& checkhealth.tmp ; cat checkhealth.tmp' >& checkhealth.out
	cat checkhealth.out
	echo "# Restore the update process"
	# Using outx because we are expecting errors
	$MSR STOPRCV INST1 INST2 >>& restart.outx
	$MSR RUN INST2 '$ydb_dist/mumps -run ^%XCMD "set ^H=1;write ^H"'>>& restart.outx
	$MSR STARTRCV INST1 INST2 >>& restart.outx
	$MSR SYNC INST1 INST2 >>& restart.outx
	echo "# Confirm secondary's update process is restored and database is up to date"
	$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth'
	$MSR RUN INST2 '$ydb_dist/mumps -run ^%XCMD "write '$var',!"'
	echo "# -------------------------------------------------------------------------------------------"
end
rm $SEC_DIR/*FATAL*


$gtm_tst/com/dbcheck.csh >>& dbcheck.out
