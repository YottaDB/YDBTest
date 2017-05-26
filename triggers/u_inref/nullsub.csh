#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Block size: 1024;  Maximum record size 900;
# Maximum key size:  255;  Null subscripts  ALWAYS
# Standard Null Collation: TRUE
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 2 255 950 1024 . . . . . ALWAYS . -stdnull
$echoline
echo "Test with database supporting null subscript"
$echoline
$gtm_exe/mumps -run ^nullsub
$gtm_tst/com/dbcheck.csh

$echoline
echo "Test with database not supporting null subscript"
$echoline
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 2 255 950 1024 . . . . . NEVER . -stdnull

$gtm_exe/mumps -run ^nullsub

$gtm_tst/com/dbcheck.csh
