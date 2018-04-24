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

$gtm_tst/com/dbcreate.csh mumps 3

set syslog_time_before = `date +"%b %e %H:%M:%S"`
$ydb_dist/mumps -run tprestart
set syslog_time_after = `date +"%b %e %H:%M:%S"`
set | grep syslog_time > debug.txt	# record these variables for test debugging if later needed
$gtm_tst/com/getoper.csh "$syslog_time_before" "$syslog_time_after" syslog2.txt

# Search for TPRESTART messages belonging to this test (hence the `pwd` below) and ensure they have the right global name.
# $8 is the full path of the database file name
# $15 is the global name (subscripted or unsubscripted)
# It is possible the global name is ^*DIR to imply directory tree. Filter that out.
# It is possible the global name has subscripts. Filter that out.
# Finally compare the unsubscripted global name against the database file name.
$grep "TPRESTART.*`pwd`" syslog2.txt | $tst_awk '{print $8, $15}' | grep -vw DIR | sed 's/(.*)//g' | sort -u >& reg_gbl.out
echo "-------------------------------------------------------------------------------------------------"
echo "Below is a list of global names & region names in the TPRESTART syslog messages that do not match"
echo "-------------------------------------------------------------------------------------------------"
$grep -v "`pwd`/a.dat; ^a;" reg_gbl.out | $grep -v "`pwd`/b.dat; ^b;" | $grep -v "`pwd`/mumps.dat; ^c;"
echo "-------------------------------------------------------------------------------------------------"

$gtm_tst/com/dbcheck.csh
