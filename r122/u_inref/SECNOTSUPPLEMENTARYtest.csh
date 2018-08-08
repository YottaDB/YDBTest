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
#
setenv test_replic_suppl_type 0

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/$tst/u_inref/ydb210_dbcreate.csh 1 >> dbcreate.log
	if ($status) then
		echo "FAILURE from ydb210_dbcreate.csh "
		echo "Dumping dbcreate.log:"
		cat dbcreate.log
	endif

echo "# Generate INST1 INST2 instance files (supplementary and non-supplementary respectively)" >> $outputFile
#INST1 server will be supplementary
set INST1_supplarg="-supplementary"
#INST2 server will not be supplementary
set INST2_supplarg=""
$MSR RUN INST1 'set msr_dont_trace ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME1 '$gtm_test_qdbrundown_parms $INST1_supplarg'' >>& $outputFile
$MSR RUN INST2 'set msr_dont_trace ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME2 '$gtm_test_qdbrundown_parms $INST2_supplarg'' >>& $outputFile
echo '' >> $outputFile

echo "# Start INST1 server " >> $outputFile
if ($terminalNoKill == 1) then
       	$MSR STARTSRC INST1 INST2 >>& $outputFile
	get_msrtime
	setenv srcLog "SRC_$time_msr.log"
else
	#Use expect script to run the commands from the IF block of code
	 set cmd1='$MSR STARTSRC INST1 INST2 >>& $outputFile'
	 set cmd2='echo "setenv msr_execute_last_out $msr_execute_last_out" > SECNOTSUPPLEMENTARY.src'
	 set cmds="$cmd1; $cmd2"

	(expect -d $gtm_tst/com/runcmd.exp "$cmds" > expect_SECNOTSUPPLEMENTARY.out) >& expect_SECNOTSUPPLEMENTARY.dbg
	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status" >> $outputFile
		echo '' >> $outputFile
	endif

	#source file created by SECNOTSUPPLEMENTARYtest.exp for $msr_execute_last_out
	source SECNOTSUPPLEMENTARY.src
	get_msrtime
	setenv srcLog "SRC_$time_msr.log"
	# move .out to .outx to avoid -E- from being caught by test framework
	mv expect_SECNOTSUPPLEMENTARY.out expect_SECNOTSUPPLEMENTARY.outx
	perl $gtm_tst/com/expectsanitize.pl expect_SECNOTSUPPLEMENTARY.outx > expect_SECNOTSUPPLEMENTARY_sanitized.outx
endif
echo '' >>& $outputFile

# Pull process ID from source log
setenv SRC_PID `$grep -e "Replication Source Server with Pid" $srcLog | $tst_awk '{ print substr($14,2,length($14)-2)}'`

echo '# Start the INST2 server (expecting SECSUPPLEMENTARY error in source server log)' >>& $outputFile
$MSR STARTRCV INST1 INST2 >>& $outputFile
get_msrtime
$MSR RUN INST2 "cat RCVR_$time_msr.log" >> INST2_RCVR.log
setenv RCVR_PID `$grep -e "Replication Source Server with Pid" INST2_RCVR.log | $tst_awk '{ print substr($14,2,length($14)-2)}'`
echo '' >>& $outputFile

echo '# Wait for INST1 source server to die'
source $gtm_tst/com/wait_for_proc_to_die.csh $SRC_PID 60 ./wait_for_proc_to_die.logx >> $outputFile
echo '' >>& $outputFile

echo "# Errors in source server log:" >> $outputFile
$grep -e "-E-" $srcLog  >> $outputFile
echo '' >> $outputFile

#Clean $srcLog of expected errors
check_error_exist.csh $srcLog "YDB-E-SECNOTSUPPLEMENTARY" > /dev/null
if ($status) then
	echo " FAILURE from check_error_exist.csh:" >> $outputFile
	echo " 		Searching for YDB-E-SECNOTSUPPLEMENTARY in $srcLog" >> $outputFile
	echo "" >> $outputFile
endif

echo '# Stop INST2 server' >>& $outputFile
$MSR STOPRCV INST1 INST2 >>& $outputFile
echo '' >>& $outputFile

echo '# Wait for INST2 reciever server to die' >>& $outputFile
source $gtm_tst/com/wait_for_proc_to_die.csh $RCVR_PID 60 ./wait_for_proc_to_die.logx >> $outputFile
