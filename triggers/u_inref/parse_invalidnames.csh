#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192
$echoline
echo "Invalid trigger names"
$gtm_exe/mumps -run invalidnames
foreach bad ( bad*check*.trg )
	$MUPIP trigger -trig=$bad -noprompt >>& invalidnametest.txt
	if (0 == $?) then
		echo "$bad FAIL"
		$head -n1 $bad | tee -a invalid.fail
	endif
	rm $bad
end
echo "Failures `$grep -c '^;' invalid.fail`"
echo "Number of times MUPIP rejected invalid names `$grep -c YDB-E-MUNOACTION invalidnametest.txt`"
$gtm_exe/mumps -run run^invalidnames
source $gtm_tst/com/ydb_trig_upgrade_check.csh
$gtm_tst/com/dbcheck.csh -extract
