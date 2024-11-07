#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests that Mupip Journal -Extract=-stdout handles its termination appropriately
#


# Needed to avoid ocassional assert failures in iott_use.c due to an error return from tcsetattr() after the terminal is killed
setenv gtm_white_box_test_case_enable   1
setenv gtm_white_box_test_case_number   400      # WBTEST_YDB_KILL_TERMINAL
echo "# Creating database,journal file"
$gtm_tst/com/dbcreate.csh mumps 1>>& create.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif
# Using nobefore so test can work with BG or MM access method (randomly chosen by test framework)
$MUPIP Set -Region Default -Journal=enable,on,nobefore,file=mumps.mjl >>& jnlcreate.out
if ($status) then
	echo "Journal Create Failed, Output Below"
	cat jnlcreate.out
endif

# Updating database with massive amount of information so it will take time to extract,
# allowing the system to easily exit while extracting
$ydb_dist/mumps -run ^%XCMD "for i=1:1:1000 set ^x(i)=i"
set t = `date +"%b %e %H:%M:%S"`

echo "# Running extract and terminating in separate terminal"
(expect -d $gtm_tst/$tst/u_inref/gtm8787.exp > expect.outx) >& xpect.dbg
if ($status) then
	echo "EXPECT FAILED"
endif
$gtm_tst/com/getoper.csh "$t"
# Syslog messages captured in getoper will be logged to syslog.txt

set extractpid = `cat extract.pid`	# Note down pid of MUPIP JOURNAL EXTRACT
echo "# Searching Sys Log for a KILLBYSIG Error from MUPIP JOURNAL EXTRACT (Expecting nothing, would be found in previous versions)"
cat syslog.txt |& $grep "MUPIP.*\<$extractpid\>.*KILLBYSIG" |& $tst_awk '{print $6,$7,$8,$9,$10,$11,$12}'
echo ""
echo "# Searching Sys Log for a NOPRINCIO Error"
# MUPIP JOURNAL -EXTRACT can sometimes produce either one or two NOPRINCIO Errors,
# for uniformity we are just looking for the first instance
cat syslog.txt |& $grep "MUPIP.*NOPRINCIO" | sed 's/.*%YDB/%YDB/;s/ -- generated.*//;'

$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
