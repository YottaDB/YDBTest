#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
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
#;;;Test handling of interrupts during disk reads with FOLLOW
#
# "sendintr.m" is a common routine also used by pipeintrpt.csh and fifointrpt.csh to interrupt the read process.
# For this test the read process is diskreadintr.m.

$switch_chset M

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

# Set encryption attributes, if needed.
source $gtm_tst/$tst/u_inref/set_key_and_iv.csh

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_non_blocked_write_retries gtm_non_blocked_write_retries 600

# report number of read interrupts when mumps exits
setenv gtmdbglvl 0x00080000

$echoline
echo "**************************** fixednonutf ***********************"
$echoline
$gtm_dist/mumps -run diskintrdriver fixednonutf >& fixednonutf.out
# make sure the read and interrupt processes are done
set pid1=`cat fixednonutf_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat fixednonutf_send_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif
set pid3=`cat fixednonutf_senddata_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
if ($status) then
	echo "TEST-E-ERROR process $pid3 did not die."
endif

# check for read interrupts
set numint=`$grep interrupted fixednonutfread.mje`
if ($#numint) then
	if (0 == `echo $numint | $tst_awk '{print $8}'`) then
		echo "Read interrupt count is zero in fixednonutfread.mje"
	endif
else
	echo "Read interrupt count missing from fixednonutfread.mje"
endif

$grep "Input matches" fixednonutfread.mjo
$echoline
echo "**************************** streamnonutf ****************************"
$echoline
$gtm_dist/mumps -run diskintrdriver streamnonutf >& streamnonutf.out
# make sure the read and interrupt processes are done
set pid1=`cat streamnonutf_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat streamnonutf_send_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif
set pid3=`cat streamnonutf_senddata_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
if ($status) then
	echo "TEST-E-ERROR process $pid3 did not die."
endif

# check for read interrupts
set numint=`$grep interrupted streamnonutfread.mje`
if ($#numint) then
	if (0 == `echo $numint | $tst_awk '{print $8}'`) then
		echo "Read interrupt count is zero in streamnonutfread.mje"
	endif
else
	echo "Read interrupt count missing from streamnonutfread.mje"
endif

$grep "Input matches" streamnonutfread.mjo
$echoline

if ("TRUE" == $gtm_test_unicode_support) then
	# Now do the utf versions.  Have to recompile the test m routines
	rm diskintrdriver.o sendintr.o diskreadintr.o disksenddata.o
	$switch_chset UTF-8
	$echoline
	echo "**************************** streamutf8 ***********************"
	$echoline
	$gtm_dist/mumps -run diskintrdriver streamutf8 >& streamutf8.out
	# make sure the read and interrupt processes are done
	set pid1=`cat streamutf8_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
	if ($status) then
		echo "TEST-E-ERROR process $pid1 did not die."
	endif
	set pid2=`cat streamutf8_send_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
	if ($status) then
		echo "TEST-E-ERROR process $pid2 did not die."
	endif
	set pid3=`cat streamutf8_senddata_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
	if ($status) then
		echo "TEST-E-ERROR process $pid3 did not die."
	endif

	# check for read interrupts
	set numint=`$grep interrupted streamutf8read.mje`
	if ($#numint) then
		if (0 == `echo $numint | $tst_awk '{print $8}'`) then
			echo "Read interrupt count is zero in streamutf8read.mje"
		endif
	else
		echo "Read interrupt count missing from streamutf8read.mje"
	endif

	$grep "Input matches" streamutf8read.mjo
	$echoline
	echo "**************************** streamutf16 ***********************"
	$echoline
	$gtm_dist/mumps -run diskintrdriver streamutf16 >& streamutf16.out
	# make sure the read and interrupt processes are done
	set pid1=`cat streamutf16_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
	if ($status) then
		echo "TEST-E-ERROR process $pid1 did not die."
	endif
	set pid2=`cat streamutf16_send_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
	if ($status) then
		echo "TEST-E-ERROR process $pid2 did not die."
	endif
	set pid3=`cat streamutf16_senddata_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
	if ($status) then
		echo "TEST-E-ERROR process $pid3 did not die."
	endif

	# check for read interrupts
	set numint=`$grep interrupted streamutf16read.mje`
	if ($#numint) then
		if (0 == `echo $numint | $tst_awk '{print $8}'`) then
			echo "Read interrupt count is zero in streamutf16read.mje"
		endif
	else
		echo "Read interrupt count missing from streamutf16read.mje"
	endif

	$grep "Input matches" streamutf16read.mjo
	$echoline
	echo "**************************** fixedutf8 ***********************"
	$echoline
	$gtm_dist/mumps -run diskintrdriver fixedutf8 >& fixedutf8.out
	# make sure the read and interrupt processes are done
	set pid1=`cat fixedutf8_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
	if ($status) then
		echo "TEST-E-ERROR process $pid1 did not die."
	endif
	set pid2=`cat fixedutf8_send_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
	if ($status) then
		echo "TEST-E-ERROR process $pid2 did not die."
	endif
	set pid3=`cat fixedutf8_senddata_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
	if ($status) then
		echo "TEST-E-ERROR process $pid3 did not die."
	endif

	# check for read interrupts
	set numint=`$grep interrupted fixedutf8read.mje`
	if ($#numint) then
		if (0 == `echo $numint | $tst_awk '{print $8}'`) then
			echo "Read interrupt count is zero in fixedutf8read.mje"
		endif
	else
		echo "Read interrupt count missing from fixedutf8read.mje"
	endif

	$grep "Input matches" fixedutf8read.mjo
	$echoline
	echo "**************************** fixedutf16 ***********************"
	$echoline
	$gtm_dist/mumps -run diskintrdriver fixedutf16 >& fixedutf16.out
	# make sure the read and interrupt processes are done
	set pid1=`cat fixedutf16_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
	if ($status) then
		echo "TEST-E-ERROR process $pid1 did not die."
	endif
	set pid2=`cat fixedutf16_send_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
	if ($status) then
		echo "TEST-E-ERROR process $pid2 did not die."
	endif
	set pid3=`cat fixedutf16_senddata_pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
	if ($status) then
		echo "TEST-E-ERROR process $pid3 did not die."
	endif

	# check for read interrupts
	set numint=`$grep interrupted fixedutf16read.mje`
	if ($#numint) then
		if (0 == `echo $numint | $tst_awk '{print $8}'`) then
			echo "Read interrupt count is zero in fixedutf16read.mje"
		endif
	else
		echo "Read interrupt count missing from fixedutf16read.mje"
	endif

	$grep "Input matches" fixedutf16read.mjo

	$echoline
	$switch_chset M
	unsetenv LC_CTYPE
endif

unsetenv gtmdbglvl

echo
echo "finalstats.out contains statistics from the database as well as read interrupt information"
# store final statistics
$gtm_dist/mumps -direct << xxx
do ^%G
finalstats.out
*

halt
xxx

echo >> finalstats.out
echo "Files and order for read interrupt information:" >> finalstats.out
ls -1 *read.mje >> finalstats.out
echo "Read interrupts for each type:" >> finalstats.out
cat *read.mje >> finalstats.out

$gtm_tst/com/dbcheck.csh
