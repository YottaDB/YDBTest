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
echo '# Test that VIEW "NOISOLATION" optimization affects atomicity of $INCREMENT inside TSTART/TCOMMIT'
echo '# In the below test, ^x is updated using $INCREMENT inside a TSTART/TCOMMIT by multiple processes'
echo '# Case (1) : Without VIEW "NOISOLATION", the transaction will restart due to a concurrent $INCREMENT'
echo '#     This means the final value of ^x would be exactly the # of transactions that committed'
echo '# Case (2) : But with VIEW "NOISOLATION", the user gives a guarantee that nodes updates by one process are not'
echo '#     updated by the same process. Therefore the transaction is not restarted in case of a concurrent'
echo '#     $INCREMENT thus resulting in the final value of ^x being way different from what it was in Case (1)'

$gtm_tst/com/dbcreate.csh mumps

echo "# Case (1) : Invoking :mumps -run ydb353: with VIEW NOISOLATION turned OFF"
$ydb_dist/mumps -run ydb353 "ISOLATION"

echo "# Case (2) : Invoking :mumps -run ydb353: with VIEW NOISOLATION turned ON"
$ydb_dist/mumps -run ydb353 "NOISOLATION"

$gtm_tst/com/dbcheck.csh
