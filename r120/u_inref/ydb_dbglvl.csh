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
echo "# Test for ydb_dbglvl env var"

#
echo '# Test that gtmdbglvl=2 (print usage statistics at process end) controls ydbDebugLevel if ydb_dbglvl is undefined'
unsetenv ydb_dbglvl
setenv gtmdbglvl 2
$gtm_exe/mumps -run %XCMD 'write "ydbDebugLevel=",ydbDebugLevel,!' |& $grep "small storage performance"

#
echo '# Test that ydb_dbglvl=2 (print usage statistics at process end) controls ydbDebugLevel if gtmdbglvl is not defined'
setenv ydb_dbglvl 2
unsetenv gtmdbglvl
$gtm_exe/mumps -run %XCMD 'write "ydbDebugLevel=",ydbDebugLevel,!' |& $grep "small storage performance"

#
echo '# Test that ydb_dbglvl=2 (print usage statistics at process end) controls ydbDebugLevel even if gtmdbglvl=4 (trace every malloc/free) is defined'
setenv ydb_dbglvl 2
setenv gtmdbglvl 4
$gtm_exe/mumps -run %XCMD 'write "ydbDebugLevel=",ydbDebugLevel,!' |& $grep "small storage performance"

