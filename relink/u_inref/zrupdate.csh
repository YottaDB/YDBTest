#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
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
#
#####
# Copy all files associated with this subtest into working directory, and strip the "subtestname-" prefix.
source $gtm_tst/$tst/u_inref/unpack_subtest_files.csh "zrupdate" `pwd`
#####

# Take a copy of the template, so we can repeatedly fill in base.m
cp base.m base.m.template

cp bar.edit.m bar2.edit.m
$gtm_exe/mumps -run %XCMD 'ZCompile "bar2.edit"'

setenv gtmroutines '.* '"$gtmroutines"

# Drive test
$gtm_exe/mumps -run zrupdate
