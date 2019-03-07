#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
unsetenv test_replic
unsetenv gtm_exe
unsetenv ydb_dist
unsetenv gtm_dist
$GTM << aaa
W "Testing YottaDB Startup check ...",!
aaa
find . -type f -a \( -name 'core*' -o -name 'gtmcore*' \) -print >& CORE.list
if !($status) then
	if (-z CORE.list) then
		echo "TEST PASSED"
	else
		echo "TEST FAILED"
		echo "Core found"
		cat CORE.list
	endif
endif
