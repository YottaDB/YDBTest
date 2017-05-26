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

# Test that TSTART variable is restored properly on restart

$gtm_tst/com/dbcreate.csh .	# needed due to TSTART usage inside alststartvar
$gtm_exe/mumps -run alststartvar
$gtm_tst/com/dbcheck.csh
