#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps
echo "----------------------------------------------------------------"
echo '# Test $ztrigger output with incremental trollbacks AND explicit restarts'
$gtm_exe/mumps -run gtm7522b
echo "# print ^ROLLBACK trigger"
$gtm_dist/mumps -run %XCMD 'if $ztrigger("select","^ROLLBACK")'
$gtm_tst/com/dbcheck.csh -extract
