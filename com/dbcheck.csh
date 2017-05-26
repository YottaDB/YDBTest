#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

#==============================
# Process arguments first
#==============================
set noshut=0
set replon="on"
set extr=0
set the_args = ""
set inst = ""
set sprgdequal = ""
foreach arg ($argv)
 switch ("$arg")
case "-noshut":
    set extr=0
    set noshut=1
    breaksw
case "-extr*":
case "-extract":
    set extr=1
    set noshut=0
    breaksw
case "-h":
    echo "USAGE of dbcheck.csh:"
    echo "dbcheck.csh <-noshut|-extract|-replon> <-instance=INST1,INST2..> <-h> "
    echo "Without any arguments, if database is replicated, the servers are shut down"
    echo "If online reorg is executing, it will be shut down"
    echo "Integrity check will be performed on the database (both source  and receiver side if replicated database)"
    echo "-noshut : replication will not be shut down"
    echo "-replon : replication will be shut down but not turned off"
    echo "-extract : extracts globals from source/receiver server, take the difference"
    echo "-instance : supported for multisite scenario,lists the instances to extract"
    echo "Only one of -noshut or -extract will be effective"
    echo "-h : Print this help and exit"
    echo ""
    exit
    breaksw
case "-replon":
    set replon="on"
    breaksw
case "-REG":
    # -REG argument is not used
    breaksw
case "INST*":
    set inst = "$inst $arg"
    breaksw
case "-nosprgde":
    set sprgdequal = "-nosprgde"
    breaksw
default:
    set the_args = "$the_args $arg"
    breaksw
endsw
end

#===============================================================
#Shut off reorg if it is there
#===============================================================
# if called outside test suite
if (! $?test_reorg) setenv test_reorg NON_REORG
if ($test_reorg == "REORG") then
   if !($noshut) then
     if ($?test_replic) then
	$pri_shell "cd $PRI_SIDE; $gtm_tst/com/close_reorg.csh >>& close_reorg.out"
	$sec_shell "cd $SEC_SIDE; $gtm_tst/com/close_reorg.csh >>& close_reorg.out"
     else
	$gtm_tst/com/close_reorg.csh >>& close_reorg.out
     endif
   endif
endif

if ( $gtm_test_do_eotf ) then
	if ($?test_replic) then
		$pri_shell "cd $PRI_SIDE; $gtm_tst/com/stop_bkgrnd_eotf.csh >>&! stop_bkgrnd_eotf.out"
		$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/stop_bkgrnd_eotf.csh >>&! stop_bkgrnd_eotf.out"
	else
		$gtm_tst/com/stop_bkgrnd_eotf.csh	>>&! stop_bkgrnd_eotf.out
	endif
endif

if ($?test_replic) then
   if ( "MULTISITE" == $test_replic) then
	   # To Shut down use MULTISITE action
	   if !($noshut) then
		if !($?gtm_test_norfsync) $MSR SYNC ALL_LINKS
		$MSR STOP ALL_LINKS OFF
	   endif
	   # Extracts globals from source/receiver server, take the difference
	   # if $inst is null, i.e. no instances are specifically given in the call
	   # then multisite awk will check for all instances that are prepared intially
	   if ($extr) then
		if ( "" == "$inst" ) set inst="ALL"
		$MSR EXTRACT $inst
	   endif
   else
	   #=========================================
	   # Shut down the source and receiver server
	   #=========================================
	   if !($noshut)  $tst_tcsh $gtm_tst/com/RF_SHUT.csh  $replon
	   #===================================================================
	   # Extracts globals from source/receiver server, take the difference
	   #===================================================================
	   if ($extr) $tst_tcsh $gtm_tst/com/RF_EXTR.csh
   endif
endif

#===============================================================
# Do integrity check on database, both source and receiver side
# if replicated
#===============================================================
if ($?test_replic) then
	set trig_upgrd_unsetenv = "unsetenv gtm_test_trig_upgrade"
	if ( "MULTISITE" != $test_replic ) then
		$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_base.csh $sprgdequal $the_args"
		set stat = $status
		# Disable sprgde file generation for secondary sides in non-MSR tests (e.g. normal -replic tests)
		# (more effort to make it work in this case with little payoff). We can revisit if/when such a
		# test need arises.
		# Also disable trigger upgrade testing on secondary side. We already did it on primary and secondary
		# is going to be no different.
		$sec_shell "$sec_getenv; cd $SEC_SIDE; $trig_upgrd_unsetenv; $gtm_tst/com/dbcheck_base.csh -nosprgde $the_args"
		@ stat = $status + $stat
		exit $stat
	else
		foreach instx ($gtm_test_msr_all_instances)
			# Disable trigger upgrade testing on all instances other than inst1. The rest of the instances
			# are going to be no different in terms of trigger content.
			if ($?gtm_test_trig_upgrade) then
				if ($instx != "INST1") then
					$MSR RUN $instx "set msr_dont_trace ; echo $trig_upgrd_unsetenv >> env_supplementary.csh"
				endif
			endif
			$MSR RUN $instx '$gtm_tst/com/dbcheck_base.csh '$sprgdequal $the_args
			set stat = $status
			echo $msr_execute_last_out >> dbcheck_msr_execute_base_${instx}_out.txt
			@ stat = $status + $stat
		end
		exit $stat
	endif
else
	if ("GT.M" == $test_gtm_gtcm) then
		$gtm_tst/com/dbcheck_base.csh $sprgdequal $the_args
		exit $status
	else
		#Turn off GT.CM
		echo "Stopping the GT.CM Servers..."
		set gtcmstoplog = gtcm_stop_`date +%H_%M_%S`.log
		$gtm_tst/com/GTCM_STOP.csh $gtcmstoplog
		set stat = $status
		if ($stat) echo "TEST-E-GTCMSTOP Error from GTCM_STOP.csh. Check gtcm_stop_*.log on the servers"
		echo "Check the databases on the GT.CM Servers..."
		$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM; $gtm_tst/com/dbcheck_base.csh -nosprgde $the_args"
		# since the database file are on remote, do the integ there
		if (-e a.dat) then
			echo "Check local (client) database..."
			$gtm_tst/com/dbcheck_base.csh -nosprgde a $the_args
		endif
		@ stat = $status + $stat
		exit $stat
	endif
endif
