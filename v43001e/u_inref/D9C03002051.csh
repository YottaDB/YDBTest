#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##################################
#D9C03-002051 [Mohammad] mupip set -extension_count and standalone access
##################################
echo "Begin of D9C03002051 subtest"
$gtm_tst/com/dbcreate.csh mumps 1 255 1000
$DSE dump -fileheader >&! dse_dump_1.out
$tst_awk '/Extension Count/ {print $5,$6,$7}' dse_dump_1.out
echo "Try to change extension_count, which will succeed"
$MUPIP set -extension_count=300 -file mumps.dat
$DSE dump -fileheader >&! dse_dump_2.out
$tst_awk '/Extension Count/ {print $5,$6,$7}' dse_dump_2.out
#
echo "Multi-processes start in the background"
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 2
$gtm_tst/com/imptp.csh >&! imptp1.out
echo "Now try to change -extension_count, which will also succeed"
echo "MUPIP set -extension_count=400 -file mumps.dat"
$MUPIP set -extension_count=400 -file mumps.dat
$DSE dump -fileheader >&! dse_dump_3.out
$tst_awk '/Extension Count/ {print $5,$6,$7}' dse_dump_3.out
#
echo "Now try to change extension_count with global_buffer which needs standalone access"
echo "MUPIP set -extension_count=500 -global_buffer=2048 -file mumps.dat"
set output = "set_extension_count_1.out"
$MUPIP set -extension_count=500 -global_buffer=2048 -file mumps.dat >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-W-WCWRNNOTCHG' ${output}x >&! $output

echo "MUPIP set -extension_count=500 -global_buffer=2048 -reg "'"*"'
set output = "set_extension_count_2.out"
$MUPIP set -extension_count=500 -global_buffer=2048 -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-W-WCWRNNOTCHG' ${output}x >&! $output

$DSE dump -fileheader >&! dse_dump_4.out
$tst_awk '/Extension Count/ {print $5,$6,$7}' dse_dump_4.out
#
echo "Stop the background processes"
$gtm_tst/com/endtp.csh  >>& endtp1.out
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/checkdb.csh
#
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
echo "MUPIP set -extension_count=600 -global_buffer=2048 -file mumps.dat"
$MUPIP set -extension_count=600 -global_buffer=2048 -file mumps.dat
$DSE dump -fileheader >&! dse_dump_5.out
$tst_awk '/Extension Count/ {print $5,$6,$7}' dse_dump_5.out
echo "End of D9C03002051 subtest"
