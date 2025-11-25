#!/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
cd /usr/library/gtm_test/T999

set instream_invokelist_regular = ""
set instream_invokelist_replic = ""
set instream_invokelist_reorg = ""
set instream_invokelist_reorg_replic = ""

# Results collected in result.txt, initially empty
touch result.txt

# List of heavyweight tests we won't run on the pipeline
# Leading and trailing spaces are necessary and relied upon by the =~ operator
set heavyweights = " multisrv_crash unicode_socket rollback_B socket jnl_crash ideminter_rolrec rollback_A recov suppl_inst_B io resil_4 tp gtcm_gnp triggers resil v44003 burst_load manually_start "

# Our AARCH64 runner is slow, so add sudo to the list of heavyweight tests
if (`uname -m` == "aarch64") set heavyweights = "${heavyweights}sudo "

# Print file list so we can find out which tests are running in the pipeline
echo $filelist | sed 's/ /\n/g;'

# For each file, check if it is instream.csh or is inside inref
# If it is, add it so that we invoke the test system with "-t xxx -t yyy -t zzz"
# Reorg tests are added to a separate list, as they are run with -reorg
foreach file ($filelist)
	set filename = $file:t
	set directory_name = `echo $file | cut -d / -f 2`
	# If instream.csh changes, then test the entire test
	if ("instream.csh" == "$filename") then
		set test = `dirname $file`
	# If a file inside inref changes, then test the entire test, as we can't tell which test it belongs to
	else if ( "inref" == "$directory_name" ) then
		set test = `echo $file | cut -d / -f 1`
	endif
	if ( $?test ) then
		# Space delimiters ensure we don't accidentally exclude a test due to partial matching; it needs to be a whole word
		if ( "$heavyweights" =~ "* $test *" ) then
			echo "Skipping test [$test] on pipeline as it is a heavyweight test"
			continue
		endif

		# Is this a regular test?
		grep -q ${test}'.* E$' com/SUITE
		@ is_regular_test = ! $status
		# Is this a reorg test?
		grep -q ${test}'.* E REORG$' com/SUITE
		@ is_reorg_test = ! $status
		# Is this a replic test?
		grep -q ${test}'.* E REPLIC$' com/SUITE
		@ is_replic_test = ! $status
		# Is this a reorg-replic test?
		grep -q ${test}'.* E REPLIC REORG$' com/SUITE
		@ is_reorg_replic_test = ! $status

		# Construct test lists. If test is already there, don't add it again.
		if ($is_reorg_test) then
			if ( "$instream_invokelist_reorg" !~ " *-t $test* " ) then
				set instream_invokelist_reorg = "$instream_invokelist_reorg -t $test "
			endif
		endif
		if ($is_replic_test) then
			if ( "$instream_invokelist_replic" !~ " *-t $test* " ) then
				set instream_invokelist_replic = "$instream_invokelist_replic -t $test "
			endif
		endif
		if ($is_regular_test) then
			if ( "$instream_invokelist_regular" !~ " *-t $test* " ) then
				set instream_invokelist_regular = "$instream_invokelist_regular -t $test "
			endif
		endif
		if ($is_reorg_replic_test) then
			if ( "$instream_invokelist_reorg_replic " !~ " *-t $test* " ) then
				set instream_invokelist_reorg_replic = "$instream_invokelist_reorg_replic -t $test "
			endif
		endif
	endif
end

echo -n "# Regular list: "
echo $instream_invokelist_regular
echo -n "# Replic list: "
echo $instream_invokelist_replic
echo -n "# Reorg test list: "
echo $instream_invokelist_reorg
echo -n "# Reorg replic test list: "
echo $instream_invokelist_reorg_replic
echo " "

echo "### Run tests"

# The test system has the capability of running multiple instreams at once, so let's do that.

if ( "$instream_invokelist_regular" != "" ) then
	echo "Run: [su -l gtmtest $pass_env -c \"/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_regular\"]"
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_regular"
	if ($status) then
		echo "${instream_invokelist_regular}: FAIL (non-replic)" >> result.txt
	else
		echo "${instream_invokelist_regular}: PASS (non-replic)" >> result.txt
	endif
	echo " "
endif

if ( "$instream_invokelist_replic" != "" ) then
	echo "Run: [su -l gtmtest $pass_env -c \"/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_replic -replic\"]"
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_replic -replic"
	if ($status) then
		echo "${instream_invokelist_replic}: FAIL (replic)" >> result.txt
	else
		echo "${instream_invokelist_replic}: PASS (replic)" >> result.txt
	endif
	echo " "
endif

if ( "$instream_invokelist_reorg" != "" ) then
	echo "Run: [su -l gtmtest $pass_env -c \"/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_reorg -reorg\"]"
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_reorg -reorg"
	if ($status) then
		echo "${instream_invokelist_reorg}: FAIL (reorg)" >> result.txt
	else
		echo "${instream_invokelist_reorg}: PASS (reorg)" >> result.txt
	endif
	echo " "
endif

if ( "$instream_invokelist_reorg_replic" != "" ) then
	echo "Run: [su -l gtmtest $pass_env -c \"/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_reorg_replic -reorg -replic\"]"
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_reorg_replic -reorg -replic"
	if ($status) then
		echo "${instream_invokelist_reorg_replic}: FAIL (reorg replic)" >> result.txt
	else
		echo "${instream_invokelist_reorg_replic}: PASS (reorg replic)" >> result.txt
	endif
	echo " "
endif

# Next, check if the file is "test/u_inref/xxx.csh" or "test/outref/xxx.txt".
# If so, run EACH with -t test/xxx, but only if we didn't previously run the whole "test" before just above.
# We cross check that xxx is found in the subtest_list in test/instream.csh
# Note that we run each sequentially (rather than together as above) because the test system is incapable of combining different -t xxx/yyy -t aaa/bbb
set subtest_non_replic_invokelist = ""
set subtest_replic_invokelist = ""
foreach file ($filelist)
	set directory_name = `echo $file | cut -d / -f 2`
	if ( ( "u_inref" == "$directory_name" ) || ( "outref" == "$directory_name" ) ) then
		set test = `echo $file | cut -d / -f 1`
		if ( "$heavyweights" =~ "* $test *" ) then
			echo "Skipping test [$test] on pipeline as it is a heavyweight test"
			continue
		endif

		# Is this a regular test?
		grep -q ${test}'.* E$' com/SUITE
		@ is_regular_test = ! $status

		# Is this a reorg test?
		grep -q ${test}'.* E REORG$' com/SUITE
		@ is_reorg_test = ! $status

		# Is this a replic test?
		grep -q ${test}'.* E REPLIC$' com/SUITE
		@ is_replic_test = ! $status

		# Is this a reorg-replic test?
		grep -q ${test}'.* E REPLIC REORG$' com/SUITE
		@ is_reorg_replic_test = ! $status
		if ($is_reorg_replic_test) then
			set is_reorg_test = 1
			set is_replic_test = 1
		endif

		set reorg_flag = ""
		set replic_flag = ""
		if ($is_reorg_test) set reorg_flag = "-reorg"
		if ($is_replic_test) set replic_flag = "-replic"

		# We define them to prevent undefs
		setenv subtest_list
		setenv subtest_list_non_replic
		setenv subtest_list_replic
		setenv subtest_list_common
		grep "setenv subtest_list" ${test}/instream.csh > instream_setenvs
		source instream_setenvs
		rm instream_setenvs

		set subtest = $file:r:t

		# Regular tests
		if ( " $subtest_list_non_replic " =~ " *$subtest* " || " $subtest_list_common " =~ " *$subtest* " || ( " $subtest_list " =~ " *$subtest* " && $is_regular_test ) ) then
			# If test was invoked as a suite from instream, don't add it to the invoke list
			if ( "$instream_invokelist_regular" !~ " *-t $test* " && "$instream_invokelist_reorg" !~ " *-t $test* " && "$instream_invokelist_replic" !~ " *-t $test* " && "$instream_invokelist_reorg_replic" !~ " *-t $test* " ) then
				echo -n "# Running $test/$subtest ${reorg_flag}: "
			        echo "[su -l gtmtest $pass_env -c \"/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -st $subtest $reorg_flag\"]"
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -st $subtest $reorg_flag"
				if ($status) then
					echo "$test/${subtest}: FAIL (non-replic)" >> result.txt
				else
					echo "$test/${subtest}: PASS (non-replic)" >> result.txt
				endif
				echo " "
			endif
		# Replic tests
		else if ( " $subtest_list_replic " =~ " *$subtest* " || " $subtest_list_common " =~ " *$subtest* " || ( " $subtest_list " =~ " *$subtest* " && $is_replic_test ) ) then
			# If test was invoked as a suite from instream, don't add it to the invoke list
			if ( "$instream_invokelist_regular" !~ " *-t $test* " && "$instream_invokelist_reorg" !~ " *-t $test* " && "$instream_invokelist_replic" !~ " *-t $test* " && "$instream_invokelist_reorg_replic" !~ " *-t $test* " ) then
				echo -n "# Running $test/$subtest -replic ${reorg_flag}: "
			        echo "[su -l gtmtest $pass_env -c \"/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -st $subtest -replic $reorg_flag\"]"
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -st $subtest -replic $reorg_flag"
				if ($status) then
					echo "$test/${subtest}: FAIL (replic)" >> result.txt
				else
					echo "$test/${subtest}: PASS (replic)" >> result.txt
				endif
				echo " "
			endif
		# Unclassifiable tests
		else
			# Subtest in the u_inref or outref is not a known subtest. Run whole test.
			# If test was invoked as a suite from instream, don't add it to the invoke list
			if ( "$instream_invokelist_regular" !~ " *-t $test* " && "$instream_invokelist_reorg" !~ " *-t $test* " && "$instream_invokelist_replic" !~ " *-t $test* " && "$instream_invokelist_reorg_replic" !~ " *-t $test* " ) then
				echo -n "# Running $test $reorg_flag ${replic_flag}: "
			        echo "[su -l gtmtest $pass_env -c \"/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test $reorg_flag $replic_flag\"]"
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test $reorg_flag $replic_flag"
				if ($status) then
					echo "${test}: FAIL (flags: $reorg_flag $replic_flag)" >> result.txt
				else
					echo "${test}: PASS (flags: $reorg_flag $replic_flag)" >> result.txt
				endif
				echo " "
			endif
		endif
	endif
end

# Fail if any of the tests failed
echo "# Final report:"
cat result.txt

# Coverage for YDB pipeline
/usr/library/gtm_test/T999/docker/coverage.csh

grep -q FAIL result.txt
# Grep reverses the exit: 0 means found, 1 means not found, not found is good!
exit ( ! $status )
