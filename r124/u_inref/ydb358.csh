#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that ASYNCIO writes in SimpleAPI/SimpleThreadAPI parent and child work fine (no DBIOERR error)"
echo ""

echo "# Create ASYNCIO=ON database"
setenv gtm_test_mupip_set_version "disable"     # ASYNCIO and V4 format don't go together. So, disable creating V4 formats
setenv acc_meth BG				# ASYNCIO and MM is not supported
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif
# Currently dbcreate.csh does not have a way to enable ASYNCIO. So do that manually after the dbcreate.
$ydb_dist/mupip set -asyncio -reg "*"
echo ""

echo "# Verify flush timer is 1 second (ydb358.c relies on this when it waits for 2 seconds)"
$ydb_dist/dse dump -file |& grep "Flush timer"
echo ""

set file="ydb358.c"
set exefile = $file:r
echo "# Compiling/Linking $file into executable $exefile and executing it"
cp $gtm_tst/$tst/inref/$file .
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "$exefile-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	exit -1
endif
`pwd`/$exefile
echo "$exefile returned with exit status : $status"

$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
