#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Simple two for one test case
#   1. %XCMD avoids overriding $gtm_etrap
#   2. $ZCALL() produces an FNOTONSYS for all Unix platforms
setenv gtm_etrap 'set $ecode="" write $select($zstatus["FNOTONSYS":"PASS",1:"FAIL"),!'
$gtm_dist/mumps -run %XCMD 'write $zcall()'

