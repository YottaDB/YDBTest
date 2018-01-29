#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
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
# This script just calls the stress runs. This script exists so that the callcan be backgrounded

if ("init" == "$1") then
$GTM << GTM_EOF
do init^concurr("$2","$3")
GTM_EOF

endif

@ exit_status = 0

if ("run" == "$1") then
	# Randomly choose to run M or C (simpleAPI) version of the test
	if !($?gtm_test_replay) then
		set usesimpleapi = `$gtm_exe/mumps -run rand 2`
		echo "setenv usesimpleapi $usesimpleapi" >> settings.csh
	endif
	if ($usesimpleapi) then
		# Run simpleAPI equivalent of run^concurr
		set exit_status = $status # run^concurr could return non-zero exit status through "zhalt 255" done in stress/inref/stress.m
		set file="simpleapi_run_concurr.c"
		cp $gtm_tst/$tst/inref/$file .
		set exefile = $file:r
		$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
		$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
		if (0 != $status) then
			echo "LVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
			continue
		endif
		`pwd`/$exefile $2
		set exit_status = $status
	else
		$gtm_exe/mumps -run %XCMD 'do run^concurr('$2')'
		set exit_status = $status # run^concurr could return non-zero exit status through "zhalt 255" done in stress/inref/stress.m
	endif
	if (0 == $exit_status) then
		$gtm_exe/mumps -run %XCMD 'do verify^concurr'
		set exit_status = $status
	endif
endif

exit $exit_status
