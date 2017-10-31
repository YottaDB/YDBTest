#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

######################################################################################
# This test verifies that repetitive invocations of gtm_init() do not cause M stack  #
# overflows. The test fires up a C routine that calls gtm_init() and gtm_ci() in     #
# succession a 100,000 times.                                                        #
######################################################################################

# Set the call-in table.
setenv GTMCI stack_leak.tab
cat > $GTMCI << EOF
stackLeak	:void stackLeak^stackLeak(I:gtm_int_t)
EOF

# Compile and link stack_leak.c.
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/stack_leak.c -I$gtm_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output stack_leak $gt_ld_options_common stack_leak.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map

# Invoke the executable.
stack_leak >&! stack_leak.out

# Unset GTMCI.
unsetenv $GTMCI
