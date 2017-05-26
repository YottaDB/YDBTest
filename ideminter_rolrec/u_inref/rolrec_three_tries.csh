#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Call as: rolrec_three_tries [RECOVER|ROLLBACK] [CRASH|STOP|IDEMP] [ZTP|.] [round_no]
# 02/12/2004 - zhouc
# The ideminter_rolrec test has a subtest that tries to issue a MUPIP STOP or STOP to rollback/recover.
#It does this currently using a $rand function of a maximum value picked up from the file rates.txt
# which has platform specific expected durations of the rollback/recover. This is supposed to catch
#rollback/recover uniformly at all points in its processing i.e. in mur_open_files as well as
# mur_close_files. But the problem is we cannot be sure how long recover/rollback will take so we
# cannot be sure what is a good value to sleep to interrupt it in mur_close_files().
# To accommodate this, the test allows for the possibility that we did a MUPIP STOP or STOP on a
# non-existent process i.e. a missed STOP or MUPIP STOP. But it currently allows only 4 out of 6
# tries to miss. At least 2 should have been hit. We have seen a lot of failures where either all
# or all-except-one try got missed. To avoid spending time analyzing these failures and adjust
# rates.txt here is what is going to be done.
#
# a) Remove rates.txt altogether. Keep 10 as the default value for everybody.
# b) set rates as 3, 6, 9 for the three tries.
# c) Take $r(3). It should be in the range 0 to 2. Let us say it comes out to be 2.
# d) Take 2**2 = 4
# e) Then take $r(4)
# f) Add them. sleeptime = 4 + $r(4)
# g) Sleep for this duration  before killing recover/rollback.
# In case we are in the third try and both the previous attempts have failed, following method is used.
# a) Note the actual time taken by the MUPIP command in the previous tries
# b) Note the minimum time of the two
# c) Take 25% of the time in b)
# d) Set sleep of the third try to the number in c)
# Do this sleep in 1-second increments that keep checking if recover/rollback process is alive.
# If not alive, then stop sleeping. That way we do not sleep for more than what is needed.
# Use is_proc_alive.csh/com scripts to do this check.
#
unset backslash_quote
echo "#########################################################################"
echo $argv
set rol_or_rec = $1
set intr_stop_idemp = $2
set ztptp = $3
set round_no = 1
if ("" != $4) set round_no = $4
set r_values = "3 6 9"
echo "Will run:" $rol_or_rec
echo "Will :" $intr_stop_idemp
echo "# CRASH: will crash the mupip command"
echo "# STOP:  will MUPIP STOP the mupip command"
echo "# IDEMP: will let the mupip command run to completion"
echo "First MUPIP: "
set logs = ${rol_or_rec}${round_no}_1
setenv rand_value  `echo $r_values | $tst_awk '{print $1}'`
setenv logno ${round_no}_1
if (RECOVER == $rol_or_rec) then
	# time1_abs and time2_abs would have been created by test/com_u/abs_time.csh which uses tee.
	# On zOS, tee creates UNTAGGED files so need to tag these before GT.M reads the same file in UTF8 mode.
	$convert_to_gtm_chset time1_abs
	$convert_to_gtm_chset time2_abs
	echo "The time of the initial update:" `cat time1_abs`
	echo "The time of the final   update:" `cat time2_abs`
	set btpercent = 95
	if (1 == $round_no) then
		@ rand = `$gtm_exe/mumps -run rand 30` + 10	#[10,40)	#round 1
	else
		@ rtop = $btpercent - 15
		@ rand = `$gtm_exe/mumps -run rand $rtop` + 10	#[10,90)	#round 2
	endif
	set since_time = `$gtm_exe/mumps -run timecalc time1_abs time2_abs .$rand`
	mv timecalc.txt since_time${logno}.txt
	echo "since_time: $since_time	($rand %)"
	if ("ZTP" == $ztptp) then
		set before = ""
		cp since_time${logno}.txt before_time${logno}.txt # create a dummy file
	else
		set before_time = `$gtm_exe/mumps -run timecalc time1_abs time2_abs .$btpercent`
		mv timecalc.txt before_time${logno}.txt
		echo "before_time: $before_time 	($btpercent %)"
		set before = '-before="'"$before_time"'"'
	endif
	$gtm_tst/$tst/u_inref/try_rolrec.csh $rol_or_rec $intr_stop_idemp $ztptp $logs.logx -since=\"$since_time\" $before
	set stat = $status
	echo Status of try_rolrec is: $stat
	if ($stat) echo "TEST-E-ERROR from try_rolrec.csh, check $logs.logx"
	if (4 == $stat) exit 4
else
	#ROLLBACK
	echo "max_seqno is:" $max_seqno
	echo $max_seqno > max_seqno.txt
	# seqno: (75-100] % of max_seqno
	@ rand = `$gtm_exe/mumps -run rand 25` + 76
	if (100 == $rand) then
		setenv seqno  $max_seqno
	else
		# Compute seqno but set it to a minimum of 25 to keep checkdb.m happy
		setenv seqno  `echo $max_seqno $rand | $tst_awk '{x=$1*$2/100; if (x < 25) x=25; printf "%d",x;}'`
	endif
	echo "seqno: $seqno ($rand %)"
	echo $seqno >! seqno{$logno}.txt
	$gtm_tst/$tst/u_inref/try_rolrec.csh $rol_or_rec $intr_stop_idemp $ztptp $logs.logx $rollbackmethod -resync=$seqno -lost=$logs.lost
	set stat = $status
	echo Status of try_rolrec is: $stat
	if ($stat) echo "TEST-E-ERROR from try_rolrec.csh, check $logs.logx"
	if (4 == $stat) exit 4
endif

#set rand = `$gtm_exe/mumps -run rand 4` <- if we decide not to try MUPIP three times at every run
set rand = 0
if (0 == $rand) then
	echo "#########################################################################"
	echo "Will try one more time..."
	# i.e. with a probability of .25
	echo "Second MUPIP: "
	set logs = ${rol_or_rec}${round_no}_2
	setenv logno ${round_no}_2
	setenv rand_value `echo $r_values | $tst_awk '{print $2}'`
	if (RECOVER == $rol_or_rec) then
		set btpercent = 85
		if (1 == $round_no) then
			@ rand = `$gtm_exe/mumps -run rand 30` + 10 	#[10,40)        #round 1
		else
			@ rtop = $btpercent - 15
			@ rand = `$gtm_exe/mumps -run rand $rtop` + 10	#[10,80)	#round 2
		endif
		set since_time = `$gtm_exe/mumps -run timecalc time1_abs time2_abs .$rand`
		mv timecalc.txt since_time${logno}.txt
		echo "since_time: $since_time	($rand %)"
		if ("ZTP" == $ztptp) then
			set before = ""
			cp since_time${logno}.txt before_time${logno}.txt # create a dummy file
		else
			set before_time = `$gtm_exe/mumps -run timecalc time1_abs time2_abs .$btpercent`
			mv timecalc.txt before_time${logno}.txt
			echo "before_time: $before_time 	($btpercent %)"
			set before = '-before="'"$before_time"'"'
		endif
		$gtm_tst/$tst/u_inref/try_rolrec.csh $rol_or_rec $intr_stop_idemp $ztptp $logs.logx -since=\"$since_time\" $before
		set stat = $status
		echo Status of try_rolrec is: $stat
		if ($stat) echo "TEST-E-ERROR from try_rolrec.csh, check $logs.logx"
		if (4 == $stat) exit 4
	else
		# seqno: (50-75] % of max_seqno
		@ rand = `$gtm_exe/mumps -run rand 25` + 51
		# Compute seqno but set it to a minimum of 25 to keep checkdb.m happy
		set seqno = `echo $max_seqno $rand | $tst_awk '{x=$1*$2/100; if (x < 25) x=25; printf "%d",x;}'`
		echo "seqno: $seqno ($rand %)"
		echo $seqno >! seqno{$logno}.txt
		source $gtm_tst/$tst/u_inref/online_rollback_v4_aversion.csh
		$gtm_tst/$tst/u_inref/try_rolrec.csh $rol_or_rec $intr_stop_idemp $ztptp $logs.logx $rollbackmethod -resync=$seqno -lost=$logs.lost
		set stat = $status
		echo Status of try_rolrec is: $stat
		if ($stat) echo "TEST-E-ERROR from try_rolrec.csh, check $logs.logx"
		if (4 == $stat) exit 4
	endif
	#set rand = `$gtm_exe/mumps -run rand 4` <- if we decide not to try MUPIP three times at every run
	set rand = 0
	if (0 == $rand) then
		echo "#########################################################################"
		echo "And yet one more time..."
		# i.e. with a probability of .25 * .25
		echo "Third MUPIP: "
		set logs = ${rol_or_rec}${round_no}_3
		setenv logno ${round_no}_3
		setenv rand_value `echo $r_values | $tst_awk '{print $3}'`
		# Check if more than the threshold attempts failed
		find . -name 'MUPIP*.log' >>& files_found.log
		find . -name 'MUPIP*.log' -exec $grep -E "NOTALIVE|MUPIPDIDNOTSTOP" {} \;  | wc -l > 	check_previous_rounds.logx
		@ allowed = ($round_no * 2) - 1
		if ($allowed  < `cat check_previous_rounds.logx`) then
			# Thousand is just a max value
			set elaptime = 1000
			foreach logfile (${rol_or_rec}${round_no}_?.logx)
				set tmpelaptime = `$tst_awk '/The time the mupip command took/{print $7}' $logfile`
				if ($elaptime > $tmpelaptime) set elaptime = $tmpelaptime
			end
			@ sleeptime = $elaptime / 4
			setenv third_sleeptime $sleeptime
			echo "Failed in previous two cases, passing the sleep time of: "$sleeptime
		endif
		if (RECOVER == $rol_or_rec) then
			set btpercent = 75
			if (1 == $round_no) then
				@ rand = `$gtm_exe/mumps -run rand 30` + 10	#[10,40)        #round 1
			else
				@ rtop = $btpercent - 15
				@ rand = `$gtm_exe/mumps -run rand $rtop` + 10	#[10,70)	#round 2
			endif
			set since_time = `$gtm_exe/mumps -run timecalc time1_abs time2_abs .$rand`
			mv timecalc.txt since_time${logno}.txt
			echo "since_time: $since_time	($rand %)"
			if ("ZTP" == $ztptp) then
				set before = ""
				cp since_time${logno}.txt before_time${logno}.txt # create a dummy file
			else
				set before_time = `$gtm_exe/mumps -run timecalc time1_abs time2_abs .$btpercent`
				mv timecalc.txt before_time${logno}.txt
				echo "before_time: $before_time 	($btpercent %)"
				set before = '-before="'"$before_time"'"'
			endif
			$gtm_tst/$tst/u_inref/try_rolrec.csh $rol_or_rec $intr_stop_idemp $ztptp $logs.logx -since=\"$since_time\" $before
			set stat = $status
			echo Status of try_rolrec is: $stat
			unsetenv third_sleeptime
			if ($stat) echo "TEST-E-ERROR from try_rolrec.csh, check $logs.logx"
			if (4 == $stat) exit 4
		else
			#ROLLBACK
			# seqno: (25-50] % of max_seqno
			@ rand = `$gtm_exe/mumps -run rand 25` + 26
			# Compute seqno but set it to a minimum of 25 to keep checkdb.m happy
			set seqno = `echo $max_seqno $rand | $tst_awk '{x=$1*$2/100; if (x < 25) x=25; printf "%d",x;}'`
			echo "seqno: $seqno ($rand %)"
			echo $seqno >! seqno{$logno}.txt
			source $gtm_tst/$tst/u_inref/online_rollback_v4_aversion.csh
			$gtm_tst/$tst/u_inref/try_rolrec.csh $rol_or_rec $intr_stop_idemp $ztptp $logs.logx $rollbackmethod -resync=$seqno -lost=$logs.lost
			set stat = $status
			echo Status of try_rolrec is: $stat
			unsetenv third_sleeptime
			if ($stat) echo "TEST-E-ERROR from try_rolrec.csh, check $logs.logx"
			if (4 == $stat) exit 4
		endif
	endif
endif
#######################################################################################
# Since the logs were written into *.logx, filter out FORCEDHALT and move them into *.log
# this filtering is necessary because otherwise the test would fail even for the
# acceptable number of "miss"es, since it will not have the FORCEDHALT message in the log file.
foreach logxfile (${rol_or_rec}${round_no}_*.logx mstop_*.logx)
	set logfile = `echo $logxfile | sed 's/x$//g'`
	sed 's/-F-FORCEDHALT/-X-FORCEDHALT/g; s/-E-MUNOACTION/-X-MUNOACTION/; s/-W-MUKILLIP/-X-MUKILLIP/' $logxfile >! $logfile
end

#######################################################################################
echo "#########################################################################"
echo "The MUPIP commands run were:"
$head -n 1 ${rol_or_rec}${round_no}_?.log

