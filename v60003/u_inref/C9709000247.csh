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

$gtm_tst/com/dbcreate.csh mumps 2
foreach cmd (mupip dse lke)
	$echoline
	echo Testing ${cmd} help
	$gtm_dist/${cmd} help >! ${cmd}.help <<EOF
EOF
	if ( -z ${cmd}.help ) echo "TEST-F-FAIL: ${cmd}.help is zero length"
	$grep "Help command not implemented in this revision" ${cmd}.help
end
$echoline
$gtm_tst/com/dbcheck.csh
