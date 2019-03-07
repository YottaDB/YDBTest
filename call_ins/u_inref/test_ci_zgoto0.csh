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
#   1. A routine "artn" is on the M call stack.
#   2. That routine or some subsequent routine does an external call.
#   3. The external call does a call-in back into M mode.
#   4. The call-in does a ZGOTO 0 which should return immediately to the caller.
#
# (This test is a stripped down version of test_rtn_replace)
#

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
setenv GTMCI testcizgoto0.xc
cat >> $GTMCI << EOF
testcizgoto02: void testcizgoto02()
EOF
#
# Create our "artn" (with a more meaningful name)
#
setenv RTNA testcizgoto0A.m
cat >> $RTNA << EOF
testcizgoto0A
    write "testcizgoto0A: Entered -- driving first call-in",!
    set rtnname="testcizgoto02"
    do &drivecirtn(.rtnname)
    write "testcizgoto0A: Back in testcizgoto0A",!
    write "testcizgoto0A: Returning",!
    quit
EOF
#
# Drive main test
#
$gtm_dist/mumps -run testcizgoto01
#
echo "End of test_ci_zgoto0 subtest"
