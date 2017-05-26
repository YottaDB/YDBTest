#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Trigger Update Memory Leak Test
echo "# Trigger Update Memory Leak Test"
$gtm_tst/com/dbcreate.csh mumps 1
cp $gtm_tst/$tst/inref/trigmemleak.trg .
$gtm_exe/mumps -run ^trigmemleak
$gtm_tst/com/dbcheck.csh -extract
