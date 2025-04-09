#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
YDB#1128 - Test the following release note
********************************************************************************************

Release note (from https://gitlab.com/YottaDB/DB/YDB/-/issues/1128):

A MUPIP STOP does not terminate DSE, LKE and MUPIP processes if they hold the critical section for a database file. Previously, if \$ydb_readline was 1 or an equivalent value, it would incorrectly terminate the process. Note that a sequence of three MUPIP STOP signals sent within one minute continue to terminate the process even if it holds a critical section. [#1128 (closed)]

CAT_EOF
echo

setenv ydb_readline 1

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
(expect -d $gtm_tst/$tst/u_inref/mupipstop_readlineterm-ydb1128.exp $gtm_dist > expect.tmp) >& expect.dbg
cat expect.tmp | sed 's/\r//g'
