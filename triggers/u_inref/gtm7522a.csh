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

$gtm_tst/com/dbcreate.csh mumps
echo "----------------------------------------------------------------"
echo "# Test that TRIGGER SELECT operations happen under a TP fence"
$gtm_exe/mumps -run gtm7522a
$gtm_tst/com/dbcheck.csh -extract
