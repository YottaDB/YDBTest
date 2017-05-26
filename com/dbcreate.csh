#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ($?gtm_trace_gbl_name) then
	set mprof_env = `echo $gtm_trace_gbl_name`
	unsetenv gtm_trace_gbl_name
endif

if ($?gtm_tst) then
	setenv source_dir $gtm_tst/com
else
	setenv source_dir $gtm_test/T990/com
	setenv gtm_tst $gtm_test/T990
	setenv gtm_test_mupip_set_version "disable"
	setenv gtm_test_disable_randomdbtn
	source $source_dir/set_gtm_machtype.csh
endif
if !($?gtm_test_trigger) setenv gtm_test_trigger 0
if !($?test_encryption) setenv test_encryption NON_ENCRYPT
if !($?gtm_test_spannode) setenv gtm_test_spannode 0
if !($?gtm_test_spanreg) setenv gtm_test_spanreg 0
if (! $?gtm_test_tls) setenv gtm_test_tls FALSE
if (! $?gtm_test_jnl) setenv gtm_test_jnl NON_SETJNL
if (! $?gtm_test_do_eotf) setenv gtm_test_do_eotf 0

source $source_dir/set_specific.csh

set timenow = `date +%H_%M_%S`
set renamecount = 0
set rename = "$timenow"
while (-e dbcargs.csh_$rename)
	@ renamecount++
	set rename = "${timenow}_$renamecount"
end
if (-e dbcargs.csh) \mv dbcargs.csh dbcargs.csh_$rename
$gtm_tst/com/dbcargs.csh $argv >&! dbcargs.csh
source dbcargs.csh
if ( "$argv" != "$newargs") then
	echo "# The arguments to dbcreate '$argv' were randomized to the following " >> settings.csh
	echo "setenv gtm_test_dbcargs '$newargs'" >> settings.csh
	# assume region randomization in the next round of changes
	# setenv gtm_test_silence_dbcreate 1
endif

if (!($?test_replic)) then
   # DB creation for NON-REPLICATION tests
   if !($?test_gtm_gtcm) setenv test_gtm_gtcm "GT.M" #default
   if ("GT.M" == $test_gtm_gtcm) then
	   # create database files on the localhost (no networking)
	   source $source_dir/dbcreate_base.csh $newargs
	   if ($status != 0 ) exit 1
	   if ($?test_reorg) then
	      if ("REORG" == $test_reorg) then
		 $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg1.out
		 $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg2.out
		 $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg3.out
		 $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg4.out
	      endif
	   endif
	   if ( $gtm_test_do_eotf ) then
		$gtm_tst/com/bkgrnd_eotf.csh	>>&! bkgrnd_eotf.out
	   endif
   else
   	#GT.CM
	#create the database on the "remote" server
   	$source_dir/send_env.csh
	echo "Create database on GT.CM Servers ( $tst_gtcm_server_list)..."
	set tmpenv = `$sec_shell "echo TST_REMOTE_HOST_GTCM:SEC_DIR_GTCM/"`
	set tmpenv = `echo  $tmpenv | sed 's/ /,/g'`
	echo "$sec_shell 'SEC_SHELL_GTCM SEC_GETENV_GTCM  ; cd SEC_DIR_GTCM ; source $source_dir/dbcreate_base.csh -GTCM_REMOTE $tmpenv $newargs'" > dbcreate.gtcm
	$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM  ; cd SEC_DIR_GTCM ; source $source_dir/dbcreate_base.csh -GTCM_REMOTE $tmpenv $newargs"
	if ($status != 0 ) exit 1
	echo "Create local (client) database..."
	source $source_dir/dbcreate_base.csh -GTCM_LOCAL $tmpenv $newargs
	if ($status != 0 ) exit 1
	$GDE << EOF_GDE >&! gde_out.tmp
	show -segment
EOF_GDE
	echo "The database layout is:"
	$grep -E "SEG|DEFAULT" gde_out.tmp | $tst_awk '{if ("***" != $1) print $1 "\t" $2}'
	\rm -f  gde_out.tmp >& /dev/null
	source $gtm_tst/com/GTCM_START.csh
   endif

else
   # DB creation for tests with REPLICATION

   # create a database on both source and receiver side
   # Starts source/receiver server
   if ( !($?tst_org_host && $?tst_remote_host && $?PRI_DIR && $?SEC_DIR && $?sec_shell && $?sec_getenv)) then
      echo please set the necessary environment variables for replication
      echo tst_org_host tst_remote_host PRI_DIR SEC_DIR sec_shell sec_getenv
      echo "gtm_tst test_reorg ,... (and it still might not work outside the test system)"
      exit
   endif
   if (!($?tst_general_dir)) setenv tst_general_dir .
   if ($tst_org_host != $tst_remote_host) $source_dir/send_env.csh
   # For multisite scenario we need databases in all the instances so let's loop thro' all of them
   if ( "MULTISITE" == $test_replic ) then
      foreach instx (`echo $gtm_test_msr_all_instances`)
	    set extra_inst_args = ""
	    if ( `eval echo '$?'${instx}_dbcreate_extra_args` ) then
	        eval 'set extra_inst_args=$'${instx}_dbcreate_extra_args
   	    endif
	    setenv temp_argv "$newargs $extra_inst_args"
            if ("INST1" == $instx) then
		set test_on_remote = ""
            else
                set test_on_remote = "setenv tst_on_remote 1;"
            endif
	    if ($?gtm_test_disable_randomdbtn && $?gtm_test_mupip_set_version) then
		  set test_remote_disable = "setenv gtm_test_disable_randomdbtn '$gtm_test_disable_randomdbtn'; setenv gtm_test_mupip_set_version '$gtm_test_mupip_set_version';"
	    else
		  set test_remote_disable = ""
	    endif
	    $MSR RUN $instx 'set msr_dont_trace;'"${test_on_remote}${test_remote_disable}"'source '$source_dir'/dbcreate_base.csh '$temp_argv
        if ($status != 0 ) exit 1
      end
   else
      cd $PRI_SIDE;  source $source_dir/dbcreate_base.csh $newargs
      if ($status != 0 ) exit 1
      $sec_shell "$sec_getenv; cd $SEC_SIDE; setenv tst_on_remote 1; source $source_dir/dbcreate_base.csh $newargs "
      if ($status != 0 ) exit 1
      #===================================================
      #====== Now start source and receiver server =======
      #===================================================
      $tst_tcsh $source_dir/RF_START.csh
   endif



   if ("REORG" == $test_reorg) then
        $pri_shell "cd $PRI_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg1.out"
        $pri_shell "cd $PRI_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg2.out"
        $pri_shell "cd $PRI_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg3.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg1.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>&! reorg2.out"
   endif
   if ( $gtm_test_do_eotf ) then
	$pri_shell "cd $PRI_SIDE; $gtm_tst/com/bkgrnd_eotf.csh	>>&! bkgrnd_eotf.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/bkgrnd_eotf.csh	>>&! bkgrnd_eotf.out"
   endif

endif

if ($?mprof_env) then
	setenv gtm_trace_gbl_name "$mprof_env"
endif
