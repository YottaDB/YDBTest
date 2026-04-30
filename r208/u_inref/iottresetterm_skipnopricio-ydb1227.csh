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

echo "#---------------------------------------------------------------------------------------------------------------------#"
echo '# [#938] Test skip issuing NOPRINCIO error in iott_resetterm.c if exiting (fixes SIG-11)                              #'
echo '# See the MR description for YDB\1859 for additional details: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1859 #'
echo "#---------------------------------------------------------------------------------------------------------------------#"
echo

set tname = ydb1227
echo '# Run [$ydb_dist/yottadb -run %XCMD '"'read *x' > '"$tname"'.out]"
unsetenv ydb_readline
(expect -d $gtm_tst/$tst/u_inref/iottresetterm_skipnopricio-ydb1227.exp $tname > $tname.exp.out) >& $tname.exp.dbg
echo '# Expect no SIG-11. Prior to the YDB\!1859 (commit YDB@de1fee28) changes, a SIG-11 would occur.'
perl $gtm_tst/com/expectsanitize.pl ${tname}.exp.out >& ${tname}.exp.sanitized.out
cat ${tname}.exp.sanitized.out
cat ydb1227.out
