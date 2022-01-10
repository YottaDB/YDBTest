#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test for GTM-9036 - test [NO]HUPENABLE device parameters to verify SIGHUP is interceptable.
#
# Methodology: The HUPENABLE processing we want to test is only valid when the $P device is a terminal so testing requires
#              requires the use of 'expect' to provide that pseudo-terminal environment in a batch test. So this test uses
#              'expect' - twice in fact. The first time is with ydb_hupenable set to FALSE (the default) and the second
#              when ydb_hupenable set to TRUE, which should cause expected failures.
#
# First invocation is with ydb_hupenable set to false so this is set in the script. The routine should run correctly this
# time as the first test the M routine does is to see what happens when a SIGHUP is sent to its own process. It should
# be ignored with this false setting (which is also the default).
#
echo "## Test for GTM-9036 - Test [NO]HUPENABLE device parameter along with setting ydb_hupenable environment variable to verify"
echo "## .. that we can catch and handle SIGHUP signals."
echo "##"
#
# Part 1:
#
# Note when the M routine (gtm9036) first runs it expects ydb_hupenable to be either undefined or off. If this is not true, the
# first part of the test will fail - which we expect in the second part of the test below.
echo "## Part 1: Run gtm9036.m with ydb_hupenable set to the default value of FALSE (the default)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_hupenable gtm_hupenable FALSE
## Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/gtm9036a.exp > expect.out1) >& expect.dbg1
# Now that the log is complete, check the execution status.
set saveStatus=$status
if (0 != $saveStatus) then
	echo "### Failure - first invocation of expect failed with rc=$saveStatus"
endif
# Make output readable and put it in our log to compare against this test's reference file
perl $gtm_tst/com/expectsanitize.pl expect.out1 > expect_sanitized.out1
cat expect_sanitized.out1
# Process the output of our command making it usable/readable for our purposes
# One this routine hit its SIGHUP handler, $P became unusable. Any IO to $P causes an immediate exit in the process. Because
# of this, the output from the above test, from the moment the test entered the interrupt handler, it switched its output from
# $P to the file gtm9036_post_exception.log. So now, cat that into the log of record (if it exists). If it doesn't exist due
# to some problem, the reference file diff will show it missing.
if (-e gtm9036_post_exception.log) then
    cat gtm9036_post_exception.log
    mv gtm9036_post_exception.log gtm9036_post_exception_1strun.logx # Save this one from overwrite
endif
#
# Part 2:
#
echo "## Part 2: Run gtm9036.m with ydb_hupenable set to TRUE to verify if is enough to set the hupenable on the first part"
echo "## .. of this test which assumes ydb_hupenable is FALSE. So we expect this to fail."
# This second invocation is done with ydb_hupenable set to true. What this will do is cause the first test in this routine
# to fail as it assumes it is being run with the default (false or not specified) value of false. We expect no output because
# SIGHUP would terminate the process abruptly before error handler can do any IO to $P
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_hupenable gtm_hupenable TRUE
## Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/gtm9036b.exp > expect.out2) >& expect.dbg2
set saveStatus=$status
# So we expect the first part of this test to fail. Note the sanitized output file will only contain output from the first
# subtest in gtm9036 - the other two subtests will be bypassed when the first subtest fails.
if (0 != $saveStatus) then
	echo "### Failure - second invocation of expect failed with rc=$saveStatus"
endif
# Make output readable and put it in our log to compare against reference file
perl $gtm_tst/com/expectsanitize.pl expect.out2 > expect_sanitized.out2
cat expect_sanitized.out2
echo
echo "## Test complete"
