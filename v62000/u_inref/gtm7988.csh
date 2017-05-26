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

# Verify that zwrite does not issue a (GV)UNDEF error
$gtm_tst/com/dbcreate.csh mumps
$gtm_exe/mumps -run gtm7988
$gtm_tst/com/dbcheck.csh
