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
echo '# [YDB#1375] A STACKCRIT error inside nested triggers leaves the symbol table of the caller          #'
echo '# unchanged                                                                                          #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A trigger on ^c sets ^c again, so a SET of ^c nests triggers until the M stack is nearly full and'
echo '# the next trigger invocation fails with a STACKCRIT error. The M stack is set to the minimum size'
echo '# (gtm_mstack_size=25) so that happens after a few nested triggers. ydb1375.m replaces the trigger'
echo '# with one whose code has 0 to 200 more SET commands (which changes how much M stack each trigger'
echo '# level uses, and so the point in the trigger invocation where the STACKCRIT error occurs), sets ^c'
echo '# twice for each size and catches the errors with $ETRAP. After each size, ydb1375.m checks that the'
echo '# local variable "top", set before the first trigger, is still visible.'
echo
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
if ($status) then
	echo "FAIL : dbcreate.csh failed - see dbcreate.out"
endif
setenv gtm_mstack_size 25
echo '# Command : $gtm_dist/mumps -run ydb1375'
echo '# Before the fix : a Release build shows $data(@"top")=0, and a Debug build fails an assert in'
echo '#                  unw_mv_ent.c'
echo '# With the fix   : PASS'
$gtm_dist/mumps -run ydb1375 >& ydb1375.out
unsetenv gtm_mstack_size
if (`$grep -c -- "-F-" ydb1375.out`) then
	echo "FAIL : ydb1375.out has a fatal error"
else
	echo "PASS : no fatal error in ydb1375.out"
endif
$grep -E "^(PASS|FAIL) " ydb1375.out
if (! `$grep -c "^PASS " ydb1375.out`) then
	echo "FAIL : ydb1375.out does not have a PASS line - see ydb1375.out"
endif
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "FAIL : dbcheck.csh failed - see dbcheck.out"
endif
