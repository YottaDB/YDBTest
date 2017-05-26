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
# Helper script for wcs_flu_fail test. It attempts a MUPIP JOURNAL -RECOVER, in forward or backward mode, on  #
# a crashed database, and ensures that appopriate error messages appear in the terminal and/or the syslog.    #
###############################################################################################################

set case = $1

# Activate the white-box test.
setenv gtm_white_box_test_case_enable 1

# Attempt a recovery.
if ($gtm_test_jnl_nobefore) then
	$gtm_dist/mupip journal -recover -forward -verbose mumps.mjl
else
	# Record the time before a recovery.
	set time_before = `date +"%b %e %H:%M:%S"`

	$gtm_dist/mupip journal -recover -backward -verbose mumps.mjl

	# Record the time after an attempted recovery.
	set time_after = `date +"%b %e %H:%M:%S"`

	# Ensure that JNLFILOPN error got printed in the syslog.
	$gtm_tst/com/getoper.csh "$time_before" "$time_after" "jnlfilopn${case}.txt" "" JNLFILOPN
	$grep -q -E 'JNLFILOPN.*'$cwd jnlfilopn${case}.txt
	if ($status) then
		echo "TEST-E-FAIL, GTM-E-JNLFILOPN not found in operator log. Check jnlfilopn${case}.txt."
	endif
endif

# Deactivate the white-box test.
unsetenv gtm_white_box_test_case_enable

# Ensure that all IPCs are gone.
$gtm_dist/mupip rundown -override -reg "*" >&! rundown${case}.txt

# Copy back a clean database to avoid integ errors.
mv mumps.dat mumps.dat${case}.orig
mv mumps.dat${case}.bak mumps.dat
