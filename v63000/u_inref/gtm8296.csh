#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                     #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test opens the help database (using PEEKBYNAME) and since other concurrent tests could also be doing
# PEEKBYNAME concurrently, we want to avoid semaphore counter overflow to affect this or the concurrent test.
# Therefore disable counter overflow in this test by setting the increment value to default value of 1 (aka unset).
unsetenv gtm_db_counter_sem_incr

setenv gtm_test_spanreg     0       # Test assumes ^x maps to DEFAULT region, so disable spanning regions

$MULTISITE_REPLIC_PREPARE 2

$gtm_tst/com/dbcreate.csh mumps 3 125 1000 4096 2000 4096 2000

$MSR START INST1 INST2

$gtm_exe/mumps -run gtm8296

$gtm_tst/com/dbcheck.csh -extract
