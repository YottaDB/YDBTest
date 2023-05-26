#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Check functionality of $ZPEEK() - note requires GTMDefinedTypesInit.m
# to be available.
#
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	setenv test_specific_gde $gtm_tst/$tst/inref/peekaboo_col${colno}.sprgde
endif
setenv gtm_test_spanreg		0	# We have already pointed a spanning gld to test_specific_gde
setenv gtm_test_jnlfileonly	0	# We mangle the journal, so avoid forcing the source to read it.
unsetenv gtm_test_jnlpool_sync		# ditto

if (0 == $?test_replic) then
    echo "Subtest peekaboo must be run with -replic"
    exit 1
endif
#
setenv gtm_test_disable_randomdbtn 1          # Disable resetting the TN to lower values cause below reset to fail
setenv gtm_test_mupip_set_version "disable"   # Don't drive V4 conversion testing
unsetenv gtm_custom_errors                    # Test sends JNLFILOPN to syslog, potentially causing instance freeze without this.
#
echo ""
$echoline
echo "Create database and start replication"
$echoline
echo ""
$gtm_tst/com/dbcreate.csh mumps 4
echo ""
$echoline
echo "Wait for connection to be established"
$echoline
echo ""
setenv start_time `cat start_time`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 30"
#
# Set TN to an interesting transnum a few shy of the warning TN. We'll be extracting this TN and
# formatting it different ways. Do this on both sides.
#
echo ""
$echoline
echo "Reset current TN value in each region"
$echoline
echo ""
$gtm_tst/com/dse_command.csh -region AREG BREG CREG DEFAULT -do 'change -f -current_tn=0xFFFFFFD813FFFF41'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dse_command.csh -region AREG BREG CREG DEFAULT -do 'change -f -current_tn=0xFFFFFFD813FFFF41'"
#
# Now just do a few updates so things churn slightly
#
echo ""
$echoline
echo "Run a few updates to give replication a modicum of work to do"
$echoline
echo ""
$GTM << EOF
For i=1:1:10 Set (^a(i),^b(i),^c(i),^zot(i))=\$Random(1000000)
Set ^done=1 ; used as flag earlier updates completed
EOF
#
# Run $ZPEEK() test on primary
#
echo ""
$echoline
echo "Run peekaboo primary side first"
$echoline
echo ""
$gtm_dist/mumps -run peekaboo
#
# Make sure other side sync'd before we drive peekaboo on the 2ndary
#
$gtm_tst/com/RF_sync.csh
#
# Run $ZPEEK() test on 2ndry
#
echo ""
$echoline
echo "Now running peekaboo on 2ndry side"
$echoline
echo ""
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_dist/mumps -run peekaboo"
#
# integ check not strictly necessary since we never update the DB but for consistency sake..
#
echo ""
$echoline
echo "DB-check"
$echoline
echo ""
$gtm_tst/com/dbcheck.csh
