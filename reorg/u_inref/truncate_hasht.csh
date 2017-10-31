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
setenv test_reorg NON_REORG
setenv gtm_test_mupip_set_version "V5"
$gtm_tst/com/dbcreate.csh mumps 3 -block_size=1024	# The truncate tests below are sensitive to block layout
$gtm_dist/mumps -run truncatehasht

# Truncate each database file
$MUPIP reorg -truncate |& $grep -E "Truncated|TRUNC|#t"

$gtm_tst/com/dbcheck.csh
