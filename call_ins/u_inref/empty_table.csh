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

#####################################################################################################
# Test that specifying an empty call-in table does not cause SIG-11s if a call is made from C to M. #
#####################################################################################################

# Set GTMCI; since we are not calling M functions, keep it empty.
setenv GTMCI empty_table.ci
touch $GTMCI

# Compile and link empty_table.c.
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/empty_table.c -I$gtm_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output empty_table $gt_ld_options_common empty_table.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
endif
rm -f link.map

# Invoke the executable.
empty_table

# Unset GTMCI.
unsetenv $GTMCI
