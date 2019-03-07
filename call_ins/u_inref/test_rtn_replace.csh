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
#   4. A new version of "artn" created and driven.
#   5. The zlput_rname() routine looks back through the stack to see if a version
#      of "artn" exists on the stack. V63001A_R100 and earlier don't find the routine
#      as the search stops at the call-in boundary. This can cause the original artn
#      to explode most spectacularly. Post V63001A_R100 should find the routine and
#      "fork" the routine so the old routine stays around until it pops off the stack
#      while the new routine takes its place for all other matters.
#
# Test logic:
#   - If this test completes without a fatal exit producing a core file, then the test
#     passes.
#   - Else it fails. The presence of the core itself will result in test failure.
#
# Note this test fails with any version previous to V63002_R110.
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
setenv GTMCI testrtnreplc2.xc
cat >> $GTMCI << EOF
testrtnreplc2: void testrtnreplc2()
EOF
#
# Create our "artn" (with a more meaningful name)
#
setenv RTNA testrtnreplcA.m
cat >> $RTNA << EOF
testrtnreplcA
    write "testrtnreplcA: Entered -- driving call-in",!
    set rtnname="testrtnreplc2"
    do &drivecirtn(.rtnname)
    write "testrtnreplcA: Back in testrtnreplcA",!
    write "testrtnreplcA: Driving ^testrtnreplc3",!
    do ^testrtnreplc3
    write "testrtnreplcA: Use variables to see if l_symtab was corrupted",!
    set d=a*2,e=b*c,f=a+b+c+d+e   ; Some variable play to access some vars that went inaccessible if routine was replaced
    write "testrtnreplcA: Returning",!
    quit
EOF
#
# Drive main test
#
$gtm_dist/mumps -run testrtnreplc1
#
echo "End of test_rtn_replace subtest"
