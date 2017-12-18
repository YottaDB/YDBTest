#!/usr/local/bin/tcsh -f
#################################################################
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
#
# Test of ydb_get_s() function for ISVs in the simpleAPI
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/isvget1cb.c
$gt_ld_shl_linker ${gt_ld_option_output}libisvget1cb${gt_ld_shl_suffix} $gt_ld_shl_options isvget1cb.o $gt_ld_syslibs
\rm isvget1cb.o
setenv	GTMXC	isvget1.tab
echo "`pwd`/libisvget1cb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
isvget1cb:	void	isvget1cb(I:ydb_string_t *, O:ydb_string_t *[4096])
xx
#
# Drive main M routine
#
$gtm_dist/mumps -run isvget1
