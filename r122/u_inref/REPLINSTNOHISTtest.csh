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
$gtm_tst/$tst/u_inref/ydb210_MSR.dbcreate.csh

echo "# Start INST1 INST2 connection" >> REPLINSTNOHIST.logx
$MSR START INST1 INST2 >>& REPLINSTNOHIST.logx
get_msrtime
setenv srcLog1 "SRC_$time_msr.log" #srcLog1 will hold current source log for INST1 INST2
echo '' >> REPLINSTNOHIST.logx

#$gtm_tst/com/wait_for_log.csh -message "New History Content" -log $srcLog1 -duration 300
echo "# Update the DB" >> REPLINSTNOHIST.logx
$ydb_dist/mumps -run ^%XCMD 'SET ^J="100396"'
$MSR SYNC INST1 INST2 >>& REPLINSTNOHIST.logx
echo '' >> REPLINSTNOHIST.logx

echo "# Shutdown INST1 INST2 connection and replace the instance file in INST1" >> REPLINSTNOHIST.logx
set INST1_supplarg=""
set INST2_supplarg=""
if (1 == $test_replic_suppl_type) then
	set INST2_supplarg="-supplementary"
else if (2 == $test_replic_suppl_type) then
	set INST1_supplarg="-supplementary"
	set INST2_supplarg="-supplementary"
endif
$MSR STOPSRC INST1 INST2 >>& REPLINSTNOHIST.logx
$MSR STOPRCV INST1 INST2 >>& REPLINSTNOHIST.logx
$MSR RUN INST1 'set msr_dont_trace ; mv mumps.repl mumps.repl_precrash ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME1 '$gtm_test_qdbrundown_parms $INST1_supplarg'' >>& REPLINSTNOHIST.logx
echo '' >> REPLINSTNOHIST.logx

echo "# Start INST1 INST3 connection (expecting RCVR start to fail with REPLINSTNOHIST error)" >> REPLINSTNOHIST.logx
if ($rand == 1) then
       	$MSR STARTSRC INST1 INST3 >>& REPLINSTNOHIST.logx
	get_msrtime
	setenv srcLog2 "SRC_$time_msr.log"
else
	#Use expect script to run the commands from the if statement
	(expect -d $gtm_tst/$tst/u_inref/REPLINSTNOHISTtest.exp > expect_REPLINSTNOHIST.out) >& expect_REPLINSTNOHIST.dbg
	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status" >> REPLINSTNOHIST.logx
		echo "		      ydb210.exp calling $errorTest" >> REPLINSTNOHIST.logx
		echo '' >> REPLINSTNOHIST.logx
	endif

	get_msrtime
	setenv srcLog2 "SRC_$time_msr.log"
	# move .out to .outx to avoid -E- from being caught by test framework
	mv expect_REPLINSTNOHIST.out expect_REPLINSTNOHIST.outx
	perl $gtm_tst/com/expectsanitize.pl expect_REPLINSTNOHIST.outx > expect_REPLINSTNOHIST_sanitized.outx
endif
echo "srcLog2: $srcLog2" >> REPLINSTNOHIST.logx

# Start the reciever and get its log file
$MSR STARTRCV INST1 INST3 >>& REPLINSTNOHIST.logx
get_msrtime
$MSR RUN INST3 "cat RCVR_$time_msr.log" >> INST3_RCVR.logx

# Pull process ID from reciever log
setenv RCVR_PID `$grep -e "Replication Receiver Server with Pid" INST3_RCVR.logx | $tst_awk '{ print substr($14,2,length($14)-2)}'`
#echo "RCVR_PID:$RCVR_PID" >> REPLINSTNOHIST.logx

# dont move on until the error has been generated in the source log
$gtm_tst/com/wait_for_log.csh -message "YDB-E" -log $srcLog2 -duration 300
echo '' >> REPLINSTNOHIST.logx

echo "# INST1 INST2 errors:" >> REPLINSTNOHIST.logx
$grep -e "-E-" $srcLog1  >> REPLINSTNOHIST.logx
echo "# INST1 INST3 errors:" >> REPLINSTNOHIST.logx
$grep -e "-E-" $srcLog2  >> REPLINSTNOHIST.logx
echo '' >> REPLINSTNOHIST.logx

echo "# Wait for the INST1 INST3 reciever to die" >> REPLINSTNOHIST.logx
source $gtm_tst/com/wait_for_proc_to_die.csh $RCVR_PID 60 ./wait_for_proc_to_die.logx >> REPLINSTNOHIST.logx
echo '' >>& REPLINSTNOHIST.logx

echo "# Shutdown INST3 passive source server" >> REPLINSTNOHIST.logx
$MSR RUN INST3 '$MUPIP replic -source -shutdown -timeout=0 >&! passive_shut.out'
echo '' >>& REPLINSTNOHIST.logx

echo "# Stop INST1 INST3 source server" >> REPLINSTNOHIST.logx
$MSR STOPSRC INST1 INST3 >>& REPLINSTNOHIST.logx
echo '' >>& REPLINSTNOHIST.logx

echo "# Check the DB" >> REPLINSTNOHIST.logx
$gtm_tst/com/dbcheck.csh -noshut >& dbcheck.outx
if ($status) then
	echo "DB Check Failed, Output Below" >> REPLINSTNOHIST.logx
	cat dbcheck.outx >> REPLINSTNOHIST.logx
endif
echo '' >> REPLINSTNOHIST.logx


echo "Test has concluded"
