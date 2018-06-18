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
if ($terminalKill == 1) then
	$gtm_tst/$tst/u_inref/ydb210_dbcreate.csh
else
	(expect -d $gtm_tst/$tst/u_inref/ydb210_dbcreate.exp > expect_REPLOFFJNLON.out) >& expect_REPLOFFJNLON.dbg
	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status"
	endif
	mv expect_REPLOFFJNLON.out expect_REPLOFFJNLON.outx	# move .out to .outx to avoid -E- from being caught by test framework
	# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.
	perl $gtm_tst/com/expectsanitize.pl expect_REPLOFFJNLON.outx > expect_REPLOFFJNLON_sanitized.outx
endif

setenv start_time `cat start_time` # start_time is used in naming conventions
setenv srcLog "SRC_$start_time.log"
setenv portno `$sec_shell "$sec_getenv ; source $gtm_tst/com/portno_acquire.csh"`

echo "# Shut down source server and turn replication off in AREG" >> REPLOFFJNLON.logx
echo "# (Both regions should have had journaling and replication on initially)" >> REPLOFFJNLON.logx
$gtm_tst/com/SRC_SHUT.csh "." < /dev/null >>&! $PRI_SIDE/REPLOFFJNLON_SHUT1.out
$MUPIP SET -REGION "AREG" -REPLICATION=OFF |& grep "STATE" >>& REPLOFFJNLON.logx
echo '' >> REPLOFFJNLON.logx

echo "# Restart source server (expecting REPLOFFJNLON error)" >> REPLOFFJNLON.logx
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! REPLOFFJNLON_RESTART1.outx

$grep "REPLOFFJNLON" $srcLog >> REPLOFFJNLON.logx
echo '' >> REPLOFFJNLON.logx

echo "# Shut down source server and turn replication back on in AREG" >> REPLOFFJNLON.logx
$MUPIP SET -REGION "AREG" -REPLICATION=ON |& grep "STATE" >>& REPLOFFJNLON.logx
echo '' >> REPLOFFJNLON.logx

echo "# Restart source server (expecting no error)" >> REPLOFFJNLON.logx
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! REPLOFFJNLON_RESTART2.out
echo '' >> REPLOFFJNLON.logx

echo "# Shutdown the DB" >> REPLOFFJNLON.logx
$gtm_tst/com/dbcheck.csh >& dbcheck.outx
if ($status) then
	echo "DB Check Failed, Output Below" >> REPLOFFJNLON.logx
	cat dbcheck.outx >> REPLOFFJNLON.logx
endif

echo '' >> REPLOFFJNLON.logx

echo "Test has concluded"
