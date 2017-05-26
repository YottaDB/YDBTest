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
# A test that simulates an error inside wcs_flu(), and ensures that mu_rndwn_file.c responds accordingly,     #
# depending on whether it is invoked in standalone (MUPIP RECOVER/ROLLBACK) or non-standalone (MUPIP RUNDOWN) #
# mode, and whether the OVERRIDE qualifer (only supported in non-standalone mode) is present.                 #
###############################################################################################################

@ case = 1

setenv gtm_test_jnl NON_SETJNL

# There will be four cases, first dealing with standalone, and the other three with non-standalone modes.
while ($case <= 4)
	echo "Case #${case}"
	$echoline

	# Create a database.
	$gtm_tst/com/dbcreate.csh mumps >&! dbcreate${case}.out

	# Copy the database to replace the crashed one, if needed.
	cp mumps.dat mumps.dat${case}.bak

	# Prepare the white-box test that causes wcs_flu() to fail.
	setenv gtm_white_box_test_case_number 93
	setenv gtm_white_box_test_case_count 1
	unsetenv gtm_white_box_test_case_enable

	# Set the flush timer for one tenth of a second for quick updating.
	$gtm_dist/dse >&! dse${case}.out << EOF
	change -fileheader -flush_time=10
	quit
EOF

	if (2 != $case) then
		# Enable journaling to qualify for conditions that should normally prevent the rundown.
		$MUPIP set $tst_jnl_str -reg "*" >&! mupip_set${case}.out
	endif

	# Launch a GT.M process that writes an update and kills itself
	$gtm_exe/mumps -direct >&! mumps${case}.out <<EOF
		set ^a=1
		if \$zsigproc(\$job,9)
		quit
EOF

	# First case is for standalone, the other three for non-standalone modes.
	if (1 == $case) then
		$gtm_tst/$tst/u_inref/wcs_flu_fail_standalone.csh $case
	else
		$gtm_tst/$tst/u_inref/wcs_flu_fail_non_standalone.csh $case
	endif

	# Verify that the database is fine.
	$gtm_tst/com/dbcheck.csh >&! dbcheck${case}.out

	# Move the database out of the way for the next case.
	mv mumps.dat mumps.checked${case}.dat

	echo
	@ case = $case + 1
end
