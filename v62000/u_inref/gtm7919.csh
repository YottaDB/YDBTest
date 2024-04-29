#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test to ensure that all currently defined GT.M messages are printed correctly in the terminal or syslog,
# and that argument overflows and type coercions happen in an expected manner. The test relies on the
# ZMESSAGE facility to generate every message used by GT.M. The arguments supplied to a ZMESSAGE command
# are recorded and later matched against the arguments extracted out of the actual messages, taking into
# consideration numeric overflows, type casting, and width and filling requirements.

set facilities =	( "terminal"	"syslog" )
set msgFileNames =	( "termmsg"	"syslogmsg" )
set argsFileNames =	( "termargs"	"syslogargs" )
set logFileNames =	( "termlog"	"sysloglog" )
set pidFileNames =	( "termpid"	"syslogpid" )
set setWhiteBoxTests =	( 0		1 )
@ num_of_cases = $#facilities

@ i = 1
while ($i <= $num_of_cases)
	$echoline
	echo "Testing $facilities[$i] messages."
	$echoline

	set msgFileName = $msgFileNames[$i]
	set argsFileName = $argsFileNames[$i]
	set logFileName = $logFileNames[$i]
	set pidFileName = $pidFileNames[$i]
	set setWhiteBoxTest = $setWhiteBoxTests[$i]

	if ($setWhiteBoxTest) then
		setenv gtm_white_box_test_case_number 101
		setenv gtm_white_box_test_case_enable 1
	endif

	# Generate message information for other scripts to use.
	$gtm_dist/mumps -run getmsginfo	${msgFileName}.m	\
				$gtm_src/cmerrors.msg		\
				$gtm_src/gdeerrors.msg		\
				$gtm_src/merrors.msg		\
				$gtm_src/cmierrors.msg

	# Generate messages in the terminal or syslog.
	set time_before = `date +"%b %e %H:%M:%S"`
	$gtm_dist/mumps -run genmsgs ${msgFileName} ${argsFileName}.cmp ${pidFileName}.log >&! ${logFileName}.outx

	if ($setWhiteBoxTest) then
		# Get the pid of the message-issuing MUMPS process and the mnemonic of the last message.
		set pid = `cat ${pidFileName}.log`

		# Save the output of gensmgs run in a separate file in case of errors.
		mv ${logFileName}.outx ${logFileName}.outx.orig

		# Save the generated syslog messages in a local file.
		$gtm_tst/com/getoper.csh "$time_before" "" ${logFileName}.outx.tmp

		if ($gtm_test_hugepages) then
			# If huge pages have been turned on randomly by test framework, it is possible that
			# there is not enough memory to allocate huge pages for shared memory in the current
			# system. In that case, we would see messages of the following form
			#	YDB-MUMPS[91661]: %YDB-W-SHMHUGETLB, Could not back shared memory with huge pages,
			#		using base pages instead, %SYSTEM-E-ENO12, Cannot allocate memory
			# We should not count these messages as part of the syslog messages that this test intends
			# to see so filter those out. Note though that the test does generate a %YDB-W-SHMHUGETLB
			# syslog message too later (while generating all possible messages) and so that message
			# should not be filtered out. Such messages are of the following form
			#	YDB-MUMPS[91661]: %YDB-W-SHMHUGETLB, Could not back shared memory with huge pages,
			#		using base pages instead
			# The difference is the lack of the "%SYSTEM-E-ENO12, Cannot allocate memory" secondary
			# error. So that is what we use to do the filtering.
			mv ${logFileName}.outx.tmp ${logFileName}.outx.tmp.orig
			$grep -v 'SHMHUGETLB.*, %SYSTEM-E-ENO12, Cannot allocate memory' ${logFileName}.outx.tmp.orig > ${logFileName}.outx.tmp
		endif

		# Grep out only the messages that originated from our process.
		$grep "\[$pid\]" ${logFileName}.outx.tmp > ${logFileName}.outx

		# Tab characters are escaped differently in syslog, so extract a tab escape sequence from
		# a message that we know contains one, and save it in a file for our helper script to use.
		$grep STATCNT ${logFileName}.outx | $head -n 1 | $tst_awk -F '%YDB-I-' '{print $2}' | $tst_awk -F ':' '{print $2}' | sed 's/  Key cnt//' >&! tab.log

		# Extract arguments out of each generated message and save them in a file.
		$gtm_dist/mumps -run gtm7919 ${msgFileName} ${logFileName}.outx ${argsFileName}.log tab.log
	else
		# Extract arguments out of each generated message and save them in a file.
		$gtm_dist/mumps -run gtm7919 ${msgFileName} ${logFileName}.outx ${argsFileName}.log
	endif

	# Diff the extracted arguments with those actually used.
	diff ${argsFileName}.cmp ${argsFileName}.log >&! ${argsFileName}.diff

	# This time the diff must succeed, or otherwise we have a failure.
	if (0 == $status) then
		echo "TEST-S-SUCCESS, The test was successful."
	else
		echo "TEST-E-FAIL, The test failed."
	endif

	if ($setWhiteBoxTest) then
		unsetenv gtm_white_box_test_case_number
		unsetenv gtm_white_box_test_case_enable
	endif

	if ($i != $num_of_cases) then
		echo
		echo
	endif

	@ i = $i + 1
end
