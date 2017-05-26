#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that waitpid() does not rely on timers when they are unavailable or process is exiting.
# In the test we need to ensure that the waitpid() function is invoked while SIGALRMs are blocked,
# which is the case while we are processing a timer handler. To avoid introducing a new white-box
# test, we rely on an external call to schedule a short timer and then trigger the CLOSE of a
# previously OPENed pipe in its handler.

# Compile and link the test program.
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/waitpid_no_timer.c -g -DDEBUG
$gt_ld_shl_linker ${gt_ld_option_output}libwaitpid_no_timer${gt_ld_shl_suffix} $gt_ld_shl_options waitpid_no_timer.o $gt_ld_syslibs -L$gtm_dist -lgtmshr

# Make sure libgtmshr.so can be found.
if (! ($?LD_LIBRARY_PATH) ) setenv LD_LIBRARY_PATH ""
if (! ($?LIBPATH) ) setenv LIBPATH ""
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${gtm_dist}
setenv LIBPATH ${LIBPATH}:${gtm_dist}

# Define the environment and create mapping tables.
setenv GTMXC_waitpid waitpid_no_timer_co.tab
echo "`pwd`/libwaitpid_no_timer${gt_ld_shl_suffix}" > $GTMXC_waitpid
cat >> $GTMXC_waitpid << EOF
wpthco:	gtm_int_t waitpid_timer_handler(I:gtm_int_t)
EOF
setenv GTMCI waitpid_no_timer_ci.tab
cat > $GTMCI << EOF
wpthci: void close^waitpidnotimer()
EOF

# Start the test program.
$gtm_dist/mumps -run waitpidnotimer
