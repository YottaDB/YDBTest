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
#
echo "# Test for ydb_maxtptime env var"

#
echo '# Test that gtm_zmaxtptime=3 controls $zmaxtptime if ydb_maxtptime is undefined'
unsetenv ydb_maxtptime
setenv gtm_zmaxtptime 3
$gtm_exe/mumps -run %XCMD 'write "$zmaxtptime=",$zmaxtptime,!'

#
echo '# Test that ydb_maxtptime=4 controls $zmaxtptime if gtm_zmaxtptime is not defined'
setenv ydb_maxtptime 4
unsetenv gtm_zmaxtptime
$gtm_exe/mumps -run %XCMD 'write "$zmaxtptime=",$zmaxtptime,!'

#
echo '# Test that ydb_maxtptime=5 controls $zmaxtptime even if gtm_zmaxtptime=6 is defined'
setenv ydb_maxtptime 5
setenv gtm_zmaxtptime 6
$gtm_exe/mumps -run %XCMD 'write "$zmaxtptime=",$zmaxtptime,!'

