#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This file should be run, not SOURCE'd, otherwise the computation of ${0:h}
# will fail while detecting the current $gtm_test/T9XX/com for gtmroutines.
# Using ${0:h} instead of $gtm_tst avoids test system dependencies.

# Failsafe echo argv back
echo "set newargs = '${argv}'"

# Test for REPLAY
if ($?gtm_test_dbcargs) then
	echo "set newargs = '${gtm_test_dbcargs}'"
	exit
endif

# By default, no debugging
if !($?gtm_test_debug) then
	set gtm_test_debug=0
endif

# Add environment required by dbcargs.m
set curpro_env = (	gtm_test_spannode=${gtm_test_spannode}		\
			gtm_test_debug=${gtm_test_debug}		\
			gtm_verno=${gtm_verno}				\
			)

# Run dbcargs.m under curpro
set newargs = `${0:h}/mumps_curpro.csh -cur_routines ${curpro_env:q} -run dbcargs ${argv}`

# output CSH commands to be sourced
if ( "${newargs}" != "" ) then
	echo "set newargs = '${newargs}'"
endif
