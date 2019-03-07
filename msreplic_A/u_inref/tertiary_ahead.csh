#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
$echoline
cat << EOF
Test: The intention is to test what happens when a tertiary instance realizes
it's propagatingprimary did a rollback (to a point before the tertiaries
seqno).
        |--> INST2 --> INST3
INST1 --|
        |--> INST4

        -----------------------------------------------------------------
                INST1         INST2          INST3          INST4
        -----------------------------------------------------------------
Step  1:     (P) 1- 80     (S) 1- 80      (S) 1- 80      (S) 1- 70
Step  2:          X        (S)71-150      (S)            (P)71-150

i.e. INST3 never shutsdown or crashes, and INST2 connects to INST4 when INST1 crashes.
EOF

echo ""
$echoline

$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh . 1
$echoline
echo "#- Step 1:"
$MSR START INST1 INST2
$MSR START INST2 INST3 PP
$MSR START INST1 INST4
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 70'	#(seqnos 1-70)
$MSR SYNC ALL_LINKS
$MSR STOP INST1 INST4
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'	#(seqnos 71-80)
$MSR SYNC ALL_LINKS

$echoline
echo "#- Step 2:"
$MSR CRASH INST1
$MUPIP rundown -region "*" -override	# INST1 will not be used after this point on.
$MSR STOPRCV INST1 INST2 ON
$MSR STOPSRC INST2 INST3 ON		# note receiver is still running on INST3
$MSR STARTSRC INST4 INST2 RP
echo "rollback on INST2..."
$MSR RUN RCV=INST2 SRC=INST4 'set msr_dont_chk_stat; $gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost1.glo "*" >& rollback.tmp; $grep "%YDB-" rollback.tmp'
echo "#  	--> Should rollback 71-80 (i.e. lost1.glo should have 71-80)"
# analyze lost1.glo
$MSR RUN INST2 '$gtm_tst/com/analyze_jnl_extract.csh lost1.glo 71 80'

$MSR STARTRCV INST4 INST2
$MSR STARTSRC INST2 INST3 PP
$MSR RUN INST4 '$gtm_tst/com/simpleinstanceupdate.csh 80'     #(seqnos 71-150)
#	--> At some point INST3 will figure out something is wrong (when INST2 tries to replicate the new 71 to INST3)
#	and error out ("ROLLBACK_FIRST message received. Secondary ahead of primary.").
$MSR RUN INST3 'set msr_dont_trace ; set rcvrlog = `ls RCVR_*.log`; $gtm_tst/com/wait_for_log.csh -log $rcvrlog -message "Received REPL_ROLLBACK_FIRST" -duration 150; $grep "Received REPL_ROLLBACK_FIRST" $rcvrlog' |& sed "s/, Primary.*/ ##FILTERED##/g"
$MSR RUN INST3 'set msr_dont_trace ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'
# the receiver server on INST3 will have died, stop the passive source server as well
# the passive source server to INST2 is still alive, let's shut that down
$MSR RUN RCV=INST3 SRC=INST2 '$MUPIP replic -source -instsecondary=__SRC_INSTNAME__ -shutdown -timeout=0 > SHUT_passive.log'
$MSR REFRESHLINK INST2 INST3
$gtm_tst/com/dbcheck.csh
