#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

setenv ydb_msgprefix "GTM"   # So can run the test under GTM or YDB

# Set OS memory limit to cause failure. Note: 'limit memoryuse' does not appear to do anything
# Note: A value of 200Mb causes occasional NONUTF8LOCALE errors on RHEL 10 with -unicode. Hence the 400Mb choice.
source $gtm_tst/com/limit_vmemoryuse.csh 400M
limit coredumpsize 0M   # We don't need coredumps for this test

$gtm_dist/mumps -run mallocLimit

# remove YDB_FATAL_ERROR files as we know there there -- and GTM doesn't produce them
find -name "YDB_FATAL_ERROR.*.txt" -delete
