#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# turn off gtmdbglvl in case it is turned on. Avoids unwanted output
unsetenv gtmdbglvl
# Not using %XCMD as this script is used in various cases by older versions too in the test system.
# Switch gtmroutines to temporarily point to utilobj directory to take care of using com utilities with different versions/chset
source $gtm_tst/com/set_gtmroutines_utils.csh
if ("count" == "$1") then
	$gtm_exe/mumps -run count^getregls
else
	$gtm_exe/mumps -run getregls
endif
