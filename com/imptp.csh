#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
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

# Note that any code path below that exits with a non-zero status should also print a "-E-" message (e.g. "TEST-E-FAILED")
# as this is relied upon by the caller script which would call com/imptp_check_error.csh immediately after the imptp.csh call.
# That script can only check for errors by the presence of the "-E-" messages.

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
	# Randomly choose to run M (rand=0), C simpleAPI (rand=1), C simpleThreadedAPI (rand=2), Python (rand=3), Golang (rand=4), or Rust (rand=5) version of imptp
	if !($?gtm_test_replay) then
		if ($?ydb_imptp_flavor) then
			if ((0 > $ydb_imptp_flavor) || (5 < $ydb_imptp_flavor)) then
				echo "TEST-E-FAILED : Invalid flavor of imptp specified: $ydb_imptp_flavor - allowed values, 0, 1, 2, 3, 4, or 5"
				exit 1
			else if (5 == $ydb_imptp_flavor && true != $rust_supported) then
				echo "# Warning: rust flavor was explicitly specified, but Rust is not supported on this platform"
				set imptpflavor = `$gtm_exe/mumps -run rand 5`
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
			# Need to run this because it is possible for "imptp.csh" to be run on a remote host in
			# a multi-host test run where the local host does not have asan enabled but the remote host has.
			source $gtm_tst/com/set_asan_other_env_vars.csh	# sets a few other associated asan env vars
			if ((true == $rust_supported) && ! $gtm_test_libyottadb_asan_enabled) then
				set rand = 6
			else if ($gtm_test_libyottadb_asan_enabled) then
				if ("clang" == $gtm_test_asan_compiler) then
					# Disable Go testing if ASAN and CLANG. It is okay to disable Rust in this case as well,
					# since ASAN and Rust do not work well together.
					# See similar code in "com/gtmtest.csh" for details.
					set rand = 4
				else
					set rand = 5
				endif
			endif
			set imptpflavor = `$gtm_exe/mumps -run rand $rand`
			# Disable YDBRust testing if the cargo/rustc version is 1.68.*
			# We have seen the following error when building imptp.rs in that case.
			#	error[E0432]: unresolved imports `crate::craw::YDB_DEL_TREE`, `crate::craw::YDB_DEL_NODE`
			# The current suspicion is that it is a rust/cargo regression and will be fixed in a later version.
			#
			# Additionally, we have seen that even cargo/rustc version 1.69.* fails with the same errors as above but
			# only on a openSUSE Tumbleweed system. openSUSE Leap or SUSE Linux Enterprise Desktop systems
			# which have the exact same cargo/rustc version do not have this issue. Not sure why.
			# Therefore we disable YDBRust random choice for imptp.csh on a Tumbleweed system.
			set rustcminorver = `rustc --version | cut -d. -f2`
			set distrib = `grep -w ID /etc/os-release | cut -d= -f2 | cut -d'"' -f2`
			if ((68 == $rustcminorver) || ($distrib == "opensuse-tumbleweed")) then
				while (5 == $imptpflavor)
					echo "# Disabling ydb_imptp_flavor=5 (YDBRust) due to rust/cargo 1.68 or openSUSE Tumbleweed" >> settings.csh
					set imptpflavor = `$gtm_exe/mumps -run rand $rand`
				end
			endif
			# Disable YDBPython testing if python3 version is 3.11.*
			# We have seen one of the following symptoms when building imptp.py in that case.
			#	SystemError: unknown opcode
			#	SIG-11 in _PyEval_EvalFrameDefault()
			# This has been seen only on a Ubuntu 23.04 system and the current suspicion is that it is a
			# python3 regression that will be fixed in a later version. The python version then was 3.11.2
			# Later we saw a similar failure in a OpenSUSE Tumbleweed system where the python3 version was
			# 3.11.4 so we disable YDBPython testing if python version is 3.11.*.
			set python3ver = `python3 --version | cut -d" " -f2 | cut -d. -f1,2`
			if ("3.11" == $python3ver) then
				while (3 == $imptpflavor)
					echo "# Disabling ydb_imptp_flavor=3 (YDBPython) due to python3 3.11.*" >> settings.csh
					set imptpflavor = `$gtm_exe/mumps -run rand $rand`
				end
			endif
			# Disable Python testing if ASAN is enabled and Rust version is 1.58.* or 1.59.*
			# to prevent erroneous core files from `rustc --version`.
			# This command is run by YDBPython's `setup.py`, during the setting of
			# LD_PRELOAD, e.g.:
			#	LD_PRELOAD=$(gcc -print-file-name=libasan.so) rustc --version
			# On systems with Rust version 1.58.*, 1.59.* or 1.60.* or 1.61.* (all versions only on an Arch
			# Linux system, not on a Ubuntu/Debian/RHEL system), this has been seen to result in a
			# segmentation fault. So, disable YDBPython random choice on Arch Linux.
			# See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1299#note_839072462 and
			# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1385#note_972287548 for more details.
			if (($gtm_test_libyottadb_asan_enabled) && ("arch" == $gtm_test_linux_distrib)) then
				while (3 == $imptpflavor)
					echo "# Disabling ydb_imptp_flavor=3 (YDBPython) due to ASAN + Arch Linux" >> settings.csh
					set imptpflavor = `$gtm_exe/mumps -run rand $rand`
				end
			endif
			# Disable Python testing if YottaDB is built with ASAN and CLANG.
			# In that case, setting the LD_PRELOAD env var (which the YDBPython wrapper sets whenever it
			# finds YottaDB is built with ASAN, be it CLANG or GCC) results in the following error
			#	Your application is linked against incompatible ASan runtimes
			# This happens when invoking $ydb_dist/yottadb from within the YDBPython wrapper (which can happen
			# for example if the %YDBPROCSTUCKEXEC mechanism is invoked by the test framework in case the
			# YDBPython wrapper notices a MUTEXLCKALERT situation). Such occurrences would result in a core
			# file which would fail the test.
			# Note that if YottaDB is built with ASAN and GCC, then we don't have a similar issue. This is because
			# gcc links the asan runtime library dynamically whereas clang links it statically (-static-libasan).
			if ($gtm_test_libyottadb_asan_enabled) then
				if ("clang" == $gtm_test_asan_compiler) then
					while (3 == $imptpflavor)
						echo "# Disabling ydb_imptp_flavor=3 (YDBPython) due to CLANG + ASAN" >> settings.csh
						set imptpflavor = `$gtm_exe/mumps -run rand $rand`
					end
				endif
			endif
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
	case 3: # Run Python wrapper (uses simpleAPI) flavor of imptp
		# Initialize $prompt to prevent `Undefined variable` error from activate.csh
		setenv prompt ""
		if (! -e python) then # Python install directory not setup, create now
			source $gtm_tst/com/setuppyenv.csh # Do our Python setup (sets $tstpath)
			set status1 = $status
			if ($status1) then
				echo "TEST-E-FAILED : [source $gtm_tst/com/setuppyenv.csh] failed with status [$status1]"
				exit 1
			endif
		else
			# Activate virtual environment to provide access to local `yottadb` Python module
			source python/.venv/bin/activate.csh
		endif
		# Using YDBPython with ASAN requires 2 env vars to be set.
		# ASAN_OPTIONS and LD_PRELOAD. See YottaDB/Lang/YDBPython@479e80a2 for details.
		# YDBTest test framework already sets ASAN_OPTIONS. So only need to set LD_PRELOAD.
		if ($gtm_test_libyottadb_asan_enabled) then
			setenv LD_PRELOAD `gcc -print-file-name=libasan.so`
		endif
		ln -sf "$gtm_tst/com/imptp.py" .
		ln -sf "$gtm_tst/com/impjob.py" .
		set exefile = "imptp.py"
		breaksw
	case 4: # Run Golang wrapper (uses SimpleThreadAPI) flavor of imptp
		if (! -e go) then # if no go environment setup yet, do it
			source $gtm_tst/com/setupgoenv.csh # Do our golang setup (sets $tstpath)
			set status1 = $status
			if ($status1) then
				echo "TEST-E-FAILED : [source $gtm_tst/com/setupgoenv.csh] failed with status [$status1]"
				exit 1
			endif
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
	case 5: # Run Rust wrapper using SimpleThreadAPI flavor of imptp
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
