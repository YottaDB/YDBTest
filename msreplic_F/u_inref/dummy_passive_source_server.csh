#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# =================================================================================================
$echoline
echo "INST1 --> INST2 --> INST3"
$echoline
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh mumps 1
$MSR STARTSRC INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 100'
set suppl_arg = ""
if (0 != $test_replic_suppl_type) set suppl_arg = "-supplementary"
$MSR RUN RCV=INST2 '$MUPIP replic -inst -name=__RCV_INSTNAME__ '$suppl_arg $gtm_test_qdbrundown_parms';$MUPIP set -replic=on -reg "*" >& jnl_on_INST2.tmp; cat jnl_on_INST2.tmp' >&! jnl_on_INST2.out
$grep -vE "YDB-I-JNLCREATE|Executing MULTISITE_REPLIC" jnl_on_INST2.out
#
echo "#- Start replication on INST2, with a dummy passive source server to INST3 (if INST1 will not be a secondary)"
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/helper_start_source_passive_buf_pp.csh DUMMY'
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/$tst/u_inref/helper_start_receiver_server.csh __RCV_PORTNO__'
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 50'
$MSR SYNC INST1 INST2
#
echo "#- Crash INST1 and make INST2 primary, replicating to INST3:"
$MSR CRASH INST1
echo "#- since we will not use INST1 again, run it down"
$MUPIP rundown -reg '*' -override
$MSR RUN INST2 '$MUPIP replic -receiver -shutdown -timeout=0 >&! SHUT_INST2.out'
$MSR RUN SRC=INST2 RCV=INST3 '$gtm_tst/$tst/u_inref/helper_start_source_passive_pp.csh __RCV_INSTNAME__'
$MSR RUN SRC=INST2 '$MUPIP replic -source -shutdown -instsecondary=DUMMY -timeout=0 >& dummy_INST2.tmp; cat dummy_INST2.tmp'
$MSR STARTRCV INST2 INST3
get_msrtime
$MSR ACTIVATE INST2 INST3 RP
# Make sure passive->active activation is complete before proceeding with updates and dbcheck
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log RCVR_'${time_msr}'.log -message "New History Content"'
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 50'
$gtm_tst/com/dbcheck.csh -extract INST2 INST3
#
