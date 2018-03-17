#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test for ydb_gbldir env var"

#
echo '# Test that gtmgbldir=x1.gld controls $zgbldir if ydb_gbldir is undefined'
unsetenv ydb_gbldir
setenv gtmgbldir x1.gld
$gtm_exe/mumps -run %XCMD 'write "$zgbldir=",$zgbldir,!'

#
echo '# Test that ydb_gbldir=x2.gld controls $zgbldir if gtmgbldir is not defined'
setenv ydb_gbldir x2.gld
unsetenv gtmgbldir
$gtm_exe/mumps -run %XCMD 'write "$zgbldir=",$zgbldir,!'

#
echo '# Test that ydb_gbldir=x3.gld controls $zgbldir even if gtmgbldir=y3.gld is defined'
setenv ydb_gbldir x3.gld
setenv gtmgbldir y3.gld
$gtm_exe/mumps -run %XCMD 'write "$zgbldir=",$zgbldir,!'

