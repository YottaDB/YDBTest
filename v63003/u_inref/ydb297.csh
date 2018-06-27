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
# Tests that when over 31 locks hash to the same value, LOCK commands work correctly
#
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
# Simulates 2 errors in prior versions, either inappropriately seizes ownership of a lock or test hangs
# Randomly chooses an option (1 will cause the test to hang, 0 will cause locks to be inappropriately seized)
setenv hang `$gtm_tst/com/genrandnumbers.csh 1 0 1`
$ydb_dist/mumps -run ydb297^ydb297 >>& job.out
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
echo "# LOCKING RESOURCES THAT HASH TO THE SAME VALUE, EXPECT NUMBER OF LOCKS TO REMAIN CONSTANT ACROSS EACH RUN"
echo "# INFO FROM RUN 1"
set status1 = `cat lockhang_ydb297.mjo1 |& $grep FAILURE`
cat lockhang_ydb297.mjo1 |& $grep LOCKSPACEINFO
echo "# INFO FROM RUN 2"
cat lockhang_ydb297.mjo2 |& $grep LOCKSPACEINFO
set status2 = `cat lockhang_ydb297.mjo2 |& $grep SUCCESS`
echo "# INFO FROM RUN 3"
cat lockhang_ydb297.mjo3 |& $grep LOCKSPACEINFO
set status3 = `cat lockhang_ydb297.mjo3 |& $grep SUCCESS`
cat lockhang_ydb297.mjo3 |& $grep SEGMENT
if (0 == `expr $hang` && "" == "$status1" && "" != "$status2" && "" != "$status3") then
	echo "# INAPPROPRIATE LOCK SEIZED"
endif
