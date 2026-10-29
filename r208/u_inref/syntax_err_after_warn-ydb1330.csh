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
echo '# [YDB#1330] A syntax error after an invalid special variable or function name is reported          #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# An invalid intrinsic special variable or function name is a warning at compile time. A syntax error'
echo '# after it was taken to have been reported already, so it was not, and direct mode issued INDRCOMPFAIL.'
echo '#'
echo '# Each stage runs its lines in direct mode in a new process, and checks its output for the lines'
echo '# named, and for no fatal error.'
echo

set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1330dm"

echo '# Stage 1 : WRITE: with an invalid special variable name in its postconditional and a trailing space'
echo '#   expect EXPR'
echo '#   previously INDRCOMPFAIL, and an assert in linetail.c in a Debug build'
$dm swsvn EXPR
echo

echo '# Stage 2 : NEW of an invalid special variable name followed by more of the line'
echo '#   expect EXPR'
echo '#   previously INDRCOMPFAIL, and an assert in linetail.c in a Debug build'
$dm swsvn2 EXPR
echo

echo '# Stage 3 : SET @ of a string that is an invalid function name whose argument list is followed by an unterminated string literal'
echo '#   expect RPARENMISSING'
echo '#   previously INDRCOMPFAIL, and an assert in comp_fini.c in a Debug build'
$dm swfcn RPARENMISSING
echo

echo '# Stage 4 : ZCOMPILE of a routine with the lines of stages 1 and 2'
echo '#   expect INVSVN and EXPR for each line, and the object file to be written'
echo '#   previously INVSVN only, and an assert in linetail.c in a Debug build'
$dm swcompile INVSVN EXPR
echo

echo '# Stage 5 : SET with an invalid function name as a target whose argument list is followed by an unterminated string'
echo '#   literal, without indirection: alone, in an XECUTE, in a multiple target and before another target'
echo '#   expect RPARENMISSING for each line, and the line after them to run'
echo '#   previously CMD for each line'
$dm swfcn2 RPARENMISSING
echo

echo '# Stage 6 : ZCOMPILE of a routine with the first and third lines of stage 5'
echo '#   expect INVFCN and RPARENMISSING for each line, and the object file to be written'
echo '#   previously INVFCN and CMD for each line'
$dm swfcncompile INVFCN RPARENMISSING
echo

echo "# Done"
