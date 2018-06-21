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
	$gtm_tst/$tst/u_inref/ydb210_dbcreate.csh 2
else
	#Use expect script to run the commands from the IF block of code
	set cmd='ydb210_dbcreate.csh 2'

	(expect -d $gtm_tst/com/runcmd.exp "$cmd" > expect_REPLOFFJNLON.out) >& expect_REPLOFFJNLON.dbg

	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status"
	endif
	# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.
	perl $gtm_tst/com/expectsanitize.pl expect_REPLOFFJNLON.out > expect_REPLOFFJNLON_sanitized.out
endif

setenv start_time `cat start_time` # start_time is used in naming conventions
setenv srcLog "SRC_$start_time.log"
setenv portno `$sec_shell "$sec_getenv ; source $gtm_tst/com/portno_acquire.csh"`

echo "# Shut down source server and turn replication off in AREG" >> $outputFile
echo "# (Both regions should have had journaling and replication on initially)" >> $outputFile
$gtm_tst/com/SRC_SHUT.csh "." < /dev/null >>&! $PRI_SIDE/REPLOFFJNLON_SHUT1.out
$MUPIP SET -REGION "AREG" -REPLICATION=OFF |& grep "STATE" >>& $outputFile
echo '' >> $outputFile

echo "# Restart source server (expecting REPLOFFJNLON error in source server log)" >> $outputFile
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! REPLOFFJNLON_RESTART1.outx

$grep "REPLOFFJNLON" $srcLog >> $outputFile
echo '' >> $outputFile

#Clean $srcLog of expected errors
check_error_exist.csh $srcLog "YDB-E-REPLOFFJNLON" > /dev/null

echo "# Shut down source server and turn replication back on in AREG" >> $outputFile
$MUPIP SET -REGION "AREG" -REPLICATION=ON |& grep "STATE" >>& $outputFile
echo '' >> $outputFile

echo "# Restart source server (expecting no error)" >> $outputFile
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! REPLOFFJNLON_RESTART2.out
echo '' >> $outputFile

echo "# Shutdown the DB" >> $outputFile
$gtm_tst/com/dbcheck.csh >& dbcheck.outx
if ($status) then
	echo "DB Check Failed, Output Below" >> $outputFile
	cat dbcheck.outx >> $outputFile
endif

echo '' >> $outputFile

echo "Test has concluded"
