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
# gtmdist 		[bahirs] 	Test that JOB command uses the same mumps executable as that of parent to start the new mumps

unsetenv gtmcompile
$gtm_exe/mumps -run gtmdist
