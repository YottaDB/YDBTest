#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
unset backslash_quote
date
setenv rol_or_rec  $1
set bg_or_fg = $2
set outfile = $3
shift
shift
shift
if (-e mupip.pid) mv mupip.pid mupip.pid_`date +%H_%M_%S`
# run MUPIP with -noverify half the time
set verify = "-verify"
set rand = `$gtm_exe/mumps -run rand 2`
if (0 == $rand) set verify = "-noverify"

if (("RECOVER" == "$rol_or_rec") || ("BG" == "$bg_or_fg")) then
	set command = "$MUPIP journal -$rol_or_rec -back $verify -verbose"
else
	# ROLLBACK and that too non-interrupted. Use mupip_rollback.csh so we also test forward rollback.
	set command = "$gtm_tst/com/mupip_rollback.csh $verify -verbose"
endif

set q = '"'
# to get the exact command line
echo "$command $q*$q " `echo $argv| sed 's/"/\\"/g'` | tee -a $outfile
# On zOS, tee creates UNTAGGED files so need to tag it before GT.M or MUPIP writes to it (happens later as part of timecalc.m)
$convert_to_gtm_chset $outfile
if ("BG" == $bg_or_fg) then
	($gtm_tst/$tst/u_inref/runit.csh "$command" $argv >>&! $outfile )&
	# runit.csh is needed to output the dates before and after the mupip command
	# (as it possibly will be killed, the date output of mupip is not guaranteed to be present)
	# ($command "*" $argv >>&! $outfile )&
	echo $! >! mupip_parent.pid
	set parent_pid = $!
	echo "parent_pid is: $parent_pid"
	echo "Determine the pid of the mupip process..."
	set c = 60
	while ($c > 0)
		@ c = $c - 1
		set psout = ps.out_`date +%H_%M_%S`		#BYPASSOK("ps")
		echo "The ps output is in: $psout"
		$ps | $grep $parent_pid > $psout
		$grep mupip $psout | $grep -vE "grep|runit.csh" | $tst_awk '{if ($3 == "'$parent_pid'") print $2; if ($5 == "'$parent_pid'") print $4}' >! mupip.pid
		if !(-z mupip.pid) break
		sleep 1
		echo "Check one more time ($c left)..."
	end
	echo "The mupip pid is: "`cat mupip.pid`
else
	 date >>&! $outfile
	 $command "*" $argv >>&! $outfile
	 date >>&! $outfile
endif
date
