#!/usr/local/bin/tcsh -f
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

if ("GT.CM" == $test_gtm_gtcm) then
	echo "TEST-E-GTCM Do not use dbcheck_filter in GT.CM testing"
	exit 1
endif
#==============================
# Process arguments first
#==============================
set noshut=0
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
    echo "dbcheck.csh <-noshut|-extract> <-h> "
    echo "Without any arguments, if database is replicated, the servers are shut down"
    echo "If online reorg is executing, it will be shut down"
    echo "Integrity check will be performed on the database (both source  and receiver side if replicated database)"
    echo "-noshut : replication will not be shut down"
    echo "-extract : Extracts globals from source/receiver server, take the difference"
    echo "Only one of -noshut or -extract will be effective"
    echo "-h : Print this help and exit"
    echo ""
    exit
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
   if  !($noshut) then
     if ($?test_replic) then
	$pri_shell "cd $PRI_SIDE; $gtm_tst/com/close_reorg.csh >>& close_reorg.out"
	$sec_shell "cd $SEC_SIDE; $gtm_tst/com/close_reorg.csh >>& close_reorg.out"
     else
	$gtm_tst/com/close_reorg.csh >>& close_reorg.out
     endif
   endif
endif

if ($?test_replic) then
   if ( "MULTISITE" == $test_replic) then
   	   # To Shut down use MULTISITE action
	   if !($noshut) then
		$MSR SYNC ALL_LINKS
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
   	if !($noshut)  $tst_tcsh $gtm_tst/com/RF_SHUT.csh

   	#===================================================================
   	# Extracts globals from source/receiver server, take the difference
   	#===================================================================
   	if ($extr)   $tst_tcsh $gtm_tst/com/RF_EXTR.csh
   endif
endif


#===============================================================
# Do integrity check on database, both source  and receiver side
# if replicated
#===============================================================
if ($?test_replic) then
     if ( "MULTISITE" != $test_replic ) then
     	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_base_filter.csh $sprgdequal $the_args"
      	set stat = $status
	# Disable sprgde file generation for secondary sides in non-MSR tests (e.g. normal -replic tests)
	# (more effort to make it work in this case with little payoff). We can revisit if/when such a
	# test need arises.
      	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcheck_base_filter.csh -nosprgde $the_args"
      	@ stat = $status + $stat
      	exit $stat
    else
	foreach instx ($gtm_test_msr_all_instances)
		$MSR RUN $instx '$gtm_tst/com/dbcheck_base_filter.csh '$sprgdequal $the_args
      	  	set stat = $status
		echo $msr_execute_last_out >> dbcheck_msr_execute_base_${instx}_out.txt
      	  	@ stat = $status + $stat
	end
      	exit $stat
   endif
else
      $gtm_tst/com/dbcheck_base_filter.csh $sprgdequal $the_args
      exit $status
endif

