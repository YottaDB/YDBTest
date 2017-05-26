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

# Get relevant paths initialized for Java.
source $gtm_tst/com/set_java_paths.csh >&! /dev/null

# Set gtm_test_java_supported if applicable.
if (! $status) then
	setenv gtm_test_java_support 1
else
	setenv gtm_test_java_support 0
endif
