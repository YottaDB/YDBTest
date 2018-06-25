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
#
#

$MULTISITE_REPLIC_PREPARE 3
setenv gtm_repl_instance "./gbl_dir1/mumps.repl"
#$ydb_dist/mumps -run gtm4212
setenv ydb_gbldir "mumps.gld"

# Make DB 1 with global directory of gbl_dir1
$gtm_tst/com/dbcreate.csh gbl_dir1/mumps 2 >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif

#The replic instance file will be changed in gtm8182.m
#setenv gtm_repl_instance "GARBAGE VALUE"
#setenv ydb_gbldir "./gbl_dir2/mumps.gld"

# Make DB 2 with global directory of gbl_dir2
$gtm_tst/com/dbcreate.csh gbl_dir2/mumps 2 >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif


$gtm_tst/com/dbcheck.csh gbl_dir1/mumps >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif

$gtm_tst/com/dbcheck.csh gbl_dir2/mumps >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
