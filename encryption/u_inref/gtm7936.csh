#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_mupip_set_version "disable"	# Prevent random usage of V4 database as that causes issues with using MM
setenv test_encryption NON_ENCRYPT	# Disable encryption for first part of test
setenv gtm_test_jnl "NON_SETJNL"	# Disable journaling for first part of test
$gtm_tst/com/dbcreate.csh mumps
foreach acc_meth (BG MM)
	$MUPIP set -acc=${acc_meth} -reg "*"
	echo "--------------------------------------------------------------"
	echo "DSE CACHE -SHOW output with ${acc_meth}, NON_ENCRYPT and NOJNL"
	echo "--------------------------------------------------------------"
	$DSE cache -show
end
$gtm_tst/com/dbcheck.csh

setenv test_encryption ENCRYPT	# Enable encryption for second part of test
setenv acc_meth BG		# MM and encryption is not supported

echo "-----------------------------------------------"
echo "DSE CACHE -SHOW output with BG, ENCRYPT and JNL"
echo "-----------------------------------------------"
setenv gtm_test_jnl "SETJNL"	# Enable journaling for second part of test
$gtm_tst/com/dbcreate.csh mumps
$DSE cache -show
$gtm_tst/com/dbcheck.csh
