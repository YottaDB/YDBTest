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
#
# GTM-8070 - test that TP + LOCK does not block the exit of a conflicting LOCK
#
# Define envvar for SIGUSR1 value on all platforms (for test case 6).
if (("OSF1" == $HOSTOS) || ("AIX" == $HOSTOS)) then
	setenv sigusrval 30
else if (("SunOS" == $HOSTOS) || ("HP-UX" == $HOSTOS) || ("OS/390" == $HOSTOS)) then
	setenv sigusrval 16
else if ("Linux" == $HOSTOS) then
	setenv sigusrval 10
endif
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run gtm8070
$gtm_tst/com/dbcheck.csh
