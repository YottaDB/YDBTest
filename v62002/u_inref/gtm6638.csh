#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
setenv gtm_poollimit 0 # gtmpoollimit setting causes restarts, due to which threein1.m takes a long time to run and intermittent failures.

set hostn = $HOST:r:r:r

# For servers that are very slow with defer allocate OFF, turn it ON
set daonservers="flyingv"
echo $daonservers | $grep -w "$hostn" > /dev/null
if (!($status)) then
	setenv gtm_test_defer_allocate 1
endif

# We want epoch tapering so don't use the random setting
setenv gtm_test_epoch_taper 1

$gtm_tst/com/dbcreate.csh mumps 1 900 -allocation=2048 -extension_count=2048

echo "Verify epoch tapering is on by default"
$DSE change -fileheader -sleep_spin_count=128
$DSE dump -fileheader -all | & $grep "Epoch taper"

echo "Verify GDE with -noepochtaper"
rm mumps.dat
$GDE change -region DEFAULT -noepochtaper >>& gde_et1.out
$MUPIP create >>& gde_et1.out
$DSE change -fileheader -sleep_spin_count=128
$DSE dump -fileheader -all | & $grep "Epoch taper"

echo "Verify GDE with -epochtaper"
rm mumps.dat
$GDE change -region DEFAULT -epochtaper >>& gde_et2.out
$MUPIP create >>& gde_et2.out
$DSE change -fileheader -sleep_spin_count=128
$DSE dump -fileheader -all | & $grep "Epoch taper"

echo "Turn off tapering and verify it is off"
$MUPIP set -noepochtaper -region "*"
dse dump -fileheader -all | & $grep "Epoch taper"

echo "Turn on tapering and verify it is on"
$MUPIP set -epochtaper -region "*"
dse dump -fileheader -all | & $grep "Epoch taper"

echo "Verify if epoch taper is disabled in the template a new region picks it up"
$GDE >>& gde_et3.out << END
show -template
template -region -noepochtaper
show -template
add -name a -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a.dat
show -region
quit
END

echo "Examine the before and after for the template"
$tst_awk '/<default>.*Sep/ {print $1,$10}' gde_et3.out

echo "Examine the just added region"
$tst_awk '/AREG.*Sep/ {print $1,$11}' gde_et3.out

echo "Bump up the global buffers so we can accumulate some dirty buffers"
$MUPIP set -global_buffers=32767 -region "*"
echo "Set time based epoch to 90 seconds and autoswitch based epoch to 1 GB."
echo "At this writing, this is what Profile runs with."
$MUPIP set -journal="enable,on,before,epoch=90,auto=2097152" -reg "*" >& jnl.log

($ydb_dist/mumps -run %XCMD 'do showdbuffs^epochmon("DEFAULT",1,2000)' >taperdata.txt & ; echo $! >! mon_pid.log) >&! mon.outx
set mon_pid = `cat mon_pid.log`

# If server has more than 4 CPUs, then consider it fast and have a higher limit. Else a lower limit.
@ numcpus = `grep -c ^processor /proc/cpuinfo`
if (4 < $numcpus) then
	set upperbound=3000000
	set expected=559
else
	set upperbound=250000
	set expected=442
endif

echo "upperbound=$upperbound expected=$expected" >3nparms.out

echo "Run 3n+1 to generate some dirty buffers"
set nthreads = `grep -c ^processor /proc/cpuinfo`	# Use # of CPUs as the # of threads to avoid swamping the system
# Randomly choose to run M or C (simpleAPI) version of the test
if !($?gtm_test_replay) then
	set usesimpleapi = `$gtm_exe/mumps -run rand 3`
	echo "setenv usesimpleapi $usesimpleapi" >> settings.csh
endif

if ($usesimpleapi) then
	if (1 == $usesimpleapi) then
		# Run SimpleAPI equivalent of ^threeen1f
		set file="simpleapi_threeen1f.c"
	else
		# Run SimpleThreadAPI equivalent of ^threeen1f
		set file="simplethreadapi_threeen1f.c"
	endif
	cp $gtm_tst/$tst/inref/$file .
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$ydb_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "LVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		exit -1
	endif
	echo 1 $upperbound $nthreads 100 | `pwd`/$exefile > threeen1f.out
	set exit_status = $status
else
	echo 1 $upperbound $nthreads 100 | $ydb_dist/mumps -run threeen1f > threeen1f.out
endif

set actual=`cat threeen1f.out | cut -f5 -d" "`

if ("$actual" == $expected) then
	echo "Pass"
else
	echo "Fail: expected=$expected actual=$actual"
	cat threeen1f.out
endif

# Make sure the monitoring pid is gone
$kill -15 $mon_pid >/dev/null
$gtm_tst/com/wait_for_proc_to_die.csh $mon_pid

$gtm_tst/com/dbcheck.csh
