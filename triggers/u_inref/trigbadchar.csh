#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_trigger_etrap 'write $zstatus,! set $ecode=""'
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run trigbadchar
source $gtm_tst/com/ydb_trig_upgrade_check.csh
$gtm_tst/com/dbcheck.csh
