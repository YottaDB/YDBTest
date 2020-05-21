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
#
echo '# Test that LVUNDEF error displays string subscripts with surrounding double quotes\n'
set verbose
$ydb_dist/mumps -run ^%XCMD 'write x(1,"abcd",$zysqlnull,$char(2,3))'

