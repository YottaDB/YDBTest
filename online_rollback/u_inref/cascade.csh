#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is already a heavyweight test, no need to increase it's weight
unsetenv gtm_test_fake_enospc
setenv test_replic_suppl_type 0
setenv msr_dont_trace 1

# use 2MB align size to avoid central memory exhaustion errors
setenv test_align 4096
set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
setenv tst_jnl_str $tstjnlstr
set time_msr_list = ()

$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh mumps 5 125-260 256-500 512,512,768,1024 -allocation=4096 -global_buffer=1024 -extension=4096

$MSR START INST1 INST2 RP
get_msrtime ; set time_msr_list = ($time_msr_list $time_msr)

# start the cascade of propagating instances
$MSR START INST2 INST3 PP
get_msrtime ; set time_msr_list = ($time_msr_list $time_msr)
$MSR START INST3 INST4 PP
get_msrtime ; set time_msr_list = ($time_msr_list $time_msr)

set instlist = (INST1 INST2 INST3 INST4 )
set srclist  = (INST1 INST2 INST3       )
set rcvlist  = (      INST2 INST3 INST4 )

# choose a variable and randomized list of instances to run online rollback
set rolllist = `$gtm_exe/mumps -run variable^chooseamong X $instlist`
echo "# Exec online rollback on instanaces"	>> settings.csh
echo "set rolllist = '$rolllist'"		>> settings.csh

# start some imptp updates
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 2
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1

# wait for at least 100 updates or 100 seconds, whichever comes first
set lastseqno=0
$gtm_exe/mumps -run waituntilseqno "jnl" $lastseqno 100 100 >>&! last_seqno.csh
source last_seqno.csh

# can't have conflicting rollbacks, for now, choose just one instance
set rolllist = "INST1" # TODO CHEAT - force INST1 to rollback
$echoline
echo "Starting background online rollbacks"
foreach inst ($rolllist)
	$MSR RUN $inst "set msr_dont_trace;$gtm_tst/$tst/u_inref/bkgrnd_online_rollback.csh 0 250 30 >>& online_rollback_${inst}.out; cat online_rollback_${inst}.out"	>>& online_rollback_${inst}.outx
end

$echoline
echo "Waiting for Online Rollbacks to complete"
foreach inst ($rolllist)
	$MSR RUN $inst "set msr_dont_trace;$gtm_exe/mumps -run waitfororlbk^cascade"
end
$gtm_tst/com/endtp.csh >>&! endtp.out

$echoline
$MSR SYNC ALL_LINKS

# Suppress errors in the reciever log file
foreach inst ($rcvlist)
	@ i++
	set ts = $time_msr_list[$i]
	$MSR RUN $inst "set msr_dont_trace;mv RCVR_${ts}.log{,x};$grep -v MUKILLIP RCVR_${ts}.logx >&! RCVR_${ts}.log"
end

$echoline
$gtm_tst/com/dbcheck_filter.csh -extract
