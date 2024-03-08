#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################


# Set OS memory limit to cause failure. Note: 'limit memoryuse' does not appear to do anything
source $gtm_tst/com/limit_vmemoryuse.csh 120M   # premature failures below 56M and, in occasional circumstances, at 100M
limit coredumpsize 0M   # We don't need coredumps for this test

$gtm_dist/mumps -run mallocLimit
