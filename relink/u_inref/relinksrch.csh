#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
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

# This is a test of correct population of relink-control files up to supported limits. It invokes an M
# program that fires up multiple jobs to ZRUPDATE object files randomly distributed across several directories.

$gtm_tst/com/dbcreate.csh mumps

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_linktmpdir gtm_linktmpdir `pwd`

@ numdirs = 10
@ numjobs = 5
@ numobjs = 101

echo " " > relinksrchtmp.m
$gtm_dist/mumps relinksrchtmp.m

# Create $numobjs object files in each of $numdirs directories.
@ num = 1
while ($num <= $numdirs)
	mkdir -p dir$num
	@ objs = 1
	while ($objs <= $numobjs)
		cp relinksrchtmp.o dir$num/relinksrch$objs.o
		@ objs++
	end
	@ num++
end

# This white-box test sets the maximum number of relinkctl entries at 100.
setenv gtm_white_box_test_case_number 117
setenv gtm_white_box_test_case_enable 1

$gtm_dist/mumps -run relinksrch $numdirs $numjobs $numobjs

# Although more than one process may potentially error out, we expect exactly one RELINKCTLFULL
# error because the process that encounters it overwrites the file.
$gtm_tst/com/check_error_exist.csh rctlerror.log RELINKCTLFULL

setenv gtm_white_box_test_case_enable 0

$gtm_tst/com/dbcheck.csh
