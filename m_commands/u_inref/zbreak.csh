#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2004, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$gtm_tst/com/dbcreate.csh .
echo "test ZBREAK"
setenv gtmdbglvl 4096
$gtm_exe/mumps -r zbdrive

unsetenv gtmdbglvl
$gtm_tst/com/dbcheck.csh
