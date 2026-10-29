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
echo '# [YDB#1326] TSTART in direct mode with indirect arguments                                           #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# In direct mode TSTART moves part of the M stack, and the transaction id and the names of the local'
echo '# variables to restore can be in the moved part.'
echo '#'
echo '# Each stage runs its lines in direct mode in a new process, and checks its output for the lines'
echo '# named, and for no fatal error.'
echo
set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1326dm"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : TSTART with a local variable name from indirection'
echo '#   expect LABELMISSING for the DO of the label x, which does not exist in direct mode'
echo '#   previously a Release build got a SIG-11, and a Debug build failed an assert in op_tstart.c'
$dm tpindjob LABELMISSING
echo

echo '# Stage 2 : TRESTART after TSTART (job), and after TSTART @v with v="job"'
echo '#   expect the TRESTART to restore job to 1 in both cases'
echo '#   previously job was 2 after the TRESTART with TSTART @v, and a Debug build failed an assert in'
echo '#   op_tstart.c'
$dm tpindrest
echo

echo '# Stage 3 : TSTART with a transaction id that is an expression'
echo '#   expect $VIEW("TRANSACTIONID",1) to be ABCD'
echo '#   previously it was the empty string'
$dm tptid
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
