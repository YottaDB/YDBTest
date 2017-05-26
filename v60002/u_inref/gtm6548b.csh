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

# Test that NULLENTRYREF error is issued if JOB command started with NULL emptyref.

setenv gtm_noundef FALSE
echo "Test JOB command with environment variable gtm_noundef = $gtm_noundef"
$gtm_exe/mumps -dir <<EOF
write "job ^@a",!
job ^@k
write "job @k",!
job @k
write "job ^k",!
job ^k
EOF
echo "------------------------------------------------------------"
echo
setenv gtm_noundef TRUE
echo "Test JOB command with environment variable gtm_noundef = $gtm_noundef"
$gtm_exe/mumps -dir <<EOF
write "job ^@a",!
job ^@k
write "job @k",!
job @k
write "job ^k",!
job ^k
EOF
