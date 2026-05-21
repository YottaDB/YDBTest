#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# db volume test
# Limit the compression value to 6 <compression_level_high_issues>
if ($?gtm_test_replay) then
	# sourcing of the replay script would have been done already. No need to do anything now.
else if ( ($?gtm_zlib_cmp_level) ) then
	if ( ($gtm_zlib_cmp_level > 6) ) then
		set cmp_val = 6
		echo "# Resetting compression level at the test level"	>> settings.csh
		echo "setenv gtm_zlib_cmp_level $cmp_val"		>> settings.csh
		setenv gtm_zlib_cmp_level $cmp_val
	endif
endif
$gtm_tst/com/dbcreate.csh mumps 1 125 500 . 30000

$GTM << xyz
s ^tp="$gtm_test_tp"
s ^LFE="$LFE"
view "gdscert":1
do ^drive
halt
xyz

$gtm_tst/com/dbcheck.csh -extract
echo "# Check for journal output files for failures. Up to 3 failures are accepted for a given test case"
echo "# per 'ermax' variable in 'inref/volkill.m. So, only flag a failure on the third failure in any given routine."
echo "# Expect no files to be listed and a PASS message to be issued below."
$grep -l "^\*\* FAIL 3" volk*.mjo* || echo "PASS: No failed routines"
echo "# Check for completed routines, expect 9:"
$grep -l COMPLETE volk*.mjo*
cat volk*.mje*
