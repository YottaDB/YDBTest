#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set syslog_time1 = `date +"%b %e %H:%M:%S"`

# Let's prevent dup2() of stdin in forked piped process
echo "Case 1: Prevent dup2() of stdin in forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 109

$gtm_dist/mumps -run defaultstderr^pipeuname

# Let's prevent dup2() of stdout in forked piped process
echo "Case 2: Prevent dup2() of stdout in forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 110

$gtm_dist/mumps -run defaultstderr^pipeuname

# Let's prevent first dup2() of stderr in forked piped process
echo "Case 3: Prevent dup2() of stderr in forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 111

$gtm_dist/mumps -run defaultstderr^pipeuname

# Let's prevent first dup2() of stderr in forked piped process
echo "Case 4: Prevent second dup2() of stderr in forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 112

$gtm_dist/mumps -run assignstderr^pipeuname

# Let's prevent the EXEC() by the forked piped process
echo "Case 5: Prevent EXEC() by the forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 113

$gtm_dist/mumps -run defaultstderr^pipeuname

echo "# See if there was one PIPE message in syslog for each Case above. List of messages follows"
$gtm_tst/com/getoper.csh "$syslog_time1" "" msgs.txt
$grep "PIPE -" msgs.txt | sed 's/.*\(%YDB-E-DEVOPENFAIL\)/\1/;s/ -- generated.*//'

unsetenv gtm_white_box_test_case_enable
