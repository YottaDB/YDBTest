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
#check that JOB detects an undefined lvn

$gtm_dist/mumps -direct <<EOF
job ^%XCMD(foo)		;should get UNDEF
EOF
if ( -e _XCMD.mjo || -e _XCMD.mje ) then
    echo "FAIL"
    ls _XCMD.mj*
endif
