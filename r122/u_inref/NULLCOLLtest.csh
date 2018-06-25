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
if ($terminalNoKill == 1) then
	$gtm_tst/$tst/u_inref/ydb210_dbcreate.csh 2 >> dbcreate.log
	if ($status) then
		echo "FAILURE from ydb210_dbcreate.csh " >> $outputFile
		echo "Dumping dbcreate.log:" >> $outputFile
		cat dbcreate.log >> $outputFile
	endif
else
	#Use expect script to run the commands from the IF block of code
	set cmd='ydb210_dbcreate.csh 2'

	(expect -d $gtm_tst/com/runcmd.exp "$cmd" > expect_NULLCOLL.out) >& expect_NULLCOLL.dbg

	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status" >> $outputFile
	endif

	# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.
	perl $gtm_tst/com/expectsanitize.pl expect_NULLCOLL.out > expect_NULLCOLL_sanitized.out
endif

setenv start_time `cat start_time` # start_time is used in naming conventions
setenv srcLog "SRC_$start_time.log"
setenv portno `$sec_shell "$sec_getenv ; source $gtm_tst/com/portno_acquire.csh"`

echo "# Shut down source server and set regions to different NULL Collation" >> $outputFile
$gtm_tst/com/SRC_SHUT.csh "." < /dev/null >>&! $PRI_SIDE/NULLCOLL_SHUT1.out
if ($status) then
	echo "FAILURE from SRC_SHUT.csh " >> $outputFile
	echo "Dumping $PRI_SIDE/NULLCOLL_SHUT1.out " >> $outputFile
	cat $PRI_SID/NULLCOLL_SHUT1.out >> $outputFile
endif
$MUPIP SET -REGION "DEFAULT" -NOSTDNULLCOLL >>& $outputFile
$MUPIP SET -REGION "AREG" -STDNULLCOLL >>& $outputFile
echo '' >> $outputFile

echo "# Restart source server (expecting NULLCOLLDIFF error in source server log)" >> $outputFile
setenv gtm_test_repl_skipsrcchkhlth 1 #We skip SRC.csh's checkhealth as we expect an error

$gtm_tst/com/SRC.csh "." $portno $start_time >>&! NULLCOLL_RESTART1.outx
if ($status) then
	echo "FAILURE from SRC.csh" >> $outputFile
	echo "Dumping $NULLCOLL_RESTART1.outx" >> $outputFile
	cat $NULLCOLL_RESTART1.outx >> $outputFile
endif
unsetenv gtm_test_repl_skipsrcchkhlth

$grep "NULLCOLL" $srcLog >> $outputFile
echo '' >> $outputFile

#Clean $srcLog of expected errors
check_error_exist.csh $srcLog "YDB-E-NULLCOLLDIFF" > /dev/null
if ($status) then
	echo " FAILURE from check_error_exist.csh:" >> $outputFile
	echo " 		Searching for YDB-E-NULLCOLLDIFF in $srcLog" >> $outputFile
	echo "" >> $outputFile
endif

echo "# Shut down source server and set regions back to the same NULL Collation" >> $outputFile
$MUPIP SET -REGION "DEFAULT" -STDNULLCOLL >>& $outputFile
$MUPIP SET -REGION "AREG" -STDNULLCOLL >>& $outputFile
echo '' >> $outputFile

echo "# Restart source server (expecting no error)" >> $outputFile
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! NULLCOLL_RESTART2.out
setenv gtm_test_repl_skipsrcchkhlth 1 #We skip SRC.csh's checkhealth as we expect an error

if ($status) then
	echo "FAILURE from SRC.csh" >> $outputFile
	echo "Dumping $NULLCOLL_RESTART1.outx" >> $outputFile
	cat $NULLCOLL_RESTART1.outx >> $outputFile
endif
unsetenv gtm_test_repl_skipsrcchkhlth

echo '' >> $outputFile

echo "# Shutdown the DB" >> $outputFile
$gtm_tst/com/dbcheck.csh >& dbcheck.outx
if ($status) then
	echo "DB Check Failed, Output Below" >> $outputFile
	cat dbcheck.outx >> $outputFile
endif

echo '' >> $outputFile
