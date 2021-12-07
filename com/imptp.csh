#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2021 YottaDB LLC and/or its subsidiaries.	#
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
	if (! $?gtm_test_replay) then
		@ rand = `$gtm_exe/mumps -run rand 2`
		# If rand = 0 -> set env var here
		if (0 == $rand) then
			set noisolist = "^arandom,^brandomv,^crandomva,^drandomvariable,^erandomvariableimptp"
			set noisolist = "$noisolist,^frandomvariableinimptp,^grandomvariableinimptpfill"
			set noisolist = "$noisolist,^hrandomvariableinimptpfilling,^irandomvariableinimptpfillprgrm"
			set noisolist = "$noisolist,^jrandomvariableinimptpfillprogram"
			setenv ydb_app_ensures_isolation "$noisolist"
			echo "setenv ydb_app_ensures_isolation $noisolist"	>> settings.csh
		endif
		# If rand = 1 (i.e. ydb_app_ensures_isolation env var is not set) -> do VIEW "NOISOLATION" command later in imptp.m
	endif
	if (($?trigger_load) && ($gtm_test_dbfill == "IMPTP")) then
		# Test has specified -trigger and we are going to use imptp.m.
		# Load triggers in the database.
		$gtm_exe/mumps -run dollarztrigger $gtm_tst/com/imptp.trg
		$gtm_exe/mumps -run ztrsupport 'if $ztrigger("file",$ztrnlnm("gtm_tst")_"/com/imptpztr.trg")'
	endif
	setenv gtm_badchar "no"
	set rust_supported = `tcsh $gtm_tst/com/is_rust_supported.csh`
	# Randomly choose to run M (rand=0), C simpleAPI (rand=1), C simpleThreadedAPI (rand=2), Golang (rand=3), or Rust (rand=4) version of imptp
	if !($?gtm_test_replay) then
		if ($?ydb_imptp_flavor) then
			if ((0 > $ydb_imptp_flavor) || (4 < $ydb_imptp_flavor)) then
				echo "TEST-E-FAIL Invalid flavor of imptp specified: $ydb_imptp_flavor - allowed values, 0, 1, 2, 3, or 4"
				exit 1
			else if (4 == $ydb_imptp_flavor && true != $rust_supported) then
				echo "# Warning: rust flavor was explicitly specified, but Rust is not supported on this platform"
				set imptpflavor = `$gtm_exe/mumps -run rand 4`
				echo "Choosing flavor $imptpflavor instead"
			else
				echo "# Inheriting imptpflavor from env var ydb_imptp_flavor"
				set imptpflavor = $ydb_imptp_flavor # Override and force a given flavor
			endif
		else
			echo "# Choosing imptpflavor randomly"
			# Rust stable currently does not support ASAN. Only nightly does.
			# https://doc.rust-lang.org/beta/unstable-book/compiler-flags/sanitizer.html lists following issues
			#	https://github.com/rust-lang/rust/issues/39699
			#	https://github.com/rust-lang/rust/issues/89653
			# Wait for Rust stable to support ASAN before enabling it. Until then do not choose rust
			# for imptp if YottaDB build has ASAN enabled.
			source $gtm_tst/com/is_libyottadb_asan_enabled.csh
			if ((true == $rust_supported) && ! $gtm_test_libyottadb_asan_enabled) then
				set rand = 5
			else
				set rand = 4
			endif
			set imptpflavor = `$gtm_exe/mumps -run rand $rand`
			unset rand
		endif
		echo "imptpflavor: $imptpflavor"
		echo "setenv ydb_imptp_flavor $imptpflavor" >> settings.csh
	else
		set imptpflavor = $ydb_imptp_flavor
	endif
	# If using a version that is other than the currently tested version, disable simpleapi for the older version.
	if ("$gtm_verno" != "$tst_ver") then
		set imptpflavor = 0
		echo "# Disabling simpleapi due to using current version $gtm_verno (other than test version $tst_ver)"
		echo "setenv ydb_imptp_flavor $imptpflavor" >> settings.csh
	endif
	# If online rollback test, then disable simpleapi. This is because imptp.m transfers control to an M label
	# "orlbkres^imptp" etc. for online rollbacks and that is not straightforward with simpleAPI.
	if ($?gtm_test_onlinerollback) then
		if ($gtm_test_onlinerollback == "TRUE") then
			set imptpflavor = 0
			echo "# Disabling simpleapi due to using online rollback"
			echo "setenv ydb_imptp_flavor $imptpflavor" >> settings.csh
		endif
	endif
	set file = ""
	switch ($imptpflavor)
	case 0: # Run M flavor of imptp
		$GTM << xyz
		set jobcnt=\$\$^jobcnt
		w "do ^imptp(jobcnt)",!  do ^imptp(jobcnt)
		h
xyz
		exit $status # Nothing left to do in this script after driving M version
		breaksw
	case 1:	# Run C SimpleAPI flavor of imptp
		set file = "simpleapi_imptp.c"
		# Fall into next case
	case 2: # Run C SimpleThreadAPI flavor of imptp
		if ("" == "$file") then
			set file = "simplethreadapi_imptp.c"
		endif
		# common code for our two C flavors
		cp $gtm_tst/com/$file .
		set exefile = $file:r
		$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$ydb_dist $file
		$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
		if (0 != $status) then
			echo "LVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
			exit -1
		endif
		breaksw
	case 3: # Run Golang wrapper (uses SimpleThreadAPI) flavor of imptp
		if (! -e go) then # if no go environment setup yet, do it
			source $gtm_tst/com/setupgoenv.csh # Do our golang setup (sets $tstpath)
		endif
		if (! -e imptpgo) then # if imptpgo hasn't been built yet, get it and impjobgo built
			cd go/src
			mkdir imp
			mkdir imptpgo
			mkdir impjobgo
			ln -s $gtm_tst/com/imp.go imp/imp.go
			set status1 = $status
			if ($status1) then
				echo "TEST-E-FAILED : Unable to soft link imp.go to current directory ($PWD)"
				exit 1
			endif
			ln -s $gtm_tst/com/imptpgo.go imptpgo/imptpgo.go
			if ($status1) then
				echo "TEST-E-FAILED : Unable to soft link imptpgo.go to current directory ($PWD)"
				exit 1
			endif
			ln -s $gtm_tst/com/impjobgo.go impjobgo/impjobgo.go
			if ($status1) then
				echo "TEST-E-FAILED : Unable to soft link impjobgo.go to current directory ($PWD)"
				exit 1
			endif
			cd imptpgo
			$gobuild
			if (0 != $status) then
				echo "TEST-E-FAILED : Unable to build imptpgo.go"
				exit 1
			endif
			cd ../impjobgo
			$gobuild
			if (0 != $status) then
				echo "TEST-E-FAILED : Unable to build impjobgo.go"
				exit 1
			endif
			cd ../../.. # back to main test directory
			# Now make a link to imptpgo from main test directory
			ln -s go/src/imptpgo/imptpgo .
			if ($status1) then
				echo "TEST-E-FAILED : Unable to soft link imptpgo.go to main test directory ($PWD)"
				exit 1
			endif
		endif
		set exefile = "imptpgo"
		breaksw
	case 4: # Run Rust wrapper using SimpleThreadAPI flavor of imptp
		if (true != $rust_supported) then
			# This should never happen, it is caught above
			echo "TEST-E-FAILED : Rust is not supported and yet was run"
			exit 1
		endif

		# Setup rust wrapper
		source $gtm_tst/com/setuprustenv.csh
		# See comments in `real_gtm_tst_out.csh` for details
		set gtm_tst_out = `$gtm_tst/com/real_gtm_tst_out.csh $gtm_tst_out`
		if (0 != $status) then
			echo "TEST-E-FAILED : Failed to determine the absolute path of \$gtm_tst_out"
			exit 1
		endif
		# Build the Rust imptp program if not already built
		# NOTE: this only builds once for a single E_ALL test run,
		# since imptp.rs takes a while to build
		if (! -e $gtm_tst_out/imptpjobrust) then
			# Don't copy over target/ since it may be very large (as much as 10 GB)
			rm -rf $gtm_tst/com/imptp-rs/target
			cp -r $gtm_tst/com/imptp-rs/ $gtm_tst_out/imptp-rs/
			cd $gtm_tst_out/imptp-rs
			$cargo_build
			if (0 != $status) then
				echo "TEST-E-FAILED : Unable to build imptp.rs"
				exit 1
			endif
			# Now move imptprust to main test directory
			mv "target/$rust_target_dir/imptp" ../imptprust
			mv "target/$rust_target_dir/imptpjob" ../imptpjobrust
			# Go back to the original test directory
			cd -
		endif
		# Link the binaries to the current directory, replacing them if they already exist.
		# Replacing the binary avoids failures if imptp is run multiple times in the same test.
		ln -sf "$gtm_tst_out/imptpjobrust" .
		set status1 = $status
		if ($status1) then
			echo "TEST-E-FAILED : Unable to soft link imptpjobrust to current directory ($PWD)"
			exit 1
		endif
		ln -sf "$gtm_tst_out/imptprust" .
		set status1 = $status
		if ($status1) then
			echo "TEST-E-FAILED : Unable to soft link imprust to current directory ($PWD)"
			exit 1
		endif
		set exefile = "imptprust"
		breaksw
	endsw
	# Setup call-in table : Need call-ins to do a few tasks that are not easily done through simpleAPI
	cat > imptp.xc << CAT_EOF
dupsetnoop: void dupsetnoop^imptpxc()
getdatinfo: void getdatinfo^imptpxc()
helper1: void helper1^imptpxc()
helper2: void helper2^imptpxc()
helper3: void helper3^imptpxc()
imptpdztrig: void imptpdztrig^imptpxc()
impjob: void impjob^imptp()
noop: void noop^imptp()
tpnoiso: void tpnoiso^imptpxc()
writecrashfileifneeded: void writecrashfileifneeded^job()
writejobinfofileifneeded: void writejobinfofileifneeded^job()
ztrcmd: void ztrcmd^imptpxc()
ztwormstr: void ztwormstr^imptpxc()
CAT_EOF
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ci GTMCI imptp.xc
	# Run simpleAPI executable
	`pwd`/$exefile
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
