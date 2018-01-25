#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of ydb_lock_incr_s() and ydb_lock_decr_s() functions in the simpleAPI
#
$gtm_tst/com/dbcreate.csh mumps 1

#
# Simplistic function test to verify locks are obtained and released as expected
#
cp $gtm_tst/$tst/inref/incrdecr.c .
set file = incrdecr.c
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "ISVSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	continue
endif
`pwd`/$exefile

$gtm_tst/com/dbcheck.csh
