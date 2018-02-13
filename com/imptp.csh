#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# $1 = Number of process 	! Optional Parameter
#
# Always output should be redirected to a file by caller.
# Because otherwise verbose output from job.m causes reference file problem
# By default usage of job.m from the M programs below cause verbose output
#
#
# If non-TP is chosen for crash tests to do application level verification some TP transactions are used in imptp.m.
# But GT.CM does not support TP for now, we will not use any TP transactions for it at all.
# We assume when GT.CM is chosen it will not be a crash test.
#

# Set gtm_test_trigger based on whether triggers are supported on the platform in which imptp.csh is executed. This is
# needed for cases where a multihost test invokes imptp.csh remotely on a machine that does not support triggers. In
# such cases, MUPIP TRIGGER command and other $ztrigger statements will error out.
if (-e $gtm_tools/check_trigger_support.csh) then
	if ("FALSE" == `$gtm_tools/check_trigger_support.csh`) then
		setenv gtm_test_trigger "0"
	endif
endif

if (($gtm_test_trigger) && !($?test_specific_trig_file)) set trigger_load=1
\pwd
if ($gtm_test_crash == 1)	echo "This is a crash test"
if ("GT.CM" == $test_gtm_gtcm) setenv gtm_test_is_gtcm 1
if ("$1" != "") setenv gtm_test_jobcnt "$1"

$gtm_tst/com/imptp_savemjo.csh
if ($gtm_test_dbfill == "IMPTP" || $gtm_test_dbfill == "IMPZTP") then
	if (($?trigger_load) && ($gtm_test_dbfill == "IMPTP")) then
		# Test has specified -trigger and we are going to use imptp.m.
		# Load triggers in the database.
		$gtm_exe/mumps -run dollarztrigger $gtm_tst/com/imptp.trg
		$gtm_exe/mumps -run ztrsupport 'if $ztrigger("file",$ztrnlnm("gtm_tst")_"/com/imptpztr.trg")'
	endif
	setenv gtm_badchar "no"
	# Randomly choose to run M or C (simpleAPI) version of the test
	if !($?gtm_test_replay) then
		set usesimpleapi = `$gtm_exe/mumps -run rand 2`
		echo "setenv usesimpleapi $usesimpleapi" >> settings.csh
		set usesimpleapi = 1	# NARSTODO
		# NARSTODO : If online rollback test, then usesimpleapi has to be set to 0.
		# this is because imptp.m transfers control to an M label "orlbkres^imptp" etc. for online rollbacks
		# and that is not straightforward with simpleAPI.
	endif

	if (! $usesimpleapi) then
		$GTM << xyz
		set jobcnt=\$\$^jobcnt
		w "do ^imptp(jobcnt)",!  do ^imptp(jobcnt)
		h
xyz

	else
		# Run simpleAPI equivalent of ^imptp
		set file="simpleapi_imptp.c"
		cp $gtm_tst/com/$file .
		set exefile = $file:r
		$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$ydb_dist $file
		$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
		if (0 != $status) then
			echo "LVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
			exit -1
		endif
		# Setup call-in table : Need call-ins to do a few tasks that are not easily done through simpleAPI
		cat > imptp.xc << CAT_EOF
getdatinfo: void getdatinfo^imptpxc()
impjob: void impjob^imptp()
writecrashfileifneeded: void writecrashfileifneeded^job()
writejobinfofileifneeded: void writejobinfofileifneeded^job()
CAT_EOF
		setenv GTMCI imptp.xc
		# Run simpleAPI executable
		`pwd`/$exefile
	endif
else if ($gtm_test_dbfill == "IMPRTP") then
	$GTM << xyz
	w "do imprtp",!  do ^imprtp
	h
xyz
else if ($gtm_test_dbfill == "SLOWFILL") then
	# Load triggers only if this test does not have GT.CM enabled as GT.CM does not have trigger support.
	# gtm_test_is_gtcm will always be defined since it is set to 0 unconditionally in submit_test.csh.
	# Hence $?gtm_test_is_gtcm check is not needed
	if (($?trigger_load) && (0 == $gtm_test_is_gtcm)) then
		# Test has specified -trigger and we are going to use slowfill.m
		# Load triggers in the database.
		$gtm_exe/mumps -run dollarztrigger $gtm_tst/com/slowfill.trg
	endif
	$GTM << xyz
	set jobcnt=\$\$^jobcnt
	w "do ^slowfill(jobcnt)",!  do ^slowfill(jobcnt)
	h
xyz
else if ($gtm_test_dbfill == "FIXTP") then
	 # TP size is constant in the fill program
	if ($?trigger_load) then
		# Test has specified -trigger and we are going to use fixtp.m
		# Load triggers in the database.
		$gtm_exe/mumps -run dollarztrigger $gtm_tst/com/fixtp.trg
	endif
	$GTM << xyz
	set jobcnt=\$\$^jobcnt
	w "do fixtp",!  do ^fixtp	; This is single process for now
	h
xyz
endif	# endif
