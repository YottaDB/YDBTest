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
echo '# Test of an extended reference that gets a NETDBOPNERR error as the first database access when $ydb_gbldir is not set'
echo '# Before #356 fixes, this used to SIG-11'
echo '# Expect only a NETDBOPNERR error below, no SIG-11'

set verbose
unsetenv gtmgbldir

setenv ydb_gbldir mumps.gld

$ydb_dist/mumps -run GDE change -seg DEFAULT -file=dummyhostname:mumps.dat

unsetenv ydb_gbldir

$ydb_dist/mumps -run ^%XCMD 'set ^|"mumps.gld"|a=1'

