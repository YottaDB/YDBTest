#!/usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

# -----------------------------------------------------------------------
# Test the -CMPLVL qualifier.
# -----------------------------------------------------------------------

# In all the subtests below, do a fixed # of updates and do a dbcheck.csh -extract to make sure
# replication has worked fine irrespective of whether compression was ON or OFF.

set echostr = "-------------------------------------------------------------------------------"

# Choose a valid compression level from 1 to 9
@ validcmplvl  = 1 + `$gtm_exe/mumps -run rand 9`
@ validcmplvl2 = 1 + `$gtm_exe/mumps -run rand 9`

source $gtm_tst/com/unset_ydb_env_var.csh ydb_zlib_cmp_level gtm_zlib_cmp_level	# start with NO compression
# Record the above overrides into settings.csh as well in case dbcreate sources settings.csh
echo "source $gtm_tst/com/unset_ydb_env_var.csh ydb_zlib_cmp_level gtm_zlib_cmp_level"	>>! settings.csh

#-----------------------------------------------------------------------------------------------------------------
# Define strings to look out for in the log files
#
set nocmpstr = "Defaulting to NO compression"
set yescmpstr = "Using zlib compression level .* for replication"
set yescmpexactlvlstr = "Using zlib compression level $validcmplvl for replication"
set cmplvlinvalidstr = "Compression level 10 invalid; Error from compress function before sending REPL_CMP_TEST message"
set replinfotrcmpstr = "^.* : REPL INFO - Jnl Total : [0-9]*  Msg Total : [0-9]*  CmpMsg Total : [0-9]*"
set rcvruncmpfailstr = "Receiver server could not decompress successfully"

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 1 : Test of NEGATIVE CMPLVL"
echo $echostr
# Start both source and receiver server with negative cmplvl.
#    Attempt MUPIP REPLIC -SOURCE -START -CMPLVL=-1
#        You should see an error in source server log that -1 is not a valid compression level.
#
#    Attempt MUPIP REPLIC -RECEIV -START -CMPLVL=-1
#        You should see an error in receiver server log that -1 is not a valid compression level.
#
echo "This test is not implemented since GT.M currently gives a CLIERR for any negative input since it contains a dash"

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 2 : Test that cmplvl=0 on source server side results in NO compression on the replication pipe"
echo $echostr
# Start source server with cmplvl=0 and receiver server with cmplvl=<valid-level>.
setenv gtm_test_repl_src_cmplvl 0
setenv gtm_test_repl_rcvr_cmplvl $validcmplvl
$gtm_tst/com/dbcreate.csh mumps
$GTM << GTM_EOF
	set ^testcase(2)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show NO compression happening.
$gtm_tst/com/grepfile.csh "$yescmpstr" $srclog 0
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 0

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 3 : Test that cmplvl=0 on receiver server side results in NO compression on the replication pipe"
echo $echostr
# Start source server with cmplvl=<valid-level> and receiver server with cmplvl=0.
setenv gtm_test_repl_src_cmplvl $validcmplvl
setenv gtm_test_repl_rcvr_cmplvl 0
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(3)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show NO compression happening.
$gtm_tst/com/grepfile.csh "$yescmpstr" $srclog 0
# Test that logs show source server sent a test message but receiver could not decompress properly
$gtm_tst/com/grepfile.csh "$rcvruncmpfailstr" $srclog 1
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 1

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 4 : Test that invalid cmplevel on source server results in NO compression on the replication pipe"
echo $echostr
# Start source server with cmplvl=10 (an invalid level) and receiver server with cmplvl=<valid-level>.
setenv gtm_test_repl_src_cmplvl 10
setenv gtm_test_repl_rcvr_cmplvl $validcmplvl
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(4)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show NO compression happening.
$gtm_tst/com/grepfile.csh "$yescmpstr" $srclog 0
# In addition you should see the following error in the source server log.
# 	"Compression level 10 invalid; Error from compress function before sending REPL_CMP_TEST message"
$gtm_tst/com/grepfile.csh "$cmplvlinvalidstr" $srclog 1
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 1

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 5 : Test that invalid cmplevel on receiver server does not matter as long as it is greater than ZERO"
echo $echostr
# Start source server with cmplvl=<valid-level> and receiver server with cmplvl=10 (an invalid level).
setenv gtm_test_repl_src_cmplvl $validcmplvl
setenv gtm_test_repl_rcvr_cmplvl 10
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(5)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show compression is happening.
# This is because even though 10 is an invalid level as far as compression is concerned,
#	the receiver server does not care about it.
$gtm_tst/com/grepfile.csh "$yescmpexactlvlstr" $srclog 1
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 0

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 6 : Test that valid cmplevel on both source and receiver server results in compression on the replication pipe"
echo $echostr
# Start source server with cmplvl=<valid-level> and receiver server with cmplvl=<same-valid-level>.
setenv gtm_test_repl_src_cmplvl $validcmplvl
setenv gtm_test_repl_rcvr_cmplvl $validcmplvl
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(6)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show compression is happening.
$gtm_tst/com/grepfile.csh "$yescmpexactlvlstr" $srclog 1
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 0
# Check that there is a "^REPL INFO.*" message at the end of the source server log that contains
#         "CmpMsg Total" and "Msg Total" field with differing lengths.
$gtm_tst/com/grepfile.csh "$replinfotrcmpstr" $srclog 1
# Also check that the former is LESSER than the latter.
# Allow for atmost 8-byte difference since that the compressed record has an additional 8-byte message header.
# This is also a test that the compressed and uncompressed fields are logged by the source server.
# Sample output
#	Tue Oct 14 15:18:34 2008 : REPL INFO - Jnl Total : 248048  Msg Total : 248056  CmpMsg Total : 4088
#                                                                             ^^^^^^                 ^^^^
# So need to look at $17 and $21
$grep "$replinfotrcmpstr" $srclog | $tst_awk '{if ($21 <= ($17+8)) print "PASS : CmpMsg Total LESSER-THAN-OR-EQUAL-TO Msg Total"; else print "FAIL : CmpMsg Total GREATER than Msg Total";}'

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 7 : Test that environment variable gtm_zlib_cmp_level=<valid-level> is EQUIVALENT to the cmplvl qualifier"
echo $echostr
# Set environment variable gtm_zlib_cmp_level to 9 (a valid level).
# Start source server with no -cmplvl qualifier.
# Start receiver server with no -cmplvl qualifier.
unsetenv gtm_test_repl_src_cmplvl
unsetenv gtm_test_repl_rcvr_cmplvl
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zlib_cmp_level gtm_zlib_cmp_level $validcmplvl
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(7)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show compression is happening and that level is mentioned as $validcmplvl in source server log.
$gtm_tst/com/grepfile.csh "$yescmpexactlvlstr" $srclog 1
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 0

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 8 : Test that CMPLVL qualifier overrides the gtm_zlib_cmp_level environment variable"
echo $echostr
# Set environment variable gtm_zlib_cmp_level to 9 (a valid level).
# Start source server with -cmplvl=5 (yet another valid level) qualifier.
# Start receiver server with no -cmplvl qualifier.
#
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zlib_cmp_level gtm_zlib_cmp_level $validcmplvl2
setenv gtm_test_repl_src_cmplvl $validcmplvl
unsetenv gtm_test_repl_rcvr_cmplvl
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(8)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show compression is happening and that level is mentioned as $validcmplvl (not $validcmplvl2) in source server log.
$gtm_tst/com/grepfile.csh "$yescmpexactlvlstr" $srclog 1
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 0

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 9 : Test that environment variable gtm_zlib_cmp_level=0 implies NO compression"
echo $echostr
# Set environment variable gtm_zlib_cmp_level to 0.
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zlib_cmp_level gtm_zlib_cmp_level 0
# Make sure CMPLVL qualifier is NOT used.
unsetenv gtm_test_repl_src_cmplvl
unsetenv gtm_test_repl_rcvr_cmplvl
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(9)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show NO compression happening.
$gtm_tst/com/grepfile.csh "$yescmpstr" $srclog 0
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 0

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 10 : Test that environment variable gtm_zlib_cmp_level and CMPLVL qualifier work TOGETHER"
echo $echostr
# Set environment variable gtm_zlib_cmp_level to 9 (a valid cmplevel)
# Start source server with -cmplvl=5 (yet another valid cmplevel) qualifier. This should override the environment variable.
# Start receiver server with no -cmplvl qualifier. It should inherit the cmplevel from the environment variable.
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zlib_cmp_level gtm_zlib_cmp_level $validcmplvl2
setenv gtm_test_repl_src_cmplvl $validcmplvl
unsetenv gtm_test_repl_rcvr_cmplvl
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(10)="Done"
GTM_EOF
$gtm_tst/com/RF_SHUT.csh on
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show compression is happening and that level is mentioned as $validcmplvl (not $validcmplvl2) in source server log.
$gtm_tst/com/grepfile.csh "$yescmpexactlvlstr" $srclog 1
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 0

#-----------------------------------------------------------------------------------------------------------------
echo $echostr
echo "Test 11 : Test that CMPLVL=0 is same as NOT specifying CMPLVL at all"
echo $echostr
# Unset the environment variable gtm_zlib_cmp_level so only CMPLVL qualifier controls compression.
# Start source server with -cmplvl=5 (a valid cmplevel) qualifier.
# Start receiver server with no -cmplvl qualifier. It should start with NO compression.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_zlib_cmp_level gtm_zlib_cmp_level
setenv gtm_test_repl_src_cmplvl $validcmplvl
unsetenv gtm_test_repl_rcvr_cmplvl
$gtm_tst/com/RF_START.csh
$GTM << GTM_EOF
	set ^testcase(11)="Done"
GTM_EOF
$gtm_tst/com/RF_sync.csh
set timestamp = `cat $PRI_DIR/start_time`
set srclog = $PRI_DIR/SRC_$timestamp.log
# Test that logs show NO compression happening.
$gtm_tst/com/grepfile.csh "$yescmpstr" $srclog 0
# Test that logs show source server sent a test message but receiver could not decompress properly
$gtm_tst/com/grepfile.csh "$rcvruncmpfailstr" $srclog 1
$gtm_tst/com/grepfile.csh "$nocmpstr" $srclog 1

#-----------------------------------------------------------------------------------------------------------------
# Check that ALL updates until now have been replicated across irrespective of whether compression was used.
#
$gtm_tst/com/dbcheck.csh -extract
