#!/bin/sh
#################################################################
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# A master script for the different sh routines
# See the comment at the top of each function for details on what it is testing
#

testA() {
	echo '# Test 1'
	echo '# Checks that ydb_env_set sets all of the expected environment variables'
	echo '# This case is on a "fresh" environment with no preexisting variables set'
	echo '# That ydb_env_unset unsets all of the expected environment variables'
	echo '# That ydb_env_set creates the directory $HOME/.yottadb if it does not exist'

	# copy over the correct env to compare to
	sed -n '2,24p' $gtm_tst/$tst/inref/ydb429envCmp.txt > envCmpA.txt
	# if replic then we need to add this to the list
	if [ $gtm_repl_instance ]; then sed -i '21iydb_sav_[0-9]*_gtm_repl_instance' envCmpA.txt; fi
	# these are set by the test system and need to be unset to test the script
	unset gtm_log
	unset gtmgbldir
	unset gtmroutines
	unset gtm_dist
	unset ydb_xc_ydbposix
	unset ydb_dist

	. $ydbDistTmp/ydb_env_set
	echo '# source ydb_env_set'
	env | grep -f envCmpA.txt | sort | cut -d= -f1 > setEnvA.txt
	echo '# wc -l of envCmpA.txt, and setEnvA.txt should be the same'
	if [ "$(wc -l < envCmpA.txt)" = "$(wc -l < setEnvA.txt)" ]; then
		echo 'PASS'
	else
		echo 'FAIL'
	fi

	. $ydb_dist/ydb_env_unset
	echo '# source ydb_env_unset'
	# if replic then we need to add this to the list
	if [ $gtm_repl_instance ]; then sed -i '5d' envCmpA.txt; fi
	env | grep -f envCmpA.txt | sort | cut -d= -f1 > unsetEnvA.txt
	echo '# Check that no ydb*, gtm*, GTM* environment variables are set'
	if [ -s unsetEnvA.txt ] ; then
		echo 'FAIL'
		echo 'contents of unsetEnvA.txt'
		cat unsetEnvA.txt
	else
		echo 'PASS'
	fi

	echo '# Check that .yottadb was created at $HOME'
	ls $HOME/.yottadb > /dev/null
	if [ $? -eq 0 ]; then
		echo 'PASS'
	else
		echo "FAIL with status $?"
	fi
	mv .yottadb test1 # move database so it can be replaced

	exit 0
}

testB() {
	echo '# Test 2'
	echo '# Checks that ydb_env_set sets all of the expected environment variables'
	echo '# This case is on an environment with preexisting variables'
	echo '# That ydb_env_unset unsets all of the expected environment variables'
	echo '# That ydb_env_set creates the directory $HOME/.yottadb if it does not exist'

	sed -n '27,56p' $gtm_tst/$tst/inref/ydb429envCmp.txt > envCmpB.txt
	sed -n '59,63p' $gtm_tst/$tst/inref/ydb429envCmp.txt > envCmpC.txt
	# if replic then we need to add this to the list
	if [ $gtm_repl_instance ]; then
		sed -i '5igtm_repl_instance' envCmpB.txt
		sed -i '3igtm_repl_instance' envCmpC.txt
	fi
	unset gtmgbldir # unset this so that ydb_env_set uses the database in .yottadb not from the test system

	. $ydbDistTmp/ydb_env_set
	echo '# source ydb_env_set'
	env | grep -f envCmpB.txt | sort | cut -d= -f1 > setEnvB.txt
	echo '# wc -l of envCmpB.txt, and setEnvB.txt should be the same'
	if [ "$(wc -l < envCmpB.txt)" = "$(wc -l < setEnvB.txt)" ]; then
		echo 'PASS'
	else
		echo 'FAIL'
	fi

	. $ydb_dist/ydb_env_unset
	echo '# source ydb_env_unset'
	env | grep -f envCmpB.txt | sort | cut -d= -f1 > unsetEnvB.txt
	echo '# wc -l of envCmpC.txt, and unsetEnvB.txt should be the same'
	if [ "$(wc -l < envCmpC.txt)" = "$(wc -l < unsetEnvB.txt)" ]; then
		echo 'PASS'
	else
		echo 'FAIL'
	fi

	echo '# Check that .yottadb was created at $HOME'
	ls $HOME/.yottadb > /dev/null
	if [ $? -eq 0 ]; then
		echo 'PASS'
	else
		echo "FAIL with status $?"
	fi
	mv .yottadb test2 # move database so it can be replaced

	exit 0
}

testC() {
	echo '# Test 3'
	echo '# Test that ydb_env_set sets up a working database'

	unset gtmgbldir # unset this so that ydb_env_set uses the database in .yottadb not from the test system
	. $ydb_dist/ydb_env_set
	cp $gtm_tst/basic/inref/globals.m .

	echo "# Running subtest basic/globals to test that database is properly setup"
	$ydb_dist/yottadb -run globals
	echo "# Creating a second region and confirming that ydb_env_set creates it"
	cat >> gdeCmds.txt << xx
add -name a -region=a
add -region a -dynamic=a
add -segment a -file_name=$ydb_dir/$ydb_rel/g/a.dat
xx
	$ydb_dist/yottadb -run GDE < gdeCmds.txt > gdeOut3.log 2>&1
	. $ydbDistTmp/ydb_env_set
	ls $ydb_dir/$ydb_rel/g/a.dat > /dev/null
	if [ $? -eq 0 ]; then
		echo "PASS"
	else
		echo "FAIL: could not find the file $ydb_dir/$ydb_rel/g/a.dat"
	fi

	mv .yottadb test3 # move database so it can be replaced

	exit 0
}

testD() {
	echo '# Test 4'
	echo '# Test that setting ydb_chset to UtF-8 prior to ydb_env_set will use a UTF-8 database'
	echo '# Setting ydb_chset to UtF-8 to verify ydb_env_set properly sets up UTF-8 mode'

	# for this test the locale needs to be UTF8
	export LANG=C
	unset LC_ALL
	# borrowed from com/set_locale this gets the utf8 locake on the system
	export LC_CTYPE=$( locale -a | grep $binaryopt -iE 'en_us\.utf.?8$' | head -n 1 )
	export LV_COLLATE=C
	export ydb_chset="UtF-8"
	unset gtmgbldir
	# In case $gtm_dist points to a path that is soft linked to something else, ydb_env_set will
	# not work right when gtmroutines contains paths that contain the soft link $gtm_dist version
	# (see https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1125#note_845334601 for more details).
	# Therefore, replace $gtm_dist with "realpath $gtm_dist" in gtmroutines env var before calling ydb_env_set.
	# Note that using "export gtmroutines=..." does not work in sh (issues a "export: ... bad variable name" error)
	# whereas it works in bash. So we work around that by setting gtmroutines first and exporting in a separate line.
	gtmroutines=$(echo "$gtmroutines" | sed 's,'$gtm_dist','$(realpath $gtm_dist)',g')
	export gtmroutines
	. $ydb_dist/ydb_env_set
	echo '# Checking yottadb $zchset value'
	zchset=$($ydb_dist/yottadb -run %XCMD 'write $zchset,!')
	echo $zchset
	if [ "$zchset" = "UTF-8" ] ; then
		echo "PASS"
	else
		echo "FAIL"
	fi
	mv .yottadb test4 # move database so it can be replaced

	exit 0
}

testE() {
	echo '# Test 5'
	echo '# Test that ydb_env_set creates the database files at ydb_dir when it is set'
	echo '# Setting ydb_dir to nonexistent directory tmp and testing environment works'
	export ydb_dir=$(pwd)/tmp
	unset gtm_chset # unset this so that globals.o always ends up in the same directory
	unset gtmgbldir # unset this so that ydb_env_set ends up in the tmp dir
	export gtmroutines="."	# gtmroutines could contain "utf8/" in it if the test started in UTF-8 mode.
				# In that case, "ydb_env_set" would set ydb_chset to UTF-8 which would cause
				# non-deterministic test output so set this env var to a value that does not contain "utf8/".
	. $ydb_dist/ydb_env_set

	ls tmp > /dev/null
	if [ ! $? -eq 0 ] ; then
		echo "FAIL ydb_env_set did not create directory tmp"
		return 1
	fi

	echo ""
	echo "# [YDB#661] Test 5a : Test that ydb_chset is set to M by ydb_env_set by default"
	echo '$ydb_chset = '$ydb_chset
	echo ""
	echo "# Copying subtest basic/globals to test new environment"
	cp $gtm_tst/basic/inref/globals.m .
	rm -f globals.o	# remove any pre-existing object file so we test where the .o file gets created below

	$ydb_dist/yottadb -run globals
	echo "# Checking for the globals object file"
	ls globals.o
	if [ $? -eq 0 ] ; then
		echo "PASS"
	else
		echo "FAIL did not find globals.o"
	fi
	mv tmp test5 # move database so it can be replaced


	exit 0
}

testF() {
	echo '# Test [6-11]'
	echo '# Simulating crashes and recoveries of database with properties'
	echo '#       Single Region before journaling'
	echo '#       2 Region before journaling'
	echo '#       Single Region nobefore journaling'
	echo '#       2 Region nobefore journaling'
	echo '#       Single Region no journaling'
	echo '#       2 Region no journaling'
	testNum=6
	old_gtmroutines=$gtmroutines
	old_gtm_chset=$gtm_chset
	for jnl_type in "enable,on,before" "enable,on,nobefore" "disable"; do
		for num_regions in 1 2; do
			mkdir test$testNum
			ls -1 > filesA.list # make a list of all files that exist before the test starts
			echo "# Test $testNum"
			echo "# Simulating a database crash and recovery with ydb_env_set with $num_regions regions with $jnl_type journaling"
			if [ $test_repl = "REPLIC" -a $jnl_type = "disable" ]; then
				echo "Replication test cannot run with disabled journaling. Skipping test."
				testNum=`expr $testNum + 1 `
				echo; echo; echo
			       	continue
		       	fi
			# database setup
			export gtm_dist=$ydbDistTmp
			export acc_meth="BG"
			export gtm_test_jnl="SETJNL"
			export tst_jnl_str="-journal=$jnl_type"
			epoInv=$( shuf -i 1-15 -n 1 )
			# if there is no journaling then dont set epoch_interval
			if [ $jnl_type != "disable" ]; then tst_jnl_str="$tst_jnl_str,epoch_interval=$epoInv"; fi
			$gtm_tst/com/dbcreate.csh yottadb $num_regions
			if [ $? != "0" ]; then dbRet=$? echo "dbcreate failed with status: $dbRet" exit 1; fi
			$gtm_tst/com/ipcs -a > test$testNum.ipcs
			export ydb_dir=$(pwd)
			export ydb_gbldir=$gtmgbldir
			. $ydbDistTmp/ydb_env_set

			echo "# Crashing database"
			# we subshell and fork off the ydb process within the subshell to supress the output
			# then fork off the subshell so that is doesn't hang the main thread
			$( $ydb_dist/yottadb -run %XCMD 'for i=1:1 set (^a(i),^b(i))=$j(i,100) hang 0.01' & ) > crash.log 2>&1 & # start a ydb process and then leave it open
			# if the test is replic then we need to find 2 pids
			# one for the replic source and the other to do sets
			if [ $test_repl = "REPLIC" ]; then numPid=2; else numPid=1; fi
			# Wait for the correct number of ydb processes to start
			while true; do
				# fuser prints out the file name to stderr for some reason. It's junk so filter out
				# on some versions of sh you need to redirect it in the subshell
				# and in others you need to redirect after, so do both to be safe
				fuser yottadb.dat 2> /dev/null > fuser$testNum.out
				ydbPid=$(cut -d ' ' -f 1- fuser$testNum.out)
				curPid=$(echo $ydbPid | $tst_awk '{print NF}')
				if [ "$curPid" = "$numPid" ]; then
					break
				fi
				sleep 0.01
			done
			tcsh $gtm_tst/com/gtm_crash.csh "PID_" $ydbPid # crash the pid
			echo '# Confirming it is crashed'
			$ydb_dist/yottadb -run %XCMD 'write $data(^a)," ",$data(^b),!'

			echo '# Attempting recovery'
			. $ydbDistTmp/ydb_env_unset
			# if replic before recovery stop the replicating server
			if [ $test_repl = "REPLIC" ]; then $sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh \".\" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"; fi
			. $ydbDistTmp/ydb_env_set > ydb_env_set.txt
			sed -e '/^%YDBENV-/q' ydb_env_set.txt # the error always contains %YDBENV-. Rest is output of ZSHOW "*"
			# this one only needs to run when recovery is possible
			if [ $jnl_type = "enable,on,before" ]; then
				echo -n 'Checking the recovered database with $data(^a), $data(^b) Expected: 0|10 0|10; Actual: '
				$ydb_dist/yottadb -run %XCMD 'write $data(^a)," ",$data(^b),!'
			else
				# a rundown is needed when recovery is not possible
				$ydbDistTmp/mupip rundown -region "*" -override > rundown.log 2>&1
			fi

			# cleanup
			$ydbDistTmp/mupip rundown -relinkctl >> rundown.log 2>&1
			. $ydbDistTmp/ydb_env_unset
			export gtmroutines="$old_gtmroutines" # this is needed because when ydb_env_set fails gtmroutines is not reset properly
			export gtm_chset="$old_gtm_chset"
			if [ $jnl_type = "enable,on,before" ]; then
				$gtm_tst/com/dbcheck.csh -noshut > dbcheck$testNum.log 2>&1;
				if [ $? != "0" ]; then dbRet=$? echo "dbcheck failed with status: $dbRet" exit 2; fi
			else
				echo '# Cannot do a dbcheck as non-before journaling types will have integ errors'
			fi
			ls -1 > filesB.list # list of files after the test is over
			# move only the new files to the test$testNum directory
			diff --changed-group-format='%<' --unchanged-group-format='' filesB.list filesA.list | xargs mv -t test$testNum
			testNum=`expr $testNum + 1 `
			echo; echo; echo
		done
	done
	exit 0
}

testG() {
	echo '# Test [12-17]'
	echo '# Testing that ydb_env_set will not attempt robustify after a clean shutdown of database with properties'
	echo '#       Single Region before journaling'
	echo '#       2 Region before journaling'
	echo '#       Single Region nobefore journaling'
	echo '#       2 Region nobefore journaling'
	echo '#       Single Region no journaling'
	echo '#       2 Region no journaling'
	old_gtmroutines=$gtmroutines
	old_gtm_chset=$gtm_chset
	testNum=12 # keep track of what number directory to move things to
	for jnl_type in "enable,on,before" "enable,on,nobefore" "disable"; do
		for num_regions in 1 2; do
			mkdir test$testNum
			ls -1 > filesA.list # same copy system as above
			echo "# Test $testNum"
			echo "# Opening and closing cleanly database with $num_regions regions with $jnl_type journaling"
			if [ $test_repl = "REPLIC" -a $jnl_type = "disable" ]; then
				echo "Replication test cannot run with disabled journaling. Skipping test."
				testNum=`expr $testNum + 1 `
				echo; echo; echo
			       	continue
		       	fi
			# database setup
			export gtm_dist=$ydbDistTmp
			export acc_meth="BG"
			export gtm_test_jnl="SETJNL"
			export tst_jnl_str="-journal=$jnl_type"
			$gtm_tst/com/dbcreate.csh yottadb $num_regions
			if [ $? != "0" ]; then dbRet=$? echo "dbcreate failed with status: $dbRet" exit 1; fi
			export ydb_dir=$(pwd)
			export ydb_gbldir=$gtmgbldir
			. $ydbDistTmp/ydb_env_set

			echo "# Setting ^a and ^b and exiting"
			$ydb_dist/yottadb -run %XCMD 'set ^a="An a" set ^b="A b"'


			echo '# Toggling ydb_env_unset/ydb_env_set'
			. $ydbDistTmp/ydb_env_unset
			. $ydbDistTmp/ydb_env_set
			echo -n 'Checking $data(^a), $data(^b) Expected: 1 1; Actual: '
			$ydb_dist/yottadb -run %XCMD 'write $data(^a)," ",$data(^b),!'

			# cleanup
			. $ydbDistTmp/ydb_env_unset
			# The below reset of gtmroutines and gtm_chset (after they would have gotten unset by ydb_env_unset)
			# is needed for dbcreate call of following iteration
			export gtmroutines="$old_gtmroutines"
			export gtm_chset="$old_gtm_chset"
			$gtm_tst/com/dbcheck.csh > dbcheck$testNum.log 2>&1
			if [ $? != "0" ]; then dbRet=$? echo "dbcheck failed with status: $dbRet" exit 2; fi
			ls -1 > filesB.list
			diff --changed-group-format='%<' --unchanged-group-format='' filesB.list filesA.list | xargs mv -t test$testNum
			testNum=`expr $testNum + 1 `
			echo; echo; echo
		done
	done

	exit 0
}

testH() {
	echo "Test [18-23]"
	echo "Test that ydb_env_set does not call robustify when there is an open database with properties"
	echo '#       Single Region before journaling'
	echo '#       2 Region before journaling'
	echo '#       Single Region nobefore journaling'
	echo '#       2 Region nobefore journaling'
	echo '#       Single Region no journaling'
	echo '#       2 Region no journaling'
	old_gtmroutines=$gtmroutines
	old_gtm_chset=$gtm_chset
	testNum=18 # keep track of what number directory to move things to
	for jnl_type in "enable,on,before" "enable,on,nobefore" "disable"; do
		for num_regions in 1 2; do
			mkdir test$testNum
			ls -1 > filesA.list # same copy system from testF()
			echo "# Test $testNum"
			echo "# Leaving a database open and calling ydb_env_set with $num_regions regions with $jnl_type journaling"
			if [ $test_repl = "REPLIC" -a $jnl_type = "disable" ]; then
				echo "Replication test cannot run with disabled journaling. Skipping test."
				testNum=`expr $testNum + 1 `
				echo; echo; echo
			       	continue
		       	fi
			# database setup
			export gtm_dist=$ydbDistTmp
			export acc_meth="BG"
			export gtm_test_jnl="SETJNL"
			export tst_jnl_str="-journal=$jnl_type"
			$gtm_tst/com/dbcreate.csh yottadb $num_regions
			if [ $? != "0" ]; then dbRet=$? echo "dbcreate failed with status: $dbRet" exit 1; fi
			export ydb_dir=$(pwd)
			export ydb_gbldir=$gtmgbldir

			echo "# Leaving a yottadb process open and calling ydb_env_set"
			$ydbDistTmp/yottadb -run %XCMD 'set ^done(1)=1 hang 9999' > /dev/null 2>&1 &
			ydbPID=$!
			$ydbDistTmp/yottadb -run %XCMD 'for  quit:$get(^done(1))=1  hang 0.001'
			. $ydbDistTmp/ydb_env_set

			echo "# Setting ^a and ^b and exiting"
			$ydb_dist/yottadb -run %XCMD 'set ^a="An a" set ^b="A b"'


			echo '# Toggling ydb_env_unset/ydb_env_set'
			. $ydbDistTmp/ydb_env_unset
			. $ydbDistTmp/ydb_env_set
			echo -n 'Checking $data(^a), $data(^b) Expected: 1 1; Actual: '
			$ydb_dist/yottadb -run %XCMD 'write $data(^a)," ",$data(^b),!'

			# cleanup
			$ydb_dist/mupip stop $ydbPID > stop.log 2>&1 # just stop the process not crash
			. $ydbDistTmp/ydb_env_unset
			# The below reset of gtmroutines and gtm_chset (after they would have gotten unset by ydb_env_unset)
			# is needed for dbcreate call of following iteration
			export gtmroutines="$old_gtmroutines"
			export gtm_chset="$old_gtm_chset"
			$gtm_tst/com/dbcheck.csh > dbcheck$testNum.log 2>&1
			if [ $? != "0" ]; then dbRet=$? echo "dbcheck failed with status: $dbRet" exit 2; fi
			ls -1 > filesB.list
			diff --changed-group-format='%<' --unchanged-group-format='' filesB.list filesA.list | xargs mv -t test$testNum
			testNum=`expr $testNum + 1 `
			echo; echo; echo
		done
	done

	exit 0
}

testI() {
	# Beginning of test setup code
	testNum=24 # keep track of what number directory to move things to
	testCaseNum=test$testNum
	mkdir $testCaseNum
	ls -1 > filesA.list # make a list of all files that exist before the test starts
	old_gtmroutines=$gtmroutines
	old_gtm_chset=$gtm_chset

	# Actual test code
	echo "# ----------------------------------------------------------------------------------"
	echo "# Test $testNum : Test of YDB#661 : ydb_env_set creates 3-region database by default"
	echo "# This implements the test plan at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/950#note_544517343."
	echo "# ----------------------------------------------------------------------------------"
	echo "# Test $testNum : Subtest A : Test that ydb_env_set creates YDBOCTO and YDBAIM regions by default"
	export ydb_dir=$(pwd)
	unset ydb_gbldir gtmgbldir
	. $ydbDistTmp/ydb_env_set
	cp $gtm_tst/$tst/inref/ydb429.m $ydb_dir/r	# needed for "yottadb -run ydb429" after ydb_env_set
	cp $gtm_tst/$tst/inref/ydb429.m .	# needed for "yottadb -run ydb429" after ydb_env_unset
	echo '# Verify that db & jnls exist under $ydb_dir/$ydb_rel/g for DEFAULT region'
	echo '# Verify that db & jnls exist under $ydb_dir/$ydb_rel/g for YDBOCTO region'
	echo '# Verify that db & jnls exist under $ydb_dir/$ydb_rel/g for YDBAIM region'
	cd $ydb_dir/$ydb_rel; ls -1 g/*.gld g/*.dat g/*.mjl*; cd ..
	echo '# Set some globals in the DEFAULT, YDBOCTO and YDBAIM regions'
	$ydb_dist/yottadb -run setgblsallregions^ydb429
	echo '# source ydb_env_unset'
	. $ydb_dist/ydb_env_unset
	echo '# source ydb_env_set'
	. $ydbDistTmp/ydb_env_set
	echo '# Confirm globals are still there'
	$ydb_dist/yottadb -run %XCMD 'zwrite ^default,^%ydboctotmp,^%ydbAIMtmp'
	echo '# Verify gld settings of 3-region database created by ydb_env_set. GDE SHOW -COMMANDS output follows'
	$ydb_dist/yottadb -run GDE show -commands | sed 's,$ydb_dir/$ydb_rel/g/,,g' > $testCaseNum.gde
	cat $testCaseNum.gde

	# Run ydb_env_unset to restore test system env vars for dbcreate
	. $ydbDistTmp/ydb_env_unset

	# End of test cleanup code
	ls -1 > filesB.list # list of files after the test is over
	# move only the new files to the $testCaseNum directory
	diff --changed-group-format='%<' --unchanged-group-format='' filesB.list filesA.list | xargs mv -t $testCaseNum
	mv $testCaseNum/r .

	echo "# Test $testNum : Subtest B : Test of Crash handling of 3-region default database"
	echo "# Recreate default 3-region database of ydb_env_set using dbcreate.csh (as it is easy for crash/dbcheck etc.)"
	cp $testCaseNum/$testCaseNum.gde test${testNum}B.gde
	testCaseNum=test${testNum}B
	export test_specific_gde=$(pwd)/$testCaseNum.gde
	export gtmroutines="$old_gtmroutines" # this is needed because when ydb_env_set fails gtmroutines is not reset properly
	export gtm_chset="$old_gtm_chset"
	export gtmgbldir="$testCaseNum.gld"

	unset gtm_db_counter_sem_incr	# avoid semaphore counter overflow
	export gtm_test_jnl="SETJNL"
	export tst_jnl_str='-journal="enable,on,before"'
	# Need to store the value in settings.csh for the above setting to really take effect as that is what
	# "com/change_current_tn.csh" looks at.
	echo "setenv gtm_test_dbcreate_initial_tn $gtm_test_dbcreate_initial_tn" >> settings.csh
	# Enable before image journaling only on DEFAULT, YDBOCTO and YDBAIM regions but not on YDBJNLF region
	# since that is MM access method and won't work if before-image journaling is chosen.
	echo "yottadb" > jnl_on_specific_dblist.txt
	echo "%ydbocto" >> jnl_on_specific_dblist.txt
	echo "%ydbaim" >> jnl_on_specific_dblist.txt
	if [ 1 = "$test_replic" ]; then
		cp jnl_on_specific_dblist.txt $SEC_DIR
	fi

	# Create database files. If replication test, create replication instance file too and on remote side.
	$gtm_tst/com/dbcreate.csh $testCaseNum
	echo "# Start a background yottadb process that updates globals in all 3 regions DEFAULT, YDBOCTO and YDBAIM"
	$ydb_dist/yottadb -run bkgrnd^ydb429
	echo "# Kill the yottadb process and simulate a crash by deleting shared memory segments etc. for all three regions"
	ydbPid=$($ydb_dist/yottadb -run %XCMD 'write ^child')
	tcsh $gtm_tst/com/gtm_crash.csh "PID_" $ydbPid # crash the pid
	if [ 1 = "$test_replic" ]; then
		tcsh $gtm_tst/com/primary_crash.csh
		$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/receiver_crash.csh'
	fi
	echo '# Confirming it is crashed'
	$ydb_dist/yottadb -run %XCMD 'write $data(^default)," ",$data(^default),!'
	echo '# Complete the crash simulation by sourcing ydb_env_unset'
	. $ydbDistTmp/ydb_env_unset
	# Record ps output just in case it is useful for debugging a test failure.
	# Use .outx to avoid test failures due to "-E-" strings in the ps output from being caught by test framework at the end.
	ps -ef --forest > psfu.outx
	echo '# Source ydb_env_set to simulate restart of system'
	. $ydbDistTmp/ydb_env_set
	echo '# Confirm database file exists for YDBAIM in the existing $ydb_dir environment since it is journaled AND not an AUTODB region.'
	echo '# Confirm database file exists for YDBJNLF in the existing $ydb_dir environment if this test was run without -replic.'
	echo '# - In that case, this test did not open the YDBJNLF region and so that region did not have any REQRUNDOWN'
	echo '#   error (since the YDBJNLF region is not journaled) that needed to be fixed.'
	echo '# Confirm database file does NOT exist for YDBJNLF in the existing $ydb_dir environment if this test was run with -replic.'
	echo '# - In that case, the source server would have opened the YDBJNLF region (it opens all regions) and so that region would'
	echo '#   have a REQRECOVER error after the crash that needed to be fixed. And ydb_env_set would DELETE that database file since'
	echo '#   it has the AUTODB flag set and is not journaled.'
	# Note: The test framework sets "LC_COLLATE" to C (see "com/set_locale.csh") but it is possible that "ydb_env_set" sets
	# "LC_ALL" to a UTF-8 locale (if it finds that LC_CTYPE or LC_ALL is not set to a UTF-8 locale at shell startup which
	# can vary depending on how the current server was set up). In that case, the "LC_COLLATE" setting would get overridden
	# to the UTF-8 locale which would cause a different sort order of the "*.gld *.dat" files than what is expected in the
	# reference file so undo the LC_ALL env var override and set LC_COLLATE to "C" (just in case) for the "ls" command below.
	env LC_ALL="" LC_COLLATE="C" ls -1 *.gld *.dat
	echo '# Verify that globals set in DEFAULT, YDBOCTO and YDBAIM exist'
	$ydb_dist/yottadb -run verifyaftercrash^ydb429
	. $ydb_dist/ydb_env_unset

	# End of test cleanup code
	ls -1 > filesB.list # list of files after the test is over
	# move only the new files to the $testCaseNum directory
	mkdir $testCaseNum
	diff --changed-group-format='%<' --unchanged-group-format='' filesB.list filesA.list | xargs mv -t $testCaseNum
	if [ 1 = "$test_replic" ]; then
		# In case of a replic test, move away files from test24B so next stage (if any in the future) is not affected by it.
		mv $SEC_DIR ${SEC_DIR}_$testCaseNum
		mkdir $SEC_DIR
		mv ${SEC_DIR}_$testCaseNum/start_time_syslog.txt $SEC_DIR	# Move this file back in case of test failures
										# as test framework will look for it.
	fi
}

testJ() {
	# Beginning of test setup code
	testNum=25 # keep track of what number directory to move things to
	testCaseNum=test$testNum
	mkdir $testCaseNum
	echo "# Test $testNum"
	echo '# Test that ydb_env_set issues an error if ydb_gbldir points to a non-existent gld file'
	echo '# See https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1243#note_1169532091 for more details'
	export ydb_routines="$ydb_dist"
	export ydb_gbldir=nonexistent.gld
	. $ydb_dist/ydb_env_set
	mv .yottadb $testCaseNum	# move database so it can be replaced
	exit 0
}

testK() {
	# Beginning of test setup code
	testNum=26 # keep track of what number directory to move things to
	testCaseNum=test$testNum
	mkdir $testCaseNum
	echo "# Test $testNum"
	echo '# Test that ydb_env_set will set the journal of all regions to be in the same folder'
	echo '# as the journal file for a preexisting DEFAULT region'

	# database setup
	echo '# Creating Single Region Database with before image journaling on'
	export acc_meth="BG"
	export gtm_test_jnl="SETJNL"
	export tst_jnl_str="-journal=enable,on,before"
	$gtm_tst/com/dbcreate.csh yottadb 1
	echo '# Journal file'
	$ydb_dist/dse all -dump 2>&1 | grep 'Journal File: ' | awk -F': ' '{print $2}'
	. $ydb_dist/ydb_env_set
	echo '# Journal files'
	$ydb_dist/dse all -dump 2>&1 | grep 'Journal File: ' | awk -F': ' '{print $2}'
	. $ydb_dist/ydb_env_unset
	$gtm_tst/com/dbcheck.csh
	mv .yottadb $testCaseNum	# move database so it can be replaced
	exit 0
}
## MAIN

# Run what every the first argument is as a function
# The only arguments should then be A, B, C, D, E, F, G
$1
