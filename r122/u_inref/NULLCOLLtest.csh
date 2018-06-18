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
	(expect -d $gtm_tst/$tst/u_inref/ydb210_dbcreate.exp > expect_NULLCOLL.out) >& expect_NULLCOLL.dbg
	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status"
	endif

	mv expect_NULLCOLL.out expect_NULLCOLL.outx	# move .out to .outx to avoid -E- from being caught by test framework
	# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.
	perl $gtm_tst/com/expectsanitize.pl expect_NULLCOLL.outx > expect_NULLCOLL_sanitized.outx
endif

setenv start_time `cat start_time` # start_time is used in naming conventions
setenv srcLog "SRC_$start_time.log"
setenv portno `$sec_shell "$sec_getenv ; source $gtm_tst/com/portno_acquire.csh"`

echo "# Shut down source server and set regions to different NULL Collation" >> NULLCOLL.logx
$gtm_tst/com/SRC_SHUT.csh "." < /dev/null >>&! $PRI_SIDE/NULLCOLL_SHUT1.out
$MUPIP SET -REGION "DEFAULT" -NOSTDNULLCOLL >>& NULLCOLL.logx
$MUPIP SET -REGION "AREG" -STDNULLCOLL >>& NULLCOLL.logx
echo '' >> NULLCOLL.logx

echo "# Restart source server (expecting NULLCOLLDIFF error)" >> NULLCOLL.logx
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! NULLCOLL_RESTART1.outx

$grep "NULLCOLL" $srcLog >> NULLCOLL.logx
echo '' >> NULLCOLL.logx

echo "# Shut down source server and set regions back to the same NULL Collation" >> NULLCOLL.logx
$MUPIP SET -REGION "DEFAULT" -STDNULLCOLL >>& NULLCOLL.logx
$MUPIP SET -REGION "AREG" -STDNULLCOLL >>& NULLCOLL.logx
echo '' >> NULLCOLL.logx

echo "# Restart source server (expecting no error)" >> NULLCOLL.logx
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! NULLCOLL_RESTART2.out
echo '' >> NULLCOLL.logx

echo "# Shutdown the DB" >> NULLCOLL.logx
$gtm_tst/com/dbcheck.csh >& dbcheck.outx
if ($status) then
	echo "DB Check Failed, Output Below" >> NULLCOLL.logx
	cat dbcheck.outx >> NULLCOLL.logx
endif

echo '' >> NULLCOLL.logx

echo "Test has concluded"
