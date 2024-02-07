#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# gtm9422 - Show that former toggle statistics are now counters'
echo '#'
echo '# The following statistics (ZSHOW "G") are changed from being toggle switches (value 1 while the'
echo '# condition is active otherwise contain 0) to counters that are incremented whenever the condition'
echo '# occurs: DEXA, GLB, JNL, MLK, PRC, TRX, ZAD, JOPA, AFRA, BREA, MLBA, TRGA'
echo '#'
echo '# This test launches 12 worker bee processes to cause at least some of these stats to accumulate.'
echo '# We verify that the counts are always increasing instead of going up and down with toggle stats.'

setenv acc_meth "BG"		# Need BG for the GLB stat
setenv gtm_test_jnl SETJNL	# We want this DB to be journaled as journal crit stats are being monitored
setenv tst_jnl_str -journal=enable,on,nobefore

echo
echo '# Create database'
# Keep small values of allocation/extension as that greatly increases the chances of DEXA and AFRA statistic being non-zero,
# something the test expects. We have seen occasional failures where DEXA/AFRA were 0 with default allocation/extension.
$gtm_tst/com/dbcreate.csh mumps -allocation=50 -extension_count=5
echo
echo '# Enable stat sharing'
$MUPIP set -stats -region "*"
echo
echo '# Drive gtm9422 test routine'
$gtm_dist/mumps -run gtm9422
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
