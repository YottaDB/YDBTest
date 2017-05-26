#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#################
# Run the sub-test
#################
# Followings are what instream.csh passes
# $1 = Local or, Global or, Global+reorg or, TP
# $2 = Sequential collating order of Keys or, Random Keys
# $3 = Journal vs No journal
# $4 = number of region
# $5 = number of processes
# $6 = Number of kinds of operations to test
# $7 = Number of repeatation of inner most test loop
#
set typestr = $1
set order = $2
set jnlstr = $3
set regcnt = $4
set jobcnt = $5
set totop = $6
set repeat = $7
set subtest="$typestr"_"$order"_"$jnlstr"
#
# Save system state so that we know it was not run with high system load
echo "SPEED_TEST: System State: " >>&  $tst_general_dir/load.txt
echo "$typestr" "$order" "$jnlstr": Regions="$regcnt" Jobs="$jobcnt"  Kinds="$totop" Repeat="$repeat"  >>&  $tst_general_dir/load.txt
$uptime | $head -n 1 >>&  $tst_general_dir/load.txt
$ps >>&  $tst_general_dir/load.txt
#
# Now run the subtest
$gtm_tst/$tst/u_inref/speed.csh $1 $2 $3 $4 $5 $6 $7 >>& $subtest.log
#
#################
# Now analyze it
#################
# These texts will appear in outstream.log
grep PASS $subtest.log | grep -v PASSED | cut -f 1,2,3,4,5,14 -d :
set passtat = $status
grep FAIL $subtest.log | cut -f 1,2,3,4,5,14 -d :
set failstat = $status
#
# Process results: result.txt will have actual speed but not outstream.log
#
echo " " >>&  $tst_general_dir/result.txt
echo "$typestr" "$order" "$jnlstr": Regions="$regcnt" Jobs="$jobcnt"  Kinds="$totop" Repeat="$repeat"  >>&  $tst_general_dir/result.txt
grep "SPEED_TEST"  $subtest.log >>&  $tst_general_dir/result.txt
#
# Actual output from speed test are saved in sp_data.txt, for detailed analysis
#
echo " " >>&  $tst_general_dir/sp_data.txt
echo "$typestr" "$order" "$jnlstr": Regions="$regcnt" Jobs="$jobcnt"  Kinds="$totop" Repeat="$repeat"  >>&  $tst_general_dir/sp_data.txt
egrep "\^elaptime|\^cputime|\^elpovrhd|\^cpuovrhd|\^confl|\^sizes"  $subtest.log >>&  $tst_general_dir/sp_data.txt
#
if (0 == $passtat && 0 != $failstat && 0 == $?tst_keep_output) then
	rm -f {*.dat,*.gld,*.mj*,tmp.mupip*,*.out*,*.txt,*.repl,pri*.glo}
	if (0 == $?test_replic) then
		\ls $test_jnldir/*.mjl* >& /dev/null
		if ($status == 0) then
			rm -rf  $test_jnldir/*.mjl*
		endif
	endif
else
	if !( -d ./$subtest) mkdir ./$subtest
	\mv {*.dat,*.gld,*.mj*,{,gtm}core*,tmp.mupip*,*.out*,*.txt,*.repl,pri*.glo} ./$subtest
	if (0 == $?test_replic) then
		\ls $test_jnldir/*.mjl* >& /dev/null
		if ($status == 0) then
			if !( -d $test_jnldir/$subtest) mkdir $test_jnldir/$subtest
			\mv $test_jnldir/*.mjl* $test_jnldir/$subtest
		endif
	endif
endif
#
