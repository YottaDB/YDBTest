#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test ensures that alternating between setting $ZT ($ZTRAP) and
# $ET ($ETRAP) is handled correctly. The first test ($ET then $ZT)
# fails with an assert failure on versions that contain this bug.
# The second test ($ZT then $ET) should pass on all versions but
# is included to ensure that both situations are covered by the
# test system. The third test ensures that $ZT is set correctly
# when the mval it is to be set to doesn't overlap in memory with
# the stack frame pointer. It uses a ydb520.sh file because
# sourcing ydb_env_set only works under sh. The fourth test does
# the same thing as the third but without sourcing ydb_env_set.
$gtm_tst/com/dbcreate.csh mumps
echo "Testing ETRAP->ZTRAP->ETRAP->ZTRAP"
$ydb_dist/yottadb -run ydb520A
echo "Testing ZTRAP->ETRAP->ZTRAP->ETRAP"
$ydb_dist/yottadb -run ydb520B
echo "Testing setting ZTRAP after sourcing ydb_env_set"
sh $gtm_tst/$tst/u_inref/ydb520.sh
echo "Testing setting ZTRAP after setting ydb_etrap to break"
setenv ydb_etrap 'break'
$ydb_dist/yottadb -run ydb520D
