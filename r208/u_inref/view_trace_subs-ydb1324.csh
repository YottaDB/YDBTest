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
echo '# [YDB#1324] VIEW "TRACE" into a global with 26 or 27 subscripts                                     #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A global name with 26 or more subscripts overran the array that holds the name, as M profiling adds'
echo '# up to 5 subscripts of its own.'
echo '#'
echo '# Each stage runs its lines in direct mode in a new process, and checks its output for the lines'
echo '# named, and for no fatal error.'
echo
set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1324dm"
# The test framework can turn on M profiling for every process through the environment, which would change the results
source $gtm_tst/com/unset_ydb_env_var.csh ydb_trace_gbl_name gtm_trace_gbl_name
# A key size of 1019 so that the profile of a global with 26 subscripts fits in a key
$gtm_tst/com/dbcreate.csh mumps 1 1019 4000 4096 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : VIEW "TRACE" into a global with 26 subscripts, the most that leaves room for the 5 that'
echo '#           M profiling adds'
echo '#   expect the profile to be saved'
echo '#   previously a Release build got a SIG-11, and a Debug build got a SIG-11 or failed an assert in callg.c'
$dm vtsubs26
echo

echo '# Stage 2 : VIEW "TRACE" into a global with 27 subscripts'
echo '#   expect MAXNRSUBSCRIPTS, and no profile to be saved'
echo '#   previously a Release build got a SIG-11, and a Debug build got a SIG-11 or failed an assert in callg.c'
$dm vtsubs27 MAXNRSUBSCRIPTS
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
