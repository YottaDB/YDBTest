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
echo '# [YDB#1325] NEW $ZTRAP that fails with STACKCRIT leaves $ZTRAP usable                               #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# When $ZTRAP was explicitly null, NEW $ZTRAP set the length of $ZTRAP to -1, a marker for the saved'
echo '# copy, before saving $ZTRAP. A STACKCRIT error from the NEW left that -1 in $ZTRAP, so a later error'
echo '# ran garbage as the error trap.'
echo '#'
echo '# Each stage runs the lines shown in direct mode in a new process, and checks the output for the lines'
echo '# named, and for no fatal error.'
echo

set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1325dm"
# The lines assume no $ETRAP from the environment
source $gtm_tst/com/unset_ydb_env_var.csh ydb_etrap gtm_etrap

echo '# Stage 1 : NEW $ZTRAP in a FOR loop until the M stack is full, then an error'
echo '# Before the fix : a Release build ran garbage as the error trap, issuing INDRMAXLEN and ERRWETRAP,'
echo '#                  and a Debug build failed an assert in mdb_condition_handler.c'
echo '# With the fix   : expect STACKCRIT, and no error trap to run garbage'
$dm ztnew STACKCRIT
echo

echo '# Stage 2 : NEW $ZTRAP in a FOR loop until the M stack is full, then WRITE $ZTRAP'
echo '# Before the fix : a Release build terminated with a SIG-11 or wrote garbage, and a Debug build'
echo '#                  failed an assert in mdb_condition_handler.c'
echo '# With the fix   : expect STACKCRIT, and no fatal error. A line after the STACKCRIT can get a'
echo '#                  second STACKCRIT (for example in a Debug build, which needs more stack to compile'
echo '#                  the line) and the process then exits, so the stage checks only for STACKCRIT and'
echo '#                  no fatal error.'
$dm ztuse STACKCRIT
echo

echo "# Done"
