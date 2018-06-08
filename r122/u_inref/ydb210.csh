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

#This test purposely sets up the source server to fail upon restart, so those failures will be ignored
setenv gtm_test_repl_skiprcvrchkhlth 1

#This random value (1 or 0)  will determine if the errors are generated before or after closing
#the terminal that the DB was created in
setenv rand `$gtm_tst/com/genrandnumbers.csh`

#This will supress the ocassional %YDB-I-SHMREMOVED that is output when changing STDNULLCOLL settings
unsetenv gtm_db_counter_sem_incr

echo "RANDOM SETTING: "
if ($rand == 1) then
	echo '# Tests will be run within the DBs original terminal'
else
	echo '# Tests will be run after closing the DBs original terminal'
endif
echo ''

echo "Calling ydb210.exp to create DB in new terminal"
echo ''

(expect -d $gtm_tst/$tst/u_inref/ydb210.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx

#if rand is 0 we run ydb210.dbcreate.csh here. Otherwise it will have been run in ydb210.exp already
if ($rand == 0) then
	NULLCOLLtest.csh
else
	cat NULLCOLLtest.outx
endif

echo "# Shutdown the DB"
$gtm_tst/com/dbcheck.csh >& dbcheck.outx
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck.outx
endif

