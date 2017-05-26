#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that triggers can be installed & fired inside the same TP transaction without any TRIGMODINTP errors

$gtm_tst/com/dbcreate.csh mumps 1
$echoline
$gtm_exe/mumps -run trigmodintp
$echoline
$gtm_tst/com/dbcheck.csh -extract
