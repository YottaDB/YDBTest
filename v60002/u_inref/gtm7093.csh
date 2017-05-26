#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/dbcreate.csh mumps 2
$gtm_exe/mumps -run %XCMD 'zprint ^default#'
$gtm_exe/mumps -run %XCMD 'zbreak ^a#'
$gtm_exe/mumps -run %XCMD 'write $Text(^default#),!'
$gtm_tst/com/dbcheck.csh
