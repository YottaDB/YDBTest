#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test verifies that a simpleapi call doing an update that drives a trigger that gets an
# error recovers properly instead of assert failing as happens on r1.28 and earlier.
$gtm_tst/com/dbcreate.csh "mumps"
$ydb_dist/mumps -run ^%XCMD 'if $ztrigger("item","+^gbl -commands=S -xecute=""do ^gbl""")'
# Compile and link ydb500.c.
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/ydb500.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output ydb500 $gt_ld_options_common ydb500.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map
echo "----------------------------------------------------------------------"
echo "Verify making simpleapi call that drives a trigger which gets an error"
echo "properly recovers and returns:"
echo "**********"
./ydb500
echo "----------------------------------------------------------------------"
#
$gtm_tst/com/dbcheck.csh
