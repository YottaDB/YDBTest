#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###############################################################################################################
# Helper script for wcs_flu_fail test. It attempts a MUPIP RUNDOWN, with or without the OVERRIDE qualifier,   #
# on a crashed database, and ensures that appopriate error messages appear in the terminal and/or the syslog. #
###############################################################################################################

set case = $1

# Activate the white-box test.
setenv gtm_white_box_test_case_enable 1

# Record the time before a RUNDOWN.
set time_before = `date +"%b %e %H:%M:%S"`

# Use OVERRIDE qualifier in one of the cases.
if (4 == $case) then
	$gtm_dist/mupip rundown -override -reg "*"
else
	$gtm_dist/mupip rundown -reg "*"
endif

# Record the time after an attempted RUNDOWN.
set time_after = `date +"%b %e %H:%M:%S"`

# Ensure that MURNDWNOVRD message got printed in the syslog.
if (4 == $case) then
	$gtm_tst/com/getoper.csh "$time_before" "$time_after" "murndwnovrd${case}.txt" "" MURNDWNOVRD
	# grep for MURNDWNOVRD messages only from our test (not other concurrent tests)
	$grep "MURNDWNOVRD.*$PWD" murndwnovrd${case}.txt >& /dev/null
	if ($status) then
		echo "TEST-E-FAIL, GTM-I-MURNDWNOVRD not found in operator log. Check murndwnovrd${case}.txt."
	endif
endif

# If OVERRIDE was specified, we expect the operation to have succeeded, but the file header fields should
# have not been reset; so we confirm that by attempting another MUPIP RUNDOWN, this time without the
# OVERRIDE qualifier. We should not succeed and be advised to use RECOVER instead.
if (4 == $case) then
	$gtm_dist/mupip rundown -region "*"
endif

# Deactivate the white-box test.
unsetenv gtm_white_box_test_case_enable

# Ensure that all IPCs are gone.
$gtm_dist/mupip rundown -override -reg "*" >&! rundown${case}.txt

# Copy back a clean database to avoid integ errors.
mv mumps.dat mumps.dat${case}.orig
mv mumps.dat${case}.bak mumps.dat
