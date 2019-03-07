#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test condition that when:
#   1. M-Profiling is activated.
#   2. A routine "artn" is on the M call stack.
#   4. That routine or some subsequent routine does an external call.
#   4. The external call does a call-in back into M mode.
#   5. The call-in pretty much just returns (just needed something to run here)
#   6. Once back in the main routine do an analysis of the collected M-Profile trace data to
#      detect where M-Profiling had trouble locating the routine behind the the call-in base
#      frame and the effect that has on the data returned. See testmprofhiddenrtn.m for details.
#
# Note this test fails with any version previous to V63002_R110.
# (This test is a stripped down version of test_rtn_replace)
#

unsetenv gtm_trace_gbl_name			# Unset to prevent interaction with our own enabling of MPROFiling
source $gtm_tst/com/dbcreate.csh mumps 1	# For mprof to use to dump its info (not used by test otherwise)
#
# Build shared library to hold the external call in
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gt_cc_option_DDEBUG $gt_cc_option_debug $gtm_tst/$tst/inref/drivecirtn.c
$gt_ld_shl_linker ${gt_ld_option_output}libdrivecirtn${gt_ld_shl_suffix} $gt_ld_shl_options drivecirtn.o $gt_ld_syslibs >& link1.map
if (0 != $status) then
    cat link1.map
endif
#
# Create simple call-out (aka external call) that wants to do a call-in
#
setenv GTMXC drivecirtn.xc
echo "`pwd`/libdrivecirtn${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << EOF
drivecirtn: void drivecirtn(I:gtm_char_t *)
EOF
#
# Create simple call-in to test routine replacement
#
setenv GTMCI testmprofhiddenrtn2.xc
cat >> $GTMCI << EOF
testmprofhiddenrtn2: void testmprofhiddenrtn2()
EOF
#
# Create our "artn" (with a more meaningful name)
#
setenv RTNA testmprofhiddenrtnA.m
cat >> $RTNA << EOF
testmprofhiddenrtnA
    write "testmprofhiddenrtnA: Entered -- driving call-in",!
    set rtnname="testmprofhiddenrtn2"
    do &drivecirtn(.rtnname)
    write "testmprofhiddenrtnA: Back in testmprofhiddenrtnA",!
    write "testmprofhiddenrtnA: Returning",!
    quit
EOF
#
# Drive main test
#
$gtm_dist/mumps -run testmprofhiddenrtn1
#
source $gtm_tst/com/dbcheck.csh
#
echo "End of test_mprof_hidden_rtn subtest"
