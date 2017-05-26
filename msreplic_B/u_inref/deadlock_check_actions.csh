#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
# This script handles submitting itself in the background.  It calls itself
# again in the background, forwarding the output properly.
#
# Note that it does not take care of updating msr configuration files (such as
# msr_active_links.txt), because it might cause concurrency issues (since
# multiple copies will be running at the same time).  This should not be an
# issue though, since it does not change the effective layout (which would
# require an update to msr_active_links.txt) at the end of the run.
#
# Usage:
# $MSR RUN SRC=INST1 RCV=INST2 $gtm_tst/$tst/u_inref/deadlock_check_actions.csh SRC
# or
# $MSR RUN RCV=INST2 RCV=INST1 $gtm_tst/$tst/u_inref/deadlock_check_actions.csh RCV

setenv echoline 'echo ###################################################################'

$echoline
set src_or_rcv = $1

# if the SRC is not making backlog progress then moretime will be incremented by 5 sec each time it happens and this will be
# added to the hang time for the SRC
set moretime = 0
setenv addmoretime $moretime

if ("" == $2) then
	# call itself in the background
	setenv time_stamp `date +%H_%M_%S`
	setenv > setenv_$time_stamp.out
	set prino = `echo $gtm_test_cur_pri_name | sed 's/INSTANCE//g'`
	set secno = `echo $gtm_test_cur_sec_name | sed 's/INSTANCE//g'`
	set fname = actions_${prino}_${secno}_${time_stamp}.log
	($0 $argv bg $prino $secno >& $fname &) > pid_${prino}_${secno}
	exit $status
else if ("bg" != $2) then
	echo "TEST-E-WRONGARGS"
	exit 1
endif

########################################################
# the actual script -- note we come here only in the second call, i.e. in the background
#set dbg = "echo"

echo portno is $portno
set tst_primary = $3
set tst_secondary = $4
echo "#argv is: $argv"
echo "#Primary instance: $tst_primary, Secondary Instance: $tst_secondary"
echo "#date: " `date`
set chlog = src_checkhealth_${tst_primary}_${tst_secondary}.log
set sblog = src_showbacklog_${tst_primary}_${tst_secondary}.log

set counter = 1
if (! $?replic_timestamp) then
	setenv replic_timestamp `date +%H_%M_%S`
endif
setenv logtimestamp ${tst_primary}to${tst_secondary}_${replic_timestamp}

# this variable modified when receiver sees $donex_$tst_secondary.out
setenv rcvr_done_string ""

rm -f done_${tst_secondary}* >& /dev/null
while (! -e done_$tst_secondary.out)
	$echoline
	echo "#pwd: "`pwd`
	echo "#date: " `date`
	set stamp = ${logtimestamp}_c{$counter}
	set startfile=START_${stamp}.out
	echo "#startfile:  $startfile"
	if ("SRC" == $src_or_rcv) then
		echo '#1.	Start an active source server to the input secondary instance.'
		#SRC.csh is called with . (rather than on), since replication has already been turned on
		$gtm_tst/com/SRC.csh . $portno $stamp >>&! $PRI_SIDE/$startfile
		set srcstat = $status
		set srcfile = SRC_${stamp}.log
		echo "#srcfile:  $srcfile"
		if ($srcstat) then
			echo "TEST-E-SRCERROR, SRC.csh returned error. Check logs"
			echo "will exit without doing any cleanup"
			echo "TEST-E-SRCERROR" > done_$tst_secondary.out
			$sec_shell "$sec_getenv; cd $SEC_DIR; pwd; echo TEST-E-SRCERROR donex_$tst_secondary.out; ls -l "'done*'
			$sec_shell "$sec_getenv; cd $SEC_DIR; pwd; touch  donex_$tst_secondary.out; ls -l "'done*'
			exit 1
		endif
	else #RCV
		echo '#1.	Start a receiver server receiving from the primary instance.'
		#RCVR.csh is called with . (rather than on), since replication has already been turned on
		set echo
		$gtm_tst/com/RCVR.csh . $portno $stamp >>&! $SEC_SIDE/$startfile
		set rcvrstat = $status
		unset echo
		set rcvrfile = RCVR_${stamp}.log
		echo "#rcvrfile: $rcvrfile"
		ls -l $rcvrfile
		if ($rcvrstat) then
			echo "TEST-E-RCVRERROR, RCVR.csh returned error. Check logs"
			echo "will exit without doing any cleanup"
			echo "TEST-E-RCVRERROR" > done_$tst_secondary.out
			# if primary and secondary are on different platforms we have to $rcp the file
			if ($tst_now_primary == $tst_now_secondary) then
				cp done_$tst_secondary.out $PRI_SIDE/donex_$tst_secondary.out
			else
				$rcp done_$tst_secondary.out ${tst_now_primary}:$PRI_SIDE/donex_$tst_secondary.out
			endif
			exit 1
		endif
	endif
	echo '#2.	Sleep for $r(2.5) seconds.'
	echo "#date: " `date`
	$GTM << \EOF
write $H,!
set a=($RANDOM(25)/10)+$ztrnlnm("addmoretime")
; hang at least .1 sec
hang $select(a:a,1:.1)
write $H,!
write "Oh, by the way, I am ",$JOB,", nice to meet you",!
halt
EOF
#tmp tmp remove
\EOF
	echo "#date: " `date`

	if ("SRC" == $src_or_rcv) then
		echo '#3.	Run a showbacklog command for that secondary.'
		echo '#4.	Run a checkhealth command for that secondary.'
		echo "#date: " `date`
		set echo
		$gtm_tst/com/srcstat.csh "at moment $stamp" $stamp
		unset echo
		echo "#date: " `date`
	else #RCV
		echo '#3.	Run a showbacklog command on the secondary'
		echo '#4.	Run a checkhealth command on the secondary.'
		echo "#date: " `date`
		set echo
		$gtm_tst/com/rcvrstat.csh "at moment $stamp" $stamp
		unset echo
		echo "#date: " `date`
	endif

	if ("SRC" == $src_or_rcv) then
		echo '#5.	Run a changelog command for that secondary.'
		set logfilenamesrc = "SRC_${gtm_test_cur_sec_name}_${counter}.log"
		echo "#date: " `date`
		set echo
		$MUPIP replicate -source -changelog -log=$logfilenamesrc -instsecondary=$gtm_test_cur_sec_name
		unset echo
		$gtm_tst/com/wait_for_log.csh -log $logfilenamesrc -message "Change log to $logfilenamesrc successful" -duration 300 -waitcreation
	else #RCV
		echo '#5.       Run a changelog command on the receiver.'
		set logfilenamercvr = "RCVR_${gtm_test_cur_pri_name}_${counter}.log"
		echo "#date: " `date`
		set echo
		$MUPIP replicate -receiver -changelog -log=$logfilenamercvr
		unset echo
		$gtm_tst/com/wait_for_log.csh -log $logfilenamercvr.updproc -message "Change log to $logfilenamercvr.updproc successful" -duration 300 -waitcreation
	endif
	echo "#date: " `date`

	if ("SRC" == $src_or_rcv) then
		echo '#6. 	Go on until backlog is zero'
		echo '#7.	When backlog is zero, touch done_$tst_secondary.out and exit'
		echo "#date: " `date`
		set sbfile = "sb_$$_`date +%H%M%S`.log"
		$gtm_tst/com/is_backlog_clear.csh $sbfile
		set backlogstat = $status
		if (! $backlogstat) then
			echo "#Backlog cleared, exiting"
			set donemsg = "TEST-I-SUCCESS"
		endif
		if ($?prevsbfile) then
			$grep -v "Initiating SHOWBACKLOG operation" $sbfile > ${sbfile}.tmp
			diff ${prevsbfile}.tmp ${sbfile}.tmp >& /dev/null
			if (! $status) then
				echo "TEST-I-Hey, it looks like there was no change in showbacklog output (${prevsbfile}.tmp vs ${sbfile}.tmp), you know that?"
				#set donemsg = "TEST-E-NO_PROGRESS" # with $R(2.5) seconds, maybe nothing did get sent, so don't error out for this.
				@ moretime += 5
				echo "TEST-I-MORETIME, moretime increased to $moretime"
				setenv addmoretime $moretime
			endif
			\rm -f ${prevsbfile}.tmp >& /dev/null
		else
			$grep -v "Initiating SHOWBACKLOG operation" $sbfile > ${sbfile}.tmp
		endif
		if ($?donemsg) then
			echo "$donemsg" >>! done_$tst_secondary.out
			ls -l `pwd`/done_$tst_secondary.out
			$sec_shell "$sec_getenv; cd $SEC_DIR; echo $donemsg >>! donex_$tst_secondary.out; ls -l $SEC_DIR/donex_$tst_secondary.out"
		endif
		set prevsbfile = $sbfile
		if (-e donex_$tst_secondary.out) then	#there's an error, I was told to stop
			echo "TEST-E-WASTOLDTOQUIT" >>&! done_$tst_secondary.out
			$sec_shell "$sec_getenv; cd $SEC_DIR; pwd; echo TEST-E-WASTOLDTOQUIT donex_$tst_secondary.out; ls -l "'done*'
			$sec_shell "$sec_getenv; cd $SEC_DIR; pwd; touch  donex_$tst_secondary.out; ls -l "'done*'
		endif
	else
		echo '#6.	Go on until told to stop (i.e. backlog is zero on the primary and it creates a donex_$tst_secondary.out here)'
		if (-e donex_$tst_secondary.out) then
			$grep -E ".-E-" donex_$tst_secondary.out >& /dev/null
			if ($status) then	#if there was no error, sync first
				echo '# 	and when told to stop gracefully, wait until backlog is cleared'
				$gtm_tst/com/wait_until_rcvr_backlog_clear.csh
				setenv rcvr_done_string "now I am done, all is good."
			else
				echo '#		when there was some error reported, exit without further ado.'
				setenv rcvr_done_string "TEST-E-WASTOLDTOQUIT"
			endif
		endif
	endif

	echo "#date: " `date`
	echo '#8.	Shutdown the active source server.'
	echo "# shutdown file: SHUT_${stamp}.out"
	if ("SRC" == $src_or_rcv) then
		#$gtm_tst/com/SRC_SHUT.csh on  >>& $PRI_SIDE/SHUT_${stamp}.out
		$MUPIP replic -source -shutdown -instsecondary=$gtm_test_cur_sec_name -timeout=0 >& $PRI_SIDE/SHUT_${stamp}.out
		set srcshutstat = $status
		if ($srcshutstat) then
			$grep "processes still attached to jnlpool" $PRI_SIDE/SHUT_${stamp}.out > /dev/null
			set grepstat = $status
			if ((3 != `wc -l $PRI_SIDE/SHUT_${stamp}.out`) && ($grepstat)) then
				echo "TEST-E-SRCSHUTERROR. Check logs"
				echo "will exit"
				echo "TEST-E-SRCSHUTERROR" > done_$tst_secondary.out
				$sec_shell "$sec_getenv; cd $SEC_DIR; pwd; echo TEST-E-SRCSHUTERROR donex_$tst_secondary.out; ls -l "'done*'
				$sec_shell "$sec_getenv; cd $SEC_DIR; pwd; touch  donex_$tst_secondary.out; ls -l "'done*'
			endif
		endif
	else #RCV
		# if not already told to stop, add a 5 sec delay so we don't do so many restarts on the secondary
		if (! -e donex_$tst_secondary.out) sleep 5
		$gtm_tst/com/RCVR_SHUT.csh on  >>& $SEC_SIDE/SHUT_${stamp}.out
		set rcvrshutstat = $status
		if ($rcvrshutstat) then
			echo "TEST-E-RCVRSHUTERROR, Check logs"
			echo "will exit"
			echo "TEST-E-RCVRSHUTERROR" > done_$tst_secondary.out
			# if primary and secondary are on different platforms we have to $rcp the file
			if ($tst_now_primary == $tst_now_secondary) then
				cp done_$tst_secondary.out $PRI_SIDE/donex_$tst_secondary.out
			else
				$rcp done_$tst_secondary.out ${tst_now_primary}:$PRI_SIDE/donex_$tst_secondary.out
			endif
		else if ("" != "$rcvr_done_string") then
			echo $rcvr_done_string >! done_$tst_secondary.out
		endif
	endif
	@ counter = $counter + 1
end
