#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Begin gtm6571"
$gtm_tst/com/dbcreate.csh mumps
cp $gtm_tst/v60000/u_inref/gtm6571*.csh ./
setenv gtm_procstuckexec "$PWD/gtm6571_procstuckexec.csh"
echo $gtm_procstuckexec
setenv gtm_tpnotacidtime 30
set time_before = `date +"%b %e %H:%M:%S"`
$gtm_dist/mumps -run gtm6571
set time_after = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$time_before" "$time_after" syslog.txt "" "MUTEXLCKALERT"
set count_of_msgs = `$grep $PWD syslog.txt | $grep MUTEXLCKALERT | $grep -vE "STUCKACT|%YDBPROCSTUCKEXEC" | wc -l`
if (3 != $count_of_msgs) then
	echo "TEST-E-FAIL, MUTEXLCKALERT message appeared $count_of_msgs times in syslog (expecting 3 times)."
endif
$grep foo %YDBPROCSTUCKEXEC*_MUTEXLCKALERT*	# make sure things ran to avoid a false positive
cat *.mje*	# make sure there is nothing logged to any .mje files
set stat1 = $status
$gtm_tst/com/dbcheck.csh
echo "End gtm6571"
exit ($stat1)
