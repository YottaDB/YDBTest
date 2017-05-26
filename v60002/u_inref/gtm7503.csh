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

$gtm_tst/com/dbcreate.csh mumps
$gtm_exe/mumps -run gtm7503
$gtm_tst/com/check_error_exist.csh  gtm7503.mje 'GTM-E-HOSTCONFLICT'
echo "Renaming gtm7503.mjex to errout.txtx"
\mv gtm7503.mjex errout.txtx
$gtm_tst/com/dbcheck.csh
