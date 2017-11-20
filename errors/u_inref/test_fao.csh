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
echo ""
echo "Start fao testing"
if ( ! -d $gtm_obj ) then
	echo "TEST-E-CONFIGURATION error.  The directory $gtm_obj does not exist."
	exit 1
endif
\rm -rf *.o* runfaotest
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_inc $gtm_tst/$tst/inref/test_fao.c >& compiler.out
if ($status) then
	echo "TEST-E-CC Error from Compiler ($gt_cc_compiler).  See file compiler.out for details"
	exit 1
endif
# Don't change the following gt_cc_compiler to gt_ld_linker -- hppa needs gt_cc_compiler
$gt_cc_compiler $gt_ld_options_common -o runfaotest test_fao.o -L$gtm_obj -lmumps $gt_ld_extra_libs $gt_ld_syslibs >& linker.out
if ($status) then
	echo "TEST-E-LINK Error from Linker ($gt_cc_compiler).  See file linker.out for details"
	exit 1
endif

setenv LD_LIBRARY_PATH $gtm_dist
setenv LIBPATH $gtm_dist

chmod +x runfaotest

runfaotest >& out.log
# grep the values printed by "printf". These values will be used as reference to check correctness of util_out_print
# Address in Hex
set hexaddr = `$grep Memory out.log | cut -d" " -f5`
# Address in Decimal
set decaddr = `$grep Memory out.log | cut -d" " -f6`
# Signed address value
set sdecaddr = `$grep Memory out.log | cut -d" " -f7`

# The adress values will be different in different runs and platforms
# Replace address values with constants so that reference file comparison is easy
# We use output from printf to compare util_out_prints output
# If sed fails replacing the values; util_out_print has produced unexpected values and hence the test should fail
# util_out_print will zero extend hex value. printf will not print zero extended hex values.
# sed takes care of this by ignoring any prefixed zeros
sed "s/[0]*$hexaddr/XXXX/g; s/$sdecaddr/YYYY/g; s/$decaddr/YYYY/g" out.log > out1.log
cat out1.log

# Store the address values for debug purpose.
# So out.log will have output of runfaotest plus following line
echo "Hexaddr $hexaddr Decaddr $decaddr Sdecaddr $sdecaddr" >> out.log
echo "End fao testing"
echo ""
