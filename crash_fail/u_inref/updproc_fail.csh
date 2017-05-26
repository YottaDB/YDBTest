#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# TEST :  UPDATE PROCESS FAILS, BACKLOG AND RESTART (6.14)
#
#======== Start update process faliure =======
#
######## kill -15 cannot kill update process, so using the "-shut -updateonly":1/24/99
#
setenv save_dir `pwd`
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG ukill_${kill_time}.logx

echo "Update process will fail..."
cd $SEC_SIDE
echo "Before update process fails: >>>>" 	>&  $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER 		>>& $KILL_LOG
$psuser | $grep -E "mupip|mumps" 		>>& $KILL_LOG

$MUPIP replicate -receiv -checkhealth >&! recv.helth
set updpid = `$tst_awk '/PID.*Update/ {print $2}' recv.helth`
if ("$updpid" == "") then
        echo "Cannot kill update process"
        exit 2
endif
echo "$MUPIP stop $updpid" 			>>& $KILL_LOG
$MUPIP stop $updpid 				>>& $KILL_LOG
if ($status) then
	echo "TEST-E-updproc_fail.csh KILL FAILED" >>& $KILL_LOG
else
	$gtm_tst/com/wait_for_proc_to_die.csh $updpid 300
	echo "Update process has failed!"
endif
#
echo "After update process fails: >>>>" 	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER 		>>& $KILL_LOG
$psuser | $grep -E "mupip|mumps" 		>>& $KILL_LOG
#======== End update process faliure =======

