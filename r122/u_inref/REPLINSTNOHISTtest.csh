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

$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/$tst/u_inref/ydb210_dbcreate.csh 1 >> dbcreate.log
if ($status) then
	echo "FAILURE from ydb210_dbcreate.csh " >> $outputFile
	echo "Dumping dbcreate.log:" >> $outputFile
	cat dbcreate.log >> $outputFile
endif

echo "# Start INST1 INST2 connection" >> $outputFile
$MSR START INST1 INST2 >>& $outputFile
get_msrtime
setenv srcLog1 "SRC_$time_msr.log" #srcLog1 will hold current source log for INST1 INST2
echo '' >> $outputFile

echo "# Update the DB" >> $outputFile
$ydb_dist/mumps -run ^%XCMD 'SET ^J="100396"'
$MSR SYNC INST1 INST2 >>& $outputFile
echo '' >> $outputFile

echo "# Shutdown INST1 INST2 connection and recreate the instance file in INST1" >> $outputFile
set INST1_supplarg=""
set INST2_supplarg=""
if (1 == $test_replic_suppl_type) then
	set INST2_supplarg="-supplementary"
else if (2 == $test_replic_suppl_type) then
	set INST1_supplarg="-supplementary"
	set INST2_supplarg="-supplementary"
endif
$MSR STOPSRC INST1 INST2 >>& $outputFile
$MSR STOPRCV INST1 INST2 >>& $outputFile
$MSR RUN INST1 'set msr_dont_trace ; mv mumps.repl mumps.repl_precrash ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME1 '$gtm_test_qdbrundown_parms $INST1_supplarg'' >>& $outputFile
echo '' >> $outputFile

echo "# Start INST1 INST3 connection (expecting RCVR start to fail with REPLINSTNOHIST error in source server log)" >> $outputFile
setenv gtm_test_repl_skiprcvrchkhlth 1 # Have test framework ignore the expected failure in the reciever log
if ($terminalNoKill == 1) then
       	$MSR STARTSRC INST1 INST3 >>& $outputFile
	get_msrtime
	setenv srcLog2 "SRC_$time_msr.log"
else
	#Use expect script to run the commands from the IF block of code
	 set cmd1='$MSR STARTSRC INST1 INST3 >>& $outputFile'
	 set cmd2='echo "setenv msr_execute_last_out $msr_execute_last_out" > REPLINSTNOHIST.src'
	 set cmds="$cmd1; $cmd2"

	(expect -d $gtm_tst/com/runcmd.exp "$cmds" > expect_REPLINSTNOHIST.out) >& expect_REPLINSTNOHIST.dbg

	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status" >> $outputFile
		echo "		      ydb210.exp calling $errorTest" >> $outputFile
		echo '' >> $outputFile
	endif

	#source file created by REPLINSTNOHISTtest.exp for $msr_execute_last_out
	source REPLINSTNOHIST.src
	get_msrtime
	setenv srcLog2 "SRC_$time_msr.log"
	# move .out to .outx to avoid -E- from being caught by test framework
	perl $gtm_tst/com/expectsanitize.pl expect_REPLINSTNOHIST.out > expect_REPLINSTNOHIST_sanitized.out
endif


# Start the reciever and get its log file
$MSR STARTRCV INST1 INST3 >>& $outputFile
get_msrtime
$MSR RUN INST3 "cat RCVR_$time_msr.log" >> INST3_RCVR.log

# Pull process ID from reciever log
setenv RCVR_PID `$grep -e "Replication Receiver Server with Pid" INST3_RCVR.log | $tst_awk '{ print substr($14,2,length($14)-2)}'`

# dont move on until the error has been generated in the source log
$gtm_tst/com/wait_for_log.csh -message "YDB-E" -log $srcLog2 -duration 300
unsetenv gtm_test_repl_skiprcvrchkhlth # It's now safe to pay attention to reciever log errors again
if ($status) then
	echo " FAILURE from wait_for_log.csh:"
	echo " 		Searching for YDB_E within $srcLog2"
endif
echo '' >> $outputFile

echo "# INST1 INST2 source server log errors:" >> $outputFile
$grep -e "-E-" $srcLog1  >> $outputFile
echo "# INST1 INST3 source server log errors:" >> $outputFile
$grep -e "-E-" $srcLog2  >> $outputFile
echo '' >> $outputFile

#Clean $srcLog2 of expected errors
check_error_exist.csh $srcLog2 "YDB-E-REPLINSTNOHIST" > /dev/null
if ($status) then
	echo " FAILURE from check_error_exist.csh:"
	echo " 		Searching for YDB-E-REPLINSTNOHIST in $srcLog2"
endif

echo "# Wait for the INST1 INST3 reciever to die" >> $outputFile
source $gtm_tst/com/wait_for_proc_to_die.csh $RCVR_PID 60 ./wait_for_proc_to_die.logx >> $outputFile
if ($status) then
	echo " FAILURE from wait_for_proc_to_die.csh:"
	echo " 		looking at RCVR with PID $RCVR_PID"
endif
echo '' >>& $outputFile

echo "# Shutdown INST3 passive source server" >> $outputFile
$MSR RUN INST3 '$MUPIP replic -source -shutdown -timeout=0 >&! passive_shut.out'
echo '' >>& $outputFile

echo "# Stop INST1 INST3 source server" >> $outputFile
$MSR STOPSRC INST1 INST3 >>& $outputFile
echo '' >>& $outputFile

echo "# Check the DB" >> $outputFile
$gtm_tst/com/dbcheck.csh -noshut >& dbcheck.outx
if ($status) then
	echo "DB Check Failed, Output Below" >> $outputFile
	cat dbcheck.outx >> $outputFile
endif
echo '' >> $outputFile
