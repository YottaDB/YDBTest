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
#
# GTM-7923 SIG-11 during compilation of M patterns containing lots of alternations
#
$gtm_tst/com/dbcreate.csh mumps
echo "Invoking : mumps -run gtm7923"
$gtm_exe/mumps -run gtm7923
$gtm_tst/com/dbcheck.csh
