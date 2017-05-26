#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# A tool to (re)randomize environment variables
# Usually used to re-randomize environment variables that are randomized by the framework
# 	- With a limited scope (e.g test_replic_suppl_type)
# 	- In tests where randomization was previously disabled/not done (e.g gtm_test_jnl)

set var_to_randomize = "$1"
set values_to_randomize = "$2"

if ("" == "$values_to_randomize") then
	switch ($var_to_randomize)
		case "gtm_test_jnl":
			set values_to_randomize = "SETJNL NON_SETJNL"
			breaksw;
		default:
			echo "set_env_random-E-INVALID_VAR: $var_to_randomize is not recognized var by this tool"
			exit 1
	endsw
endif

 # Switch gtmroutines to temporarily point to utilobj directory to take care of using com utilities with different versions/chset
source $gtm_tst/com/set_gtmroutines_utils.csh
set random_value = `$gtm_exe/mumps -run chooseamong $values_to_randomize`

# Restore gtmroutines, as this script is "sourced"
source $gtm_tst/com/set_gtmroutines_utils.csh restore

setenv $var_to_randomize $random_value
echo "# $var_to_randomize randomized by set_env_random.csh"	>>&! settings.csh
echo "setenv $var_to_randomize $random_value"			>>&! settings.csh

unset var_to_randomize values_to_randomize random_value
