#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test $VIEW("ENVIRONMENT") under varying environmental conditions (M code, trigger, callin, etc).
#
setenv gtm_test_trigger 0	# Disable auto-generated triggers to make our trigger output below more predictable
source $gtm_tst/com/dbcreate.csh mumps
#
# Create a simple trigger to execute our $VIEW() function
#
cat << EOF >> environment.trg
-*
+^A -command=S -xecute="write ""\$VIEW(""""ENVIRONMENT"""")="",\$VIEW(""ENVIRONMENT""),!,""M-Stack follows:"",! zshow ""S"""
EOF
#
# Create simple call-out (aka external call) that wants to do a call-in
#
setenv GTMXC drivecirtn.xc
echo "`pwd`/libdrivecirtn${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << EOF
drivecirtn: void drivecirtn(I:gtm_char_t *)
EOF
#
# Create simple call-in
#
setenv GTMCI environci.xc
cat >> $GTMCI << EOF
environci: void environci^environment()
EOF
#
# Build shared library to hold the external call in
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/environci.c
$gt_ld_shl_linker ${gt_ld_option_output}libenviron${gt_ld_shl_suffix} $gt_ld_shl_options environci.o $gt_ld_syslibs >& link1.map
if (0 != $status) then
    cat link1.map
endif
#
# Add our trigger to our database (which should replicate over)
#
$MUPIP trigger -triggerfile=environment.trg -noprompt
$gtm_dist/mumps -run environment
echo
#
# Close down replication
#
source $gtm_tst/com/dbcheck.csh
#
# Locate one additional message in update process log
#
echo
setenv start_time `cat start_time`
set dlr = '$'
echo "Looking for message from update process trigger giving value for ${dlr}VIEW(""ENVIRONMENT""):"
$grep VIEW $SEC_SIDE/RCVR_${start_time}.log.updproc | grep "ENVIRONMENT"
#
echo "End of environment subtest"
