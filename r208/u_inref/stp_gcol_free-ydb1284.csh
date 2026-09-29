#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1284] VIEW "STP_GCOL_FREE" returns the unused part of the stringpool to the operating system  #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# VIEW "STP_GCOL_FREE" does a garbage collection of the stringpool, returns the physical memory of the'
echo '# whole pages in its unused part to the operating system with madvise(MADV_DONTNEED), and calls'
echo '# malloc_trim(0) to do the same for the free pages in the C library heap, such as those of the smaller'
echo '# stringpools freed as the stringpool expanded. The stringpool keeps its size.'
echo '#'
echo '# Each stage sets 20000 local variable nodes to 1000-byte strings, KILLs them, runs the VIEW, and'
echo '# compares VmRSS from /proc/self/status with what it was before the nodes were set. Each stage then'
echo '# sets the nodes again, to check the memory returned to the operating system is usable.'
echo '#'
echo '# Stage 3 is the control: VIEW "STP_GCOL" returns nothing to the operating system. Each stage runs'
echo '# in its own process, so each starts from a new stringpool.'
echo '#'
echo '# Stage 4 checks that $VIEW() rejects STP_GCOL_FREE, which is a VIEW command keyword only.'
echo

cp $gtm_tst/$tst/inref/ydb1284.m .

echo '# Stage 1 : VIEW "STP_GCOL_NOSORT":0, fill, KILL, then VIEW "STP_GCOL_FREE"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 0'
echo '#   expect the stringpool size to be unchanged and VmRSS back within a quarter of what the fill added'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 0
echo

echo '# Stage 2 : VIEW "STP_GCOL_NOSORT":1, fill, KILL, then VIEW "STP_GCOL_FREE"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 1'
echo '#   expect the stringpool size to be unchanged and VmRSS back within a quarter of what the fill added'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 1
echo

# Stage 3 uses a sorted garbage collection. An unsorted one copies the live strings to a new stringpool
# and frees the old one, which free() returns to the operating system when it is at the top of the heap,
# so how much memory stays resident after it depends on where the stringpools are.
echo '# Stage 3 : VIEW "STP_GCOL_NOSORT":0, fill, KILL, then VIEW "STP_GCOL"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL 0'
echo '#   expect the stringpool size to be unchanged and VmRSS to still hold most of what the fill added'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL 0
echo

echo '# Stage 4 : $VIEW("STP_GCOL_FREE")'
echo '# Command : $ydb_dist/yottadb -run fnview^ydb1284'
echo '#   expect a VIEWFN error'
$ydb_dist/yottadb -run fnview^ydb1284
echo

echo "# Done"
