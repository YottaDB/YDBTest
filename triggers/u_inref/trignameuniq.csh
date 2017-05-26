#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# TRIGNAMEUNIQ
#
# TRIGNAMEUNIQ, Unable to make trigger name tttt unique beyond vvvv
# versions already loaded
#
# Run Time Error: GT.M encountered more than vvvv different instances
# of the same trigger name across database regions used by the same process.
#
# Action: Revise trigger names to prevent such a high degree of overlap.
#
# If multiple global directories define triggers for the same globals then at
# run time, GT.M attempts to make these trigger names unique by appending 2
# alpha-numeric characters at the end. Each such character can take up to 62
# combinations (26 upper case + 26 lower case + 10 numeric) which gives a total
# possibility of 1+62+62x62 = 3907.
#
# Since creating this scenario is not simple, we added a whitebox test case
# WBTEST_HELPOUT_TRIGNAMEUNIQ to allow us to install multiple triggers with the
# same name in the same region.

# This test makes use of whitebox testing mechanism. For pro, exit
if ("pro" == $tst_image) then
	exit
endif
$gtm_tst/com/dbcreate.csh mumps

# Use WBTEST_HELPOUT_TRIGNAMEUNIQ
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 30
setenv gtm_white_box_test_case_count  1

$gtm_dist/mumps -run trignameuniq

$gtm_tst/com/dbcheck.csh
