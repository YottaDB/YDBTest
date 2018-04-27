#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2011, 2014 Fidelity Information Services, Inc	#
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
#;;;Test handling of interrupts during pipe reads
#;;;This work was done under the tr D9K02-002753

$switch_chset M

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

# build the c routines for the tests
$gt_cc_compiler -o delayecho -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/delayecho.c
rm -f delayecho.o

# Set encryption attributes, if needed.
source $gtm_tst/$tst/u_inref/set_key_and_iv.csh

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_non_blocked_write_retries gtm_non_blocked_write_retries 600

# add additional reads for inti and liza as they are faster than atlst2000 and can finish with no interrupts using the
# default settings in ^readcnt as defined in intrdriver.m for Solaris platforms

set hostn = $HOST:r:r:r
if (("inti" == $hostn) || ("liza" == $hostn)) then
	$gtm_dist/mumps -run ^%XCMD 'set ^morereads=1500'
endif

# add additional reads for atlst2000 in encryption mode to prevent it from finishing with no interrupts
if (("atlst2000" == $hostn) && ("ENCRYPT" == "$test_encryption")) then
	$gtm_dist/mumps -run ^%XCMD 'set ^morereads=2500'
endif

# report number of read interrupts when mumps exits
setenv gtmdbglvl 0x00080000

$echoline
echo "**************************** fixednonutf ***********************"
$echoline
$gtm_dist/mumps -run intrdriver fixednonutf >& fixednonutf.out
# make sure the read and interrupt processes are done
set pid1=`cat fixednonutf_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 600
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat fixednonutf_send_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 600
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

# check for read interrupts
$tst_awk '/interrupted/{num=$8}END{if(num<1){print "Read interrupted count not found or is 0 in " FILENAME}}' fixednonutfread.mje

$grep "Input matches" fixednonutfread.mjo
$echoline
echo "**************************** streamnonutf ****************************"
$echoline
$gtm_dist/mumps -run intrdriver streamnonutf >& streamnonutf.out
# make sure the read and interrupt processes are done
set pid1=`cat streamnonutf_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 600
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat streamnonutf_send_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 600
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

# check for read interrupts
$tst_awk '/interrupted/{num=$8}END{if(num<1){print "Read interrupted count not found or is 0 in " FILENAME}}' streamnonutfread.mje

$grep "Input matches" streamnonutfread.mjo
$echoline

if ("TRUE" == $gtm_test_unicode_support) then
# Large block containing GTM input redirection commands.  Not indenting.

# Now do the utf versions.  Have to recompile the test m routines
rm intrdriver.o sendintr.o readintr.o
$switch_chset UTF-8
$echoline
echo "**************************** streamutf8 ***********************"
$echoline
$gtm_dist/mumps -run intrdriver streamutf8 >& streamutf8.out
# make sure the read and interrupt processes are done
set pid1=`cat streamutf8_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 600
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat streamutf8_send_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 600
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

# check for read interrupts
$tst_awk '/interrupted/{num=$8}END{if(num<1){print "Read interrupted count not found or is 0 in " FILENAME}}' streamutf8read.mje

$grep "Input matches" streamutf8read.mjo
$echoline
echo "**************************** fixedutf8 ***********************"
$echoline
$gtm_dist/mumps -run intrdriver fixedutf8 >& fixedutf8.out
# make sure the read and interrupt processes are done
set pid1=`cat fixedutf8_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 600
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat fixedutf8_send_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 600
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

# check for read interrupts
$tst_awk '/interrupted/{num=$8}END{if(num<1){print "Read interrupted count not found or is 0 in " FILENAME}}' fixedutf8read.mje

$grep "Input matches" fixedutf8read.mjo
$echoline
echo "**************************** streamutf16 ***********************"
$echoline
$gtm_dist/mumps -run intrdriver streamutf16 >& streamutf16.out
# make sure the read and interrupt processes are done
set pid1=`cat streamutf16_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 600
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat streamutf16_send_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 600
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

# check for read interrupts
$tst_awk '/interrupted/{num=$8}END{if(num<1){print "Read interrupted count not found or is 0 in " FILENAME}}' streamutf16read.mje

$grep "Input matches" streamutf16read.mjo
$echoline
echo "**************************** fixedutf16 ***********************"
$echoline
$gtm_dist/mumps -run intrdriver fixedutf16 >& fixedutf16.out
# make sure the read and interrupt processes are done
set pid1=`cat fixedutf16_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 600
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat fixedutf16_send_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 600
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

# check for read interrupts
$tst_awk '/interrupted/{num=$8}END{if(num<1){print "Read interrupted count not found or is 0 in " FILENAME}}' fixedutf16read.mje

$grep "Input matches" fixedutf16read.mjo
$echoline
$switch_chset M
unsetenv LC_CTYPE

# end of large if block
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
