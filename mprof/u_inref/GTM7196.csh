#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

###################################################################################
# This subtest verifies the fix for a long-standing memory leak issue with MPROF. #
# The cause of the issue was allocation and no subsequent freeing of space for    #
# label and route names during unwinds. Those strings are created so that we      #
# could compare them with entries stored in the AVL tree and store, if necessary. #
###################################################################################

# This test uses memleak.m which relies on $zrealstor to determine how much of memory is used.
# That ISV is 0 in case we use system malloc/free (instead of the default YottaDB memory manager).
# And will cause a test failure in that case. So ensure we do use the YottaDB malloc/free.
source $gtm_tst/com/set_gtmdbglvl_to_use_yottadb_malloc_free.csh

$gtm_tst/com/dbcreate.csh .

echo ""

$gtm_dist/mumps -run memleak

echo ""

$gtm_tst/com/dbcheck.csh
