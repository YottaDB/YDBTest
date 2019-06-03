#!/bin/sh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
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

	sed -n '2,24p' $gtm_tst/$tst/inref/ydb429envCmp.txt > envCmpA.txt
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
	cp $gtm_tst/basic/inref/globals.m .yottadb/r

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
	export ydb_chset="UtF-8"
	unset gtmgbldir
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
	. $ydb_dist/ydb_env_set

	ls tmp > /dev/null
	if [ ! $? -eq 0 ] ; then
		echo "FAIL ydb_env_set did not create directory tmp"
		return 1
	fi

	echo "# Copying subtest basic/globals to test new environment"
	cp $gtm_tst/basic/inref/globals.m $ydb_dir/r

	$ydb_dist/yottadb -run globals
	echo "# Checking tmp/$ydb_rel/o for the global object file"
	ls tmp/$ydb_rel/o/globals.o
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
	echo '#\tSingle Region before journaling'
	echo '#\t2 Region before journaling'
	echo '#\tSingle Region nobefore journaling'
	echo '#\t2 Region nobefore journaling'
	echo '#\tSingle Region no journaling'
	echo '#\t2 Region no journaling'
	testNum=6
	old_gtmroutines=$gtmroutines
	old_gtm_chset=$gtm_chset
	for jnl_type in "enable,on,before" "enable,on,nobefore" "disable"; do
		for num_regions in 1 2; do
			epoInv=$( shuf -i 1-15 -n 1 )
			echo "# Test $testNum"
			echo "# Simulating a database crash and recovery with ydb_env_set with $num_regions regions with $jnl_type journaling"
			# database setup
			export gtm_dist=$ydbDistTmp
			export acc_meth="BG"
			export gtm_test_jnl="SETJNL"
			export tst_jnl_str="-journal=$jnl_type"
			if [ $jnl_type != "disable" ]; then tst_jnl_str="$tst_jnl_str,epoch_interval=$epoInv"; fi
			mkdir tmp
			cd tmp
			$gtm_tst/com/dbcreate.csh yottadb $num_regions
			export ydb_dir=$(pwd)
			export ydb_gbldir=$gtmgbldir
			. $ydbDistTmp/ydb_env_set

			echo "# Crashing database"
			$ydb_dist/yottadb -run %XCMD 'for i=1:1 set (^a(i),^b(i))=$j(i,100) hang 0.1' & # start a ydb process and then leave it open
			ydbPid=$!
			sleep $( shuf -i 0-20 -n 1 )
			tcsh $gtm_tst/com/gtm_crash.csh "PID_" $ydbPid # crash the pid
			echo '# Confirming it is crashed'
			$ydb_dist/yottadb -run %XCMD 'write $data(^a)," ",$data(^b),!'

			echo '# Attempting recovery'
			. $ydbDistTmp/ydb_env_unset
			. $ydbDistTmp/ydb_env_set
			# this one only needs to run when recovery is possible
			if [ $jnl_type = "enable,on,before" ]; then
				echo -n 'Checking the recovered database with $data(^a), $data(^b) Expected: 10 10; Actual: '
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
				$gtm_tst/com/dbcheck.csh > dbcheck.log 2>&1;
			else
				echo '# Cannot do a dbcheck as non-before journaling types will have integ errors'
			fi
			cd ..
			mv tmp test$testNum
			testNum=`expr $testNum + 1 `
			echo "\n\n"
		done
	done
	exit 0
}

testG() {
	echo '# Test [12-17]'
	echo '# Testing that databases can shutdown cleanly and come back without errors with properties'
	echo '#\tSingle Region before journaling'
	echo '#\t2 Region before journaling'
	echo '#\tSingle Region nobefore journaling'
	echo '#\t2 Region nobefore journaling'
	echo '#\tSingle Region no journaling'
	echo '#\t2 Region no journaling'
	testNum=12 # keep track of what number directory to move things to
	for jnl_type in "enable,on,before" "enable,on,nobefore" "disable"; do
		for num_regions in 1 2; do
			echo "# Test $testNum"
			echo "# Opening and closing cleanly database with $num_regions regions with $jnl_type journaling"
			# database setup
			export gtm_dist=$ydbDistTmp
			export acc_meth="BG"
			export gtm_test_jnl="SETJNL"
			export tst_jnl_str="-journal=$jnl_type"
			mkdir tmp
			cd tmp
			$gtm_tst/com/dbcreate.csh yottadb $num_regions
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
			$gtm_tst/com/dbcheck.csh > dbcheck.log 2>&1
			cd ..
			mv tmp test$testNum
			testNum=`expr $testNum + 1 `
			echo "\n\n"
		done
	done

	exit 0
}

## MAIN

# Run what every the first argument is as a function
# The only arguments should then be A, B, C, D, E, F, G
$1
