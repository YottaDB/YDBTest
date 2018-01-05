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
	set usesimpleapi = `$gtm_exe/mumps -run rand 2`
	set usesimpleapi = 1	# NARSTODO : remove this
	if ($usesimpleapi) then
		set exit_status = $status # run^concurr could return non-zero exit status through "zhalt 255" done in stress/inref/stress.m
		./run_concurr $2
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
