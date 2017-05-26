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

# Let's prevent dup2() of stdin in forked piped process
echo "Case 1: Prevent dup2() of stdin in forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 109

set syslog_time1 = `date +"%b %e %H:%M:%S"`

$gtm_dist/mumps -run defaultstderr^pipeuname

set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" msgs1.txt "" "PIPE -"
$grep "PIPE -" msgs1.txt >& grepmsgs.txt
if (! $status ) then
	echo "Message Found!"
else
	echo "Message Not Found!"
endif
echo ""


# Let's prevent dup2() of stdout in forked piped process
echo "Case 2: Prevent dup2() of stdout in forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 110

set syslog_time1 = `date +"%b %e %H:%M:%S"`

$gtm_dist/mumps -run defaultstderr^pipeuname

set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" msgs2.txt "" "PIPE -"
$grep "PIPE -" msgs2.txt >& grepmsgs.txt
if (! $status ) then
	echo "Message Found!"
else
	echo "Message Not Found!"
endif
echo ""

# Let's prevent first dup2() of stderr in forked piped process
echo "Case 3: Prevent dup2() of stderr in forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 111

set syslog_time1 = `date +"%b %e %H:%M:%S"`

$gtm_dist/mumps -run defaultstderr^pipeuname

set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" msgs3.txt "" "PIPE -"
$grep "PIPE -" msgs3.txt >& grepmsgs.txt
if (! $status ) then
	echo "Message Found!"
else
	echo "Message Not Found!"
endif
echo ""

# Let's prevent first dup2() of stderr in forked piped process
echo "Case 4: Prevent second dup2() of stderr in forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 112

set syslog_time1 = `date +"%b %e %H:%M:%S"`

$gtm_dist/mumps -run assignstderr^pipeuname

set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" msgs4.txt "" "PIPE -"
$grep "PIPE -" msgs4.txt >& grepmsgs.txt
echo ""
if (! $status ) then
	echo "Message Found!"
else
	echo "Message Not Found!"
endif
echo ""

# Let's prevent the EXEC() by the forked piped process
echo "Case 5: Prevent EXEC() by the forked piped process"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 113

set syslog_time1 = `date +"%b %e %H:%M:%S"`

$gtm_dist/mumps -run defaultstderr^pipeuname

set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" msgs5.txt "" "PIPE -"
$grep "PIPE -" msgs5.txt >& grepmsgs.txt
if (! $status ) then
	echo "Message Found!"
else
	echo "Message Not Found!"
endif
