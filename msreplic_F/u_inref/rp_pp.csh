#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# =================================================================================================
$echoline
echo "# INST1 --> INST2 --> INST3"
$echoline
$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh mumps 1
echo "# --> Test PRIMARYNOTROOT when there is already a passive source server running on INST2, so it cannot be a rp"
$MSR STARTRCV INST1 INST2
setenv msr_dont_chk_stat
$MSR STARTSRC INST2 INST3 RP
get_msrtime

$MSR RUN INST2 "$msr_err_chk START_$time_msr.out PRIMARYNOTROOT REPLINSTSECNONE"
# port reservation file created by the starting up script should be cleaned up.(startup failed-shutdown isn't called)
$MSR RUN INST3 'set msr_dont_trace ; setenv rem_port `cat portno` ; rm /tmp/test_${rem_port}.txt'

echo "# --> Test PRIMARYNOTROOT when there is already a propagating source server running on INST1,"
echo " so it cannot be a rootprimary (unless that is activated as rootprimary)"
$MSR STARTSRC INST1 INST2 PP
get_msrtime
set time_msr_INST1_INST2=$time_msr
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log SRC_'$time_msr_INST1_INST2'.log  -message "now in ACTIVE mode"'
setenv msr_dont_chk_stat
$MSR STARTSRC INST1 INST4 RP
get_msrtime
$msr_err_chk START_$time_msr.out PRIMARYNOTROOT REPLINSTSECNONE
# port reservation file created by the starting up script should be cleaned up
$MSR RUN INST4 'set msr_dont_trace ; setenv rem_port `cat portno` ; rm /tmp/test_${rem_port}.txt'

$MSR ACTIVATE INST1 INST2 RP
echo " --> Test PRIMARYISROOT when there is already an active source server running on INST1"
setenv msr_dont_chk_stat
$MSR STARTSRC INST1 INST3 PP
get_msrtime
$msr_err_chk START_$time_msr.out PRIMARYISROOT REPLINSTSECNONE
# port reservation file created by the starting up script should be cleaned up
$MSR RUN INST3 'set msr_dont_trace ; setenv rem_port `cat portno` ; rm /tmp/test_${rem_port}.txt'

$MSR START INST2 INST3 PP
get_msrtime
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log SRC_'$time_msr'.log  -message "now in ACTIVE mode"'
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 20'
$MSR STOP INST1
$MSR STOPRCV INST1 INST2
$MSR RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -deactivate -instsecondary=__RCV_INSTNAME__ -propagateprimary >& INST3_replic2.tmp; cat INST3_replic2.tmp'
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log SRC_'$time_msr'.log  -message "from ACTIVE to PASSIVE"'
$MSR RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -activate -rootprimary -instsecondary=__RCV_INSTNAME__ -secondary=__RCV_HOST__:__RCV_PORTNO__ >& INST3_src.tmp; cat INST3_src.tmp'
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log SRC_'$time_msr'.log  -message "now in ACTIVE mode" -count 2'
$MSR STOPSRC INST2 INST3
$MSR STARTSRC INST2 INST3 RP
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 10'
# INST4 receiver server was never "officially" started in the test. So, there isn't any mumps.repl file available in INST4. If
# $gtm_custom_errors is set, then the INTEG on INST4 will error out with FTOKERR/ENO2. To avoid this, unsetenv gtm_custom_errors.
unsetenv gtm_custom_errors
# For multihost tests, setting it in the environment is not enough. So, create unsetenv_individual.csh and send it to INST4 which
# gets sourced by remote_getenv.csh.
echo "unsetenv gtm_custom_errors" >&! unsetenv_individual.csh
$MSR RUN SRC=INST1 RCV=INST4 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/unsetenv_individual.csh _REMOTEINFO___RCV_DIR__/'	\
					>&! transfer_unsetenv_individual.out
$gtm_tst/com/dbcheck.csh -extract INST2 INST3
#

