#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Journaled update throughput, in nanoseconds per update.  See README.md.
#
#	./jnlupdatetime.csh <ydb_dist> [updates per trial] [trials]

if ($#argv < 1) then
	echo "usage: $0 <ydb_dist> [updates per trial] [trials]"
	exit 1
endif

setenv ydb_dist "$1"
if (! -x "$ydb_dist/mumps") then
	echo "no mumps in $ydb_dist"
	exit 1
endif

set n = 200000
set trials = 10
if ($#argv > 1) set n = "$2"
if ($#argv > 2) set trials = "$3"

set here = `dirname $0`
set here = `cd $here && pwd`
set work = `mktemp -d`
onintr cleanup

cp $here/jnlupdatetime.m $work/
cd $work

setenv PATH "${ydb_dist}:${PATH}"
setenv ydb_routines ". $ydb_dist/libyottadbutil.so"
setenv ydb_gbldir "$work/bench.gld"

$ydb_dist/mumps -run GDE >&! gde.out << GDEEOF
change -segment DEFAULT -file_name=bench.dat -allocation=100000 -extension=50000
change -region DEFAULT -journal=(before,file="bench.mjl",allocation=100000,autoswitchlimit=8388600)
exit
GDEEOF
$ydb_dist/mupip create >&! create.out

# This runs standalone, outside the test framework, so tst_awk may not be set.  Checked with
# printenv rather than $?tst_awk, since a whole line variable substitution defeats that guard.
set awkcmd = `printenv tst_awk`
if ("$awkcmd" == "") set awkcmd = awk

# Pinning to one cpu takes a visible bite out of the run to run spread
set run = ""
which taskset >& /dev/null
if (0 == $status) set run = "taskset -c 1"

echo "build   : $ydb_dist"
$ydb_dist/mumps -run %XCMD 'write "version : ",$piece($zyrelease," ",2)," ",$piece($zyrelease," ",4),!'
echo "updates : $n per trial, best of $trials trials, pinned: $run"
echo
printf '%-10s %-12s %12s\n' workload journaling ns/update
printf '%-10s %-12s %12s\n' -------- ---------- ---------
foreach jnl (ON OFF)
	if ("$jnl" == "ON") then
		$ydb_dist/mupip set -journal=enable,on,before -region '*' >&! jnlon.out
	else
		$ydb_dist/mupip set -journal=disable -region '*' >&! jnloff.out
	endif
	foreach wkld (point tree)
		set out = `$run $ydb_dist/mumps -run run^jnlupdatetime "$wkld" "$n" "$trials"`
		set ns = `echo "$out" | $awkcmd -F, '{print $4}'`
		printf '%-10s %-12s %12s\n' "$wkld" "$jnl" "$ns"
	end
end
echo
echo "Compare the ON rows between two builds.  The OFF rows are the control: SET_GBL_JREC_TIME sits"
echo "inside the JNL_ENABLED test in t_end.c, so a change to it cannot move them.  Whatever the OFF"
echo "rows differ by is the noise floor a difference in the ON rows has to beat to mean anything."

cleanup:
cd /
rm -rf $work
