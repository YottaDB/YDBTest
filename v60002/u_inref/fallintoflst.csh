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

######################################################################################
# This test exercises the newly added functionality that issues a FALLINTOFLST error #
# whenever a fall-through to a label with a formallist occurs in the M code flow.    #
######################################################################################

# Define envvar for SIGUSR1 value on all platforms (for test case 6).
if (("OSF1" == $HOSTOS) || ("AIX" == $HOSTOS)) then
	setenv sigusrval 30
else if (("SunOS" == $HOSTOS) || ("HP-UX" == $HOSTOS) || ("OS/390" == $HOSTOS)) then
	setenv sigusrval 16
else if ("Linux" == $HOSTOS) then
	setenv sigusrval 10
endif

# Loop through all 12 cases.
@ test_case = 1
while ($test_case <= 12)
	echo "Test case #$test_case"
	echo
	$gtm_dist/mumps -run fallintoflst${test_case}
	echo
	$echoline
	@ test_case = $test_case + 1
end
