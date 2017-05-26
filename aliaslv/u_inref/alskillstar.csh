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

# Test that KILL * works when there are LOTS of aliased unsubscripted variable names

$gtm_exe/mumps -run alskillstargen	# this generates alskillstar.m the real program to run

# The stringpool array size is usually a lot smaller in direct mode versus "mumps -run".
# We want a small array size to demonstrate this issue. So trying just direct mode is enough.
# But we try "mumps -run" too to make sure both cases work fine.
echo "-----------------------------------"
echo "Running ^alskillstar in Direct Mode"
echo "-----------------------------------"
$GTM << GTM_EOF
	do ^alskillstar
GTM_EOF

echo "-----------------------------------"
echo "Running ^alskillstar in MUMPS -RUN mode"
echo "-----------------------------------"
$gtm_exe/mumps -run ^alskillstar
