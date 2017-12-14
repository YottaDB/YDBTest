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
# Test of ydb_get_s() function for Local variables in the simpleAPI
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/lvnget1cb.c
$gt_ld_shl_linker ${gt_ld_option_output}liblvnget1cb${gt_ld_shl_suffix} $gt_ld_shl_options lvnget1cb.o $gt_ld_syslibs
\rm lvnget1cb.o
setenv	GTMXC	lvnget1.tab
echo "`pwd`/liblvnget1cb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
lvnget1cb:		void	lvnget1cb()
xx
#
# Drive main M routine
#
$gtm_dist/mumps -run lvnget1
#
