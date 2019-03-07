#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ydb_env_set only works in sh, which is why this csh redirects to ydb395.sh
#
# First we need to initialize a global database
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, output below:"
	cat dbcreate.out
endif

unsetenv ydb_log gtm_log
# Now run the sh script
sh $gtm_tst/$tst/u_inref/ydb395.sh

# Close database
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
if ($status) then
	echo "DB Check Failed, output below:"
	cat dbcheck.out
endif
