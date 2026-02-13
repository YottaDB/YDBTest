#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-F135288 - Test the following release note
*****************************************************************

Release note http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-F135288 says:

> When the gtm_pinshm environment variable is defined and
> evaluates to a non-zero integer or any case-independent
> string or leading substring of TRUE or YES in a process
> creating shared memory, GT.M attempts to pin such memory
> used for database global buffers, replication buffers,
> and routine buffers into physical memory. Huge pages are
> implicitly locked in physical memory, so GT.M does not attempt
> to pin shared memory buffers backed by huge pages. gtm_pinshm
> does not pin memory used by online INTEG (integ snapshot).
> Pinning  may not succeed due to insufficient physical memory
> and/or OS configuration. When the gtm_hugetlb_shm environment
> variable is defined and evaluates to a non-zero integer or any
> case-independent string or leading substring of TRUE or YES
> in a process creating shared memory, GT.M attempts to back all
> such shared memory segments with huge pages, using the default
> huge page size. If huge pages cannot be used, GT.M tries to
> back the shared memory with base pages instead, and attempts to
> pin the shared memory if requested with gtm_pinshm. GT.M issues
> a SHMHUGETLB or SHMLOCK warning message to the system log when
> the system is unable to back shared memory with huge pages or
> is unable to pin shared memory to physical memory, respectively.
> Previously, GT.M did not support the gtm_pinshm option to pin
> memory, and gtm_hugetlb_shm replaces the use of libhugetlbfs
> for huge page functions, so GT.M no longer evaluates
> libhugetlbfs environment variables, e.g. HUGETLB_SHM,
> HUGETLB_VERBOSE, etc. [Linux] (GTM-F135288)
CAT_EOF

echo
echo "# ---- prepare ----"
set uid = `id -u`

echo "# check if version supports hugetlb_shm feature"
foreach libf ( "$gtm_dist/libyottadb.so" "$gtm_dist/libgtmshr.so")
	if ( -f  "$libf" ) then
		set found = `strings "$libf" | grep hugetlb_shm_enabled | wc -l`
		if (0 == $found) then
			echo "TEST-E-ERROR: This version does not support hugetlb_shm"
			exit
		endif
	endif
end

# set error prefix
setenv ydb_msgprefix "GTM"

# unset gtm_hugetlb_shm and gtm_pinshm if randomized by test system
unsetenv gtm_hugetlb_shm gtm_pinshm ydb_hugetlb_shm ydb_pinshm

# print group id into a file
id -g > enable_group_id.txt
echo 0 > disable_group_id.txt

# backup original /proc/sys/vm/hugetlb_shm_group
sudo cp /proc/sys/vm/hugetlb_shm_group hugetlb_shm_group.bak

set POS = `$gtm_dist/mumps -run randarg 1 2 999 y Y yes Yes YES t T tr Tr TR true True TRue TRUE`
set NEG = `$gtm_dist/mumps -run randarg 0 n N no No NO f F fa Fa FA false False FaLSe FALSE`

# this line should be in the output but not compared to the reference
echo '# using "'$POS'" and "'$NEG'" for env values' > randomvalues.txt

foreach parms ( "/" "0/0" "1/0" "0/1" "1/1" )
	set pin = `echo $parms | cut -d/ -f1`
	set huge = `echo $parms | cut -d/ -f2`

	foreach enabled ( "enable" "disable" )
		# On Ubuntu 22.04, disable part of test since the strace output differs due to a Kernel bug
		# See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2114#note_2199484611
		if (("ubuntu" == $gtm_test_linux_distrib) && ("22.04" == $gtm_test_linux_version) && ("disable" == $enabled) && (1 == $huge)) then
			continue
		endif

		foreach setbuf ( "set" "not" )

			# skip invalid cases: when SHM is disabled, setting buffer size is irrelevant
			if ( "disable" == $enabled && "set" == $setbuf ) then
				continue
			endif

			# parse parmeter strings (pr_* for printable version, fn_* for filename)

			if ("" == $pin) then
				set pr_pinshm="(unset)"
				set fn_pinshm="u"
			else
				set pr_pinshm='"'${pin}'"'
				set fn_pinshm=${pin}

				if (1 == $pin) then
					setenv gtm_pinshm $POS
				else
					setenv gtm_pinshm $NEG
				endif
			endif

			if ("" == $huge) then
				set pr_hugetlb_shm="(unset)"
				set fn_hugetlb_shm="u"
			else
				set pr_hugetlb_shm='"'${huge}'"'
				set fn_hugetlb_shm=${huge}

				if (1 == $huge) then
					setenv gtm_hugetlb_shm $POS
				else
					setenv gtm_hugetlb_shm $NEG
				endif
			endif

			set pr_enabled = '"'${enabled}'"'
			if ("enable" == $enabled) then
				sudo cp enable_group_id.txt /proc/sys/vm/hugetlb_shm_group
			else
				sudo cp disable_group_id.txt /proc/sys/vm/hugetlb_shm_group
			endif
			# Another process may modify /proc/sys/vm/hugetlb_shm_group after it was set in the preceding block.
			# This could cause unexpected by erroneous failures depending on the new value set by the competing process.
			# So, save the modification time of that file for a later check to confirm that it was not subsequently modified.
			set hugetlb_shm_group_init_mod_time = `stat /proc/sys/vm/hugetlb_shm_group | grep Modify | sed 's/^.*: \([0-9\-]*\) \([0-9:.]*\) -.*$/\1\2/g' | tr -d '\-:.'`

			set pr_setbuf = '"'${setbuf}'"'

			set test_id = pin${fn_pinshm}_huge${fn_hugetlb_shm}_${enabled}_${setbuf}
			set pr_id = '"'${test_id}'"'

			set header = "test_id=${pr_id} -"
			set header = "${header} gtm_pinshm=${pr_pinshm}"
			set header = "${header} gtm_hugetlb_shm=${pr_hugetlb_shm}"
			set header = "${header} enabled=${pr_enabled}"
			set header = "${header} setbuf=${pr_setbuf}"
			echo
			echo "# ----" $header "----"
			logger "$header"

			echo "# create database"
			strace \
				--string-limit=160 \
				--follow-forks \
				--output=strace_${test_id}.outx \
				-- \
				$gtm_tst/com/dbcreate.csh mumps_${test_id} \
				>& dbcreate_${test_id}.out
			setenv gtmgbldir mumps_${test_id}.gld

			# This test will fail on very large memory systems, so disable
			if ( ("set" == $setbuf) && (0 == $ydb_allow64GB_jnlpool) ) then
				echo "# Set a large global buffer to simulate SHMHUGETLB or SHMLOCK warning message to the system log"
				# Need A BG database in order to use global buffers
				$gtm_dist/mupip set -glo=1000000 -acc=BG -reg "*" \
					>& gb_mupip_${test_id}.out
				set mupip_err = \
					`cat gb_mupip_${test_id}.out | grep -P "(GTM-W|GTM-E)" | wc -l`

				if ( $mupip_err > 0 ) then
					echo "# failed setting global buffers with mupip:"
					cat gb_mupip_${test_id}.out
				else
					set syslog_before = `date +"%b %e %H:%M:%S"`
					(echo '' | $gtm_dist/dse >& gb_dse_${test_id}.out & echo $! >& dse_${test_id}.pid) >& subshell.outx
					set dsepid = `cat dse_${test_id}.pid`
					$gtm_tst/com/wait_for_proc_to_die.csh $dsepid
					$gtm_tst/com/getoper.csh "$syslog_before" "" syslog_${test_id}.txt

					if (1 == $pin) then
						set gbpin_fail = \
							`cat syslog_${test_id}.txt | grep $dsepid | grep "W-SHMLOCK" | wc -l`
						if ( $gbpin_fail > 0 ) then
							echo "DSE: pinning failed"
						else
							echo "DSE: pinning NOT failed"
							echo "See syslog_${test_id}.txt"
						endif
					endif

					if (1 == $huge) then
						set gbhuge_fail = \
							`cat syslog_${test_id}.txt | grep $dsepid | grep "W-SHMHUGETLB" | wc -l`
						if ( $gbhuge_fail > 0 ) then
							echo "DSE: using huge pages failed"
						else
							echo "DSE: using huge pages NOT failed"
							echo "See syslog_${test_id}.txt"
						endif
					endif

				endif
			endif

			echo "# check for pin behavior"
			set pin_found=`cat strace_${test_id}.outx | grep 'shmctl.*SHM_LOCK' | wc -l`
			set huge_found=`cat strace_${test_id}.outx | grep 'shmget.*SHM_HUGETLB' | wc -l`
			set huge_eperm_found=`cat strace_${test_id}.outx | grep 'shmget.*SHM_HUGETLB.*EPERM' | wc -l`
			set huge_enomem_found=`cat strace_${test_id}.outx | grep 'shmget.*SHM_HUGETLB.*ENOMEM' | wc -l`
			# Valid pin outputs are
			# 0. If pin is not valued, and not found, we pass
			# 1. If pin is requested and found
			# 	a. huge pages are not requested, then we pass
			# 	b. huge pages are requested and succeed without error, we fail (PIN is supposed to be suppressed)
			# 	c. else huge pages requested and failed, so PIN should show up: PASS
			# 2. If pin is requested and not found
			# 	a. huge pages are not requested, then we fail
			# 	b. huge pages are requested and succeed without error, we pass (PIN is suppressed in this case)
			# 	c. else huge pages are requested and failed, so PIN should show up: FAIL
			# 3. If pin is not requested, and found, we fail
			if ( ( ($pin == "") || ($pin == 0) ) && !($pin_found) ) then
				echo "\tpin: PASS"
			else if ($pin && $pin_found) then
				if ($huge == "" || $huge == 0) then
					echo "\tpin: PASS"
				else if ($huge && !( $huge_eperm_found || $huge_enomem_found )) then
					echo "\tpin: FAIL"
				else
					echo "\tpin: PASS"
				endif
			else if ($pin && !($pin_found)) then
				if ($huge == "" || $huge == 0) then
					echo "\tpin: FAIL"
				else if ($huge && !( $huge_eperm_found || $huge_enomem_found )) then
					echo "\tpin: PASS"
				else
					echo "\tpin: FAIL"
				endif
			else
				echo "\tpin: FAIL"
			endif

			# Conditionally issue expected output messages, depending on the configuration used for the current test case
			if ($huge == 1) then
				if ("$enabled" == "enable") then
					echo "# Check: when gtm_hugetlb_shm is set and HUGETLB enabled, expect shmget to return successfully"
					set pass_msg = "PASS: HUGETLB enabled, shm successfully allocated with SHM_HUGETLB"
				else
					echo "# Check: when gtm_hugetlb_shm is set and HUGETLB disabled, expect shmget fail and set EPERM"
					set pass_msg = "PASS: HUGETLB disabled, shmget returned EPERM"
				endif
			else
				echo "# Check: when gtm_hugetlb_shm is unset/disabled, expect that shmget is not called with SHM_HUGETLB at all"
				set pass_msg = "PASS: gtm_pinshm=$pr_pinshm, shmget NOT called with SHM_HUGETLB"
			endif
			# Get the current modification time /proc/sys/vm/hugetlb_shm_group to determine whether it was changed since this test case modified it above
			set hugetlb_shm_group_last_mod_time = `stat /proc/sys/vm/hugetlb_shm_group | grep Modify | sed 's/^.*: \([0-9\-]*\) \([0-9:.]*\) -.*$/\1\2/g' | tr -d '\-:.'`
			if ($hugetlb_shm_group_last_mod_time > $hugetlb_shm_group_init_mod_time) then
				# /proc/sys/vm/hugetlb_shm_group was modified by another process. So, pass this test case since
				# it is not possible to confirm the expected behavior for the value of that file set above.
				ps -ef --forest >&! ${test_id}-ps.out
				echo "FAIL: /proc/sys/vm/hugetlb_shm_group was unexpectedly modified. See ${test_id}-ps.out for more information."
			else
				if ($huge == 1) then
					if ($huge_found) then
						if (($huge_eperm_found) && ("$enabled" == "enable")) then
							echo "FAIL: HUGETLB enabled, but shmget returned EPERM"
						else if (!($huge_eperm_found) && ("$enabled" == "disable")) then
							echo "FAIL: HUGETLB disabled, but shm successfully allocated with SHM_HUGETLB"
						else
							echo $pass_msg
						endif
					else
						echo "FAIL: gtm_pinshm set, but shmget NOT called with SHM_HUGETLB"
					endif
				else
					if !($huge_found) then
						echo $pass_msg
					else
						echo "FAIL: gtm_pinshm=$pr_pinshm, but shmget called with SHM_HUGETLB"
					endif
				endif
			endif

			echo "# check for pin in MUPIP INTEG -ONLINE snapshot file (strace not should find SHM_LOCK)"
			strace \
				--string-limit=160 \
				--follow-forks \
				--output=strace_integ_${test_id}.outx \
				-- \
				$MUPIP integ -online -region DEFAULT \
				>& integ_${test_id}.out
			# https://unix.stackexchange.com/questions/56429/how-to-print-all-lines-after-a-match-up-to-the-end-of-the-file
			set pin_found=`sed -n '/openat.*snapshot/,$p' strace_integ_${test_id}.outx | grep 'shmctl.*SHM_LOCK' | wc -l`
			if ($pin_found) then
				echo "\tfound"
			else
				echo "\tnot found"
			endif

			echo '# validate db'
			$gtm_tst/com/dbcheck.csh >>& dbcreate_${test_id}.out

		end  # while setbuf
	end  # while enabled
end  # while parms

# restore original /proc/sys/vm/hugetlb_shm_group
sudo cp hugetlb_shm_group.bak /proc/sys/vm/hugetlb_shm_group
