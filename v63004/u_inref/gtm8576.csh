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
	#some of these variables are form older tests and may be outdated
#setenv test_specific_gde $gtm_tst/$tst/inref/gtm8576.gde

#$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.outx
#if ($status) then
#	echo "DB Create Failed, Output Below"
#	cat dbcreate.outx
#endif

(expect -d $gtm_tst/$tst/u_inref/gtm8576.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.

echo "# Get start time (used in .updproc file name)"
setenv start_time `cat start_time` # start_time is used in naming conventions
setenv srcLog "SRC_$start_time.log"

#echo "# Run gtm5730.m to update DB 2000 times"
#$gtm_dist/mumps -run gtm5730 > gtm5730.m.log

echo "# RF_sync to allow reciever to catch up"
$gtm_tst/com/RF_sync.csh

cat $srcLog

#echo "# Dump .updproc file from recieving side to rcvr.updproc"
#$sec_shell 'cat $SEC_DIR/RCVR_'${start_time}.log.updproc'' >& rcvr.updproc

#echo "# Search rcvr.updproc for non-numerical type descriptor"
#$ydb_dist/mumps -run LOOP^%XCMD --xec=';write:$zfind(%l,"Rectype") $zpiece(%l,":",5)," ",$zpiece(%l,":",6),!;' < rcvr.updproc
echo "# Shutdown the DB"
$gtm_tst/com/dbcheck.csh >& dbcheck.outx
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck.outx
endif

