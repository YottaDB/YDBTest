#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

echo
echo "# This is an automated test of https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1909#note_1830824327"
echo

setenv ydb_msgprefix "GTM"   # So can run the test under GTM or YDB

echo "# Limit vmemoryuse to 200,000 for this test"
# set memorylimit = `$gtm_dist/mumps -run %XCMD 'write (100+$random(200))*1000,!'`
# echo $memorylimit > memorylimit.txt	# store the randomly chosen memory limit in a file in case needed later
# source $gtm_tst/com/limit_vmemoryuse.csh $memorylimit
source $gtm_tst/com/limit_vmemoryuse.csh 400000

echo "# Run [mumps -run stpgcolsrcAssert]"
echo "# When run with GT.M V7.0-002 Debug build, we have seen this test fail an assert in stp_gcol_src.h"
echo "# When run with YottaDB, we have not seen this test fail. But since this test seems to be exercising"
echo "# an assert in a pure GT.M build, it is considered good enough to be included as an automated test case".
$gtm_dist/mumps -run stpgcolsrcAssert

source $gtm_tst/com/limit_vmemoryuse.csh 0	# reset memory limits before "find" command below as otherwise on
						# RHEL 9, we have seen "find: No match" error from tcsh due to running
						# into memory limits while trying to expand the "*" in "find *".

# If there are any YDB_FATAL_ERROR* or GTM_FATAL_ERROR* files, move them away so test framework does not flag a false failure.
find * -type f -name "YDB_FATAL_ERROR.*.txt" -exec mv '{}' orig_'{}' \;
find * -type f -name "GTM_FATAL_ERROR.*.txt" -exec mv '{}' orig_'{}' \;

