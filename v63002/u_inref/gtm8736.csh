#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Tests that $zroutines defaults to $ydb_dist/libyottadbutil.so when ydb_routines/gtmroutines is not defined'
#

unsetenv ydb_routines
unsetenv gtmroutines
$ydb_dist/mumps -direct << MUMPS_EOF
	zwrite \$zroutines
MUMPS_EOF
