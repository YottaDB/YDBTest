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
echo '# malloc_trim(0) to do the same for the free pages in the C library heap.'
echo '#'
echo '# Each stage sets 20000 local variable nodes to 1000-byte strings, KILLs most or all of them, runs the'
echo '# VIEW, and compares VmRSS from /proc/self/status with what it was before and after the nodes were'
echo '# set. Each stage then sets the nodes again, to check the memory returned to the operating system is'
echo '# usable. Each stage runs in its own process, so each starts from a new stringpool.'
echo '#'
echo '# Stages 1 to 3 KILL most of the nodes, keeping strings that add up to a third of the stringpool size.'
echo '# With that much still in use, the garbage collection leaves the stringpool size unchanged, so these'
echo '# stages measure what VIEW "STP_GCOL_FREE" itself returns.'
echo '# Stage 3 is the control: a sorted VIEW "STP_GCOL" returns nothing to the operating system.'
echo '#'
echo '# Stages 4 to 6 KILL all the nodes. A garbage collection that leaves more than 1 MiB of the stringpool'
echo '# unused above the level that triggers the next one shrinks the stringpool to that level, so then a'
echo '# plain VIEW "STP_GCOL" returns the memory too. Stages 5 and 6 check that VIEW "STP_GCOL_FREE" works'
echo '# on the smaller stringpool, after a sorted and after an unsorted garbage collection.'
echo '#'
echo '# Stage 7 checks that $VIEW() rejects STP_GCOL_FREE, which is a VIEW command keyword only.'
echo

cp $gtm_tst/$tst/inref/ydb1284.m .

echo '# Stage 1 : VIEW "STP_GCOL_NOSORT":0, fill, KILL most, then VIEW "STP_GCOL_FREE"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 0 1'
echo '#   expect the stringpool size to be unchanged and the VIEW to release most of what the KILLed strings used'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 0 1
echo

echo '# Stage 2 : VIEW "STP_GCOL_NOSORT":1, fill, KILL most, then VIEW "STP_GCOL_FREE"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 1 1'
echo '#   expect the stringpool size to be unchanged and the VIEW to release most of what the KILLed strings used'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 1 1
echo

# Stage 3 uses a sorted garbage collection. An unsorted one copies the live strings to a new stringpool
# and unmaps the old one, so it returns the unused part of the old one to the operating system too.
echo '# Stage 3 : VIEW "STP_GCOL_NOSORT":0, fill, KILL most, then VIEW "STP_GCOL"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL 0 1'
echo '#   expect the stringpool size to be unchanged and the VIEW to release little of what the KILLed strings used'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL 0 1
echo

echo '# Stage 4 : VIEW "STP_GCOL_NOSORT":0, fill, KILL all, then VIEW "STP_GCOL"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL 0 0'
echo '#   expect the stringpool to be smaller and VmRSS back within a quarter of what the fill added'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL 0 0
echo

echo '# Stage 5 : VIEW "STP_GCOL_NOSORT":0, fill, KILL all, then VIEW "STP_GCOL_FREE"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 0 0'
echo '#   expect the stringpool to be smaller and VmRSS back within a quarter of what the fill added'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 0 0
echo

echo '# Stage 6 : VIEW "STP_GCOL_NOSORT":1, fill, KILL all, then VIEW "STP_GCOL_FREE"'
echo '# Command : $ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 1 0'
echo '#   expect the stringpool to be smaller and VmRSS back within a quarter of what the fill added'
$ydb_dist/yottadb -run free^ydb1284 STP_GCOL_FREE 1 0
echo

echo '# Stage 7 : $VIEW("STP_GCOL_FREE")'
echo '# Command : $ydb_dist/yottadb -run fnview^ydb1284'
echo '#   expect a VIEWFN error'
$ydb_dist/yottadb -run fnview^ydb1284
echo

echo "# Done"
