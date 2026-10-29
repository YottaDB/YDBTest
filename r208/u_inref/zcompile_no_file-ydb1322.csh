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
echo '# [YDB#1322] ZCOMPILE with qualifiers but no file name prompts for one after an earlier ZCOMPILE     #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A ZCOMPILE with qualifiers but no file name used the state left by an earlier ZCOMPILE, and so did not'
echo '# prompt for a file name.'
echo '#'
echo '# Each stage runs its lines in direct mode in a new process, and checks its output for the lines'
echo '# named, and for no fatal error.'
echo
set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1322dm"

echo '# Stage 1 : ZCOMPILE with qualifiers but no file name, after a ZCOMPILE of a file'
echo '#   expect the second ZCOMPILE to prompt for the file name, and to compile okrtn.m, the next line'
echo '#   previously a Release build issued FILEPARSE with a garbage file name and FILEPATHTOOLONG without'
echo '#   prompting, and a Debug build failed an assert in zl_cmd_qlf.c'
$dm zcnofile FILENOTFND
echo

echo '# Stage 2 : two ZCOMPILEs with qualifiers but no file name, each answering the prompt with a file name'
echo '#   expect both ZCOMPILEs to prompt for the file name, and to compile okrtn1.m and okrtn2.m'
echo '#   previously the second ZCOMPILE did not prompt, as in stage 1, because the first left its prompted'
echo '#   file name marked as already returned'
$dm zcprompt2
echo

echo "# Done"
