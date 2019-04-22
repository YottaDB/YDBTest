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
# Test of simulated banking transactions using threaded tp calls
#
#

echo '# Test of simulated banking transactions using SimpleAPI with 10 threads in ONE process'

#SETUP of the driver C file
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/pseudoBank.c
$gt_ld_linker $gt_ld_option_output pseudoBank $gt_ld_options_common pseudoBank.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& pseudoBank.map

$gtm_tst/com/dbcreate.csh mumps
$MUPIP set -region "*" -flush_time=1:0:0:0

# Run driver C
`pwd`/pseudoBank

cp $gtm_tst/com/pseudoBankDisp.m .
$gtm_dist/mumps -r pseudoBankDisp

$gtm_tst/com/dbcheck.csh
