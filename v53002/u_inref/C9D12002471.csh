#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9D12-002471  Test outofmemory condition for (new) correct handling.
#
# Disable implicit mprof testing to prevent failures due to extra memory footprint;
# see <mprof_gtm_trace_glb_name_disabled> for more detail
unsetenv gtm_trace_gbl_name

# If gtmdbglvl had been set, reset it unconditionally since otherwise we will be doing malloc storage chain verification
# for EVERY malloc/free. This test does a LOT of mallocs until the virtual memory limit is exceeded so the GT.M process
# will be burning lots and lots of CPU time doing only verifications before it reaches the memory limit. This causes the
# test to run for hours. To avoid this situation, we turn off gtmdbglvl checking for this particular subtest.
unsetenv gtmdbglvl

# Also disable autorelink to avoid issues with being unable to allocate shared memory for the object code.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

$gtm_tst/com/dbcreate.csh mumps 1 255 1000 1024 500 4096

if !(("hp-ux" == "$gtm_test_osname") || ("aix" == "$gtm_test_osname")) then
	# Linux kernels seem to kill processes that eat up a lot of virtual memory. This has been observed at least in scylla.
	# To overcome that problem, we invoke setrlimit() system function via an external call to limit our virtual memory quota
	# and then run the M program. The reason we do not use the shell built-in 'limit vmemoryuse' is because it affects the
	# tcsh process itself, occasionally causing it to core. The limit chosen randomly and is exercised on Linux and SunOS
	# boxes.
	source $gtm_tst/com/cre_xcall_utils.csh

	if !($?gtm_test_replay) then
		# The quota has to leave the process room to attach the database shared memory, which it does at its first
		# global variable reference, well after "setup^c002471" has set the quota. A quota below what the process has
		# already mapped by then makes the "shmat()" fail with ENOMEM, and the subtest gets a DBFILERR at that first
		# reference instead of the MEMORY error it is testing for (YDBTest#1057). An absolute quota cannot guarantee
		# that room, because the address space a "mumps" process starts with is not something this test controls: in
		# UTF-8 mode the glibc locale archive and the ICU libraries alone map more than 300Mb on some systems, and
		# they grow as those files grow. So measure the baseline with a "mumps" process of the build under test in
		# this environment, and pick the quota relative to it.
		set vmbase = `$gtm_exe/mumps -run vmsize^c002471`
		if ("$vmbase" == "") set vmbase = 0	# /proc is unavailable; fall back to an absolute quota as before
		# Generates a random number between 64K and 512K, which is the amount of address space in Kb, over and above
		# the baseline, that c002471 gets to exhaust. The lower end is small enough that the process runs out of
		# memory quickly and the upper end is what it took before this was made relative to the baseline.
		set vmincr = `$gtm_exe/mumps -run %XCMD 'write (2**16)+$r((2**19)-(2**16))'`
		@ vmlimit = $vmbase + $vmincr
		setenv gtm_test_vlimit $vmlimit
		echo "# Randomly chosen virtual memory limit ($vmbase Kb baseline + $vmincr Kb):"	>>&! settings.csh
		echo "setenv gtm_test_vlimit $gtm_test_vlimit"						>>&! settings.csh
	endif
endif

$gtm_exe/mumps -run test1^c002471
$gtm_exe/mumps -run test2^c002471

# On Solaris (and on Linux when poollimit is set), move the cores away because we run out of backpocket occasionally
if ("SunOS" == $HOSTOS || "Linux" == $HOSTOS) then
	# Verify that there is at least one ENO12 error
	$grep -q "ZSTATUS=.*ENO12" YDB_FATAL_ERROR.*
	if (0 == $status) then
		# Move the cores without altering their creation relative time
		set nonomatch; set cores=(core*); unset nonomatch
		if ("$cores" != "core*") then
			foreach file (`ls -tr $cores`)
				mv $file case_${file}
			end
		endif
	endif
endif

foreach file ( YDB_FATAL_ERROR* )
	# A process that has run out of memory can run out of it a second time inside $ZJOBEXAM() itself.
	# ZSHOW reports $REFERENCE by calling "get_reference", that does a stringpool garbage collection,
	# and the collection asks "gtm_malloc" for a block a process at its virtual memory limit cannot
	# get. YottaDB then issues a JOBEXAMFAIL (to the syslog) and stops writing, leaving the dump
	# ending wherever ZSHOW had reached, which for the above is the intrinsic special variable just
	# ahead of $REFERENCE. That is an expected outcome of a test whose whole purpose is to run a
	# process out of memory, so the completeness check below must not be applied to such a dump.
	# ZSHOW writes the global statistics after the local and intrinsic special variables and before
	# the stack and external calls listing, so whether those statistics are there tells a dump that
	# stopped early apart from one that was written in full.
	$grep -q "^GLD:.*,REG:" $file
	if (0 == $status) then
		# Check the last line from each of the two generated YDB_FATAL_ERROR files.
		# This verifies the files were complete and correctly generated. ZSHOW writes the
		# external calls listing last, one line per entry of each loaded package, formatted
		# as <package>.<entry>. This subtest loads exactly one such package: the
		# "cre_xcall_utils.csh" sourced above builds libutils and points GTMXC_utils at a
		# utils.xc declaring a "setrlimit" entry, which is how the subtest sets the virtual
		# memory limit it then exhausts. So a dump written in full ends in exactly
		# "utils.setrlimit", and filtering that line out leaves nothing to report. Match the
		# whole line rather than just the package name, so that a last line which is close but
		# not what is expected still gets reported. Note the single quotes: tcsh reads the "$"
		# of an anchored pattern inside double quotes as the start of a variable name and dies
		# with "Illegal variable name".
		$tail -n1 $file | $grep -v '^utils\.setrlimit$'
	endif
	# Move the YDB_FATAL_ERROR.* files, so that error catching mechanism do not show invalid failures
	mv $file `echo $file | $tst_awk -F 'YDB_' '{print $2}'`
end

$gtm_tst/com/dbcheck.csh
