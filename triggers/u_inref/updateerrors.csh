#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/dbcreate.csh mumps 4

$gtm_exe/mumps -run setup^updateerrors

setenv gtm_trigger_etrap 'do saneZS^updateerrors($zstatus)'
$gtm_exe/mumps -run test1^updateerrors 5
$gtm_exe/mumps -run test2^updateerrors 3
$gtm_exe/mumps -run test3^updateerrors 2

echo "Re-running all the same tests with an ETRAP that should let all updates pass"
setenv gtm_trigger_etrap 'do saneZS^updateerrors($zstatus) set $ecode=""'
$gtm_exe/mumps -run test1^updateerrors 11
$gtm_exe/mumps -run test2^updateerrors 7
$gtm_exe/mumps -run test3^updateerrors 1


$gtm_tst/com/dbcheck.csh -extract
