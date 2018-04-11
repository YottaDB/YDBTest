#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

# Test:
# If there is an active source server running with -instsecondary to a specific instance, one should not be able to
# start another active or passive source server to that instance.

# Layout:
#        |--> INST2
# INST1 -|
#        |--> INST3

$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh . 1
$MSR START INST1 INST2 RP

$echoline
echo "#- Attempt to start a passive source server with -instsecondary=INST2 on INST1:"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -start -passive -log=passive1.log -instsecondary=__RCV_INSTNAME__' >& log1.log
echo "# 	--> We expect a SRCSRVEXISTS error since there is already a source server running to INST2."
$gtm_tst/com/check_error_exist.csh log1.log SRCSRVEXISTS
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out SRCSRVEXISTS > /dev/null
# We might or might not see the "Source server startup failed. See source server log file" message in the
# output of the mupip command, so filter it out
echo "log1.log:"; $grep -v "Source server startup failed. See source server log file" log1.log

$echoline
echo "#- Attempt to start an active source server with -instsecondary=INST2 on INST1"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -start -log=active2.log -secondary=__RCV_HOST__:__RCV_PORTNO__ -instsecondary=__RCV_INSTNAME__' >& log2.log
echo "#		--> We expect a SRCSRVEXISTS error since there is already a source server running to INST2."
$gtm_tst/com/check_error_exist.csh log2.log SRCSRVEXISTS
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out SRCSRVEXISTS > /dev/null
echo "log2.log:"; $grep -v "Source server startup failed. See source server log file" log2.log

$echoline
echo "#- Attempt to start a passive/supplementary source server on INST2"
if (1 == $test_replic_suppl_type) then
	set portno_supp = `$MSR RUN INST2 'set msr_dont_trace ; cat portno_supp'`
	$MSR RUN RCV=INST2 SRC=INST1 "set msr_dont_chk_stat; $MUPIP replic -source -start -log=suppl_source2.log -buf=1 -instsecondary=supp___RCV_INSTNAME__ -secondary=__RCV_HOST__:$portno_supp" >>&! restart_inst2_source.out
else
	$MSR RUN RCV=INST2 SRC=INST1 "set msr_dont_chk_stat; $MUPIP replic -source -start -passive -log=passive_source.log -buf=1 -instsecondary=__SRC_INSTNAME__" >>&!  restart_inst2_source.out
endif
$gtm_tst/com/check_error_exist.csh restart_inst2_source.out YDB-E-SRCSRVEXISTS >&! srcsrvrexists_expected.outx
if(0 == $status) then
	echo "YDB-E-SRCSRVEXISTS seen in restart_source_secondary.out as expected"
else
	echo "YDB-E-SRCSRVEXISTS NOT seen in restart_source_secondary.out. Check the files restart_source_secondary.out and srcsrvrexists_expected.outx"
endif
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out SRCSRVEXISTS > /dev/null

$echoline
echo "#- Attempt to start receiver server again on secondaray"
$MSR RUN RCV=INST2 SRC=INST1 "set msr_dont_chk_stat ; $MUPIP replic -receiv -start -buffsize=$tst_buffsize -listen=__RCV_PORTNO__ -log=secondrecv.log" >&! restart_inst2_receiver.out
$gtm_tst/com/check_error_exist.csh restart_inst2_receiver.out RECVPOOLSETUP YDB-I-TEXT
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out RECVPOOLSETUP  > /dev/null

$echoline
echo "#- Attempt to start an active source server INST1 --> INST3, but with a wrong instance name:"
echo "#wrong instance:"
$MSR STARTRCV INST1 INST3
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -start -log=active3.log -secondary=__RCV_HOST__:__RCV_PORTNO__ -instsecondary='$gtm_test_msr_INSTNAME4 >& log3.log
echo "#  	--> We expect a REPLINSTSECMTCH error."
$gtm_tst/com/wait_for_log.csh -log active3.log -message REPLINSTSECMTCH -duration 100
$gtm_tst/com/check_error_exist.csh active3.log REPLINSTSECMTCH
echo "log3.log:"; $grep -v "Source server startup failed. See source server log file" log3.log

$echoline
echo "#- Attempt to activate a passive source server (with a wrong instance name) INST1 --> INST3:"
echo "#wrong instancename:"
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -start -passive -log=active4.log -instsecondary=WRONGINSTNAME -rootprimary' >& log4.log
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -activate -secondary=__RCV_HOST__:__RCV_PORTNO__ -instsecondary=WRONGINSTNAME' >& log5.log
echo "#  	--> We expect a REPLINSTSECMTCH error in the source server log active4.log"
$gtm_tst/com/wait_for_log.csh -log active4.log -message REPLINSTSECMTCH -duration 100
$gtm_tst/com/check_error_exist.csh active4.log REPLINSTSECMTCH
echo "log4.log:"; $grep -v "Source server startup failed. See source server log file" log4.log

$echoline
echo "#- Attempt to start an active source server INST1 --> INST3, but with an existing connection's instancename"
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -start -log=active6.log -secondary=__RCV_HOST__:__RCV_PORTNO__ -instsecondary='$gtm_test_msr_INSTNAME2 >& log6.log
echo "#  	--> We expect a SRCSRVEXISTS error."
$gtm_tst/com/check_error_exist.csh log6.log SRCSRVEXISTS
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out SRCSRVEXISTS > /dev/null
echo "log6.log:"; $grep -v "Source server startup failed. See source server log file" log6.log

$echoline
$MSR STOPRCV INST1 INST3
$MSR STOP INST1 INST2
# INST4 receiver server was never "officially" started in the test. So, there isn't any mumps.repl file available in INST4. If
# $gtm_custom_errors is set, then the INTEG on INST4 will error out with FTOKERR/ENO2. To avoid this, unsetenv gtm_custom_errors.
unsetenv gtm_custom_errors
# For multihost tests, setting it in the environment is not enough. So, create unsetenv_individual.csh and send it to INST4 which
# gets sourced by remote_getenv.csh.
echo "unsetenv gtm_custom_errors" >&! unsetenv_individual.csh
$MSR RUN SRC=INST1 RCV=INST4 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/unsetenv_individual.csh _REMOTEINFO___RCV_DIR__/'	\
					>&! transfer_unsetenv_individual.out
$gtm_tst/com/dbcheck.csh
#=====================================================================

