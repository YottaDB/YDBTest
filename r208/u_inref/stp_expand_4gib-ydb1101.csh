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
echo '# [YDB#1101] A string pool expansion that copies more than 2GiB of live strings at once completes in #'
echo '# a Debug build                                                                                      #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# When the string pool expands, the sorting garbage collection copies each contiguous block of live'
echo '# strings into the new string pool with one memcpy(). With more than 2GiB of live strings, a block'
echo '# could be larger than 2GiB, and in a Debug build memcpy() asserts that its length is at most 2GiB.'
echo '# The routine creates 4.4GB of live strings. The process needs about 10GiB of memory at its peak,'
echo '# which is why r208/instream.csh excludes this subtest on systems with less than 16GiB.'
echo '# ydb_stp_gcol_nosort, which do_random_settings.csh sets at random, is set to 0 here, as the other'
echo '# garbage collection mode copies one string at a time and so never copies more than 2GiB at once.'
echo '# Before the fix, a Debug build failed the assert in gtm_memcpy_validate_and_execute.c'
echo '#   expect the routine to complete in Debug and Release builds'
echo

setenv ydb_stp_gcol_nosort 0
setenv gtm_stp_gcol_nosort 0
cp $gtm_tst/$tst/inref/ydb1101stp.m .

echo '# Command : $ydb_dist/yottadb -run ydb1101stp'
$ydb_dist/yottadb -run ydb1101stp
