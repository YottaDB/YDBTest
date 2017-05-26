#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test that if -updateresync is specified and the receiver max-reg-seqno is GREATER than source max-reg-seqno,
# REPL_ROLLBACK_FIRST error is issued.

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

BEGIN "Create database with journaling enabled"
$MULTISITE_REPLIC_PREPARE 2
setenv gtm_test_jnl "SETJNL"				# Force journaling
source $gtm_tst/com/gtm_test_setbeforeimage.csh		# Force before image journaling
$gtm_tst/com/dbcreate.csh mumps
END

set supplarg2 = ""
if ((1 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
	set supplarg2 = "-supplementary"
endif

BEGIN "Create instance file on source and receiver servers"
# START INST1 INST2 creates mumps.repl and the same mumps.repl should be used for -updateresync below. If mumps.repl is created now at INST1
# receiver will fail with GTM-E-UPDSYNCINSTFILE hence do not create replication instance file on INST1. Create only in INST2
$MSR RUN INST2 "set msr_dont_trace ; $MUPIP replic -instance_create -name=INSTANCE2 $supplarg2 $gtm_test_qdbrundown_parms"
END

BEGIN "On receiver server, take a copy of instance file. On source, take a copy of database related files"
$MSR RUN INST2 "mv mumps.repl mumps.repl.orig"
$MSR RUN INST1 "mkdir old; cp mumps.* old "

END

BEGIN "Start source and receiver servers and make some updates on source server"
$MSR START INST1 INST2 RP
$MSR RUN INST1 '$MUPIP backup -replinstance=mumps.repl.orig' >&! repl_backup.out
$GTM << GTM_EOF
        for i=1:1:10 set ^x(i)=i
	write ^x(i)
GTM_EOF
END

BEGIN "Sync source with receiver server. Stop source server and take copy of database related files"
$MSR SYNC ALL_LINKS
$MSR RUN INST1 "$MUPIP replic -source -shut -time=0 >>&! source_shut.out"
$MSR RUN INST1 "mkdir new; cp mumps.* new; cp old/* . ; cp mumps.repl.orig mumps.repl"
$MSR RUN SRC=INST1 RCV=INST2 "cp new/mumps.repl __RCV_DIR__/pri_mumps.repl"
END


BEGIN "On sec, stop receiver and passive source server. Take a copy of mumps.repl and replace it with mumps.repl.orig"
$MSR RUN INST2 "$MUPIP replic -receiv -shut -time=0 >>&! rcvr_shut.out"
$MSR RUN INST2 "$MUPIP replic -source -shut -time=0 >>&! rcvr_shut.out"
$MSR RUN INST2 "mv mumps.repl mumps.repl.new; cp mumps.repl.orig mumps.repl"
END

BEGIN "Restart source and receiver servers"
if ((0 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
	$MSR RUN RCV=INST2 "$MUPIP replic -source -start -passive -log=passive_source.log -buf=1 -instsecondary=INSTANCE1" >>&! restart_inst2_source.out
	set updok = ""
else
	set portno_supp = `$MSR RUN INST2 'set msr_dont_trace ; cat portno_supp'`
	$MSR RUN RCV=INST2 "$MUPIP replic -source -start -log=suppl_source.log -buf=1 -instsecondary=supp_INSTANCE2 -secondary=__RCV_HOST__:$portno_supp" >>&! restart_inst2_source.out
	set updok = " -updok"
endif
$MSR RUN RCV=INST2 "$MUPIP replic -receiv -start -listen=__RCV_PORTNO__ -log=RCVR_restart.log -buf=$tst_buffsize -updateresync=pri_mumps.repl -initialize"
$MSR RUN INST1 '$MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log'
$MSR RUN SRC=INST1 RCV=INST2 "$MUPIP replic -source -start -secondary=__RCV_HOST__:__RCV_PORTNO__ -log=source.log -buf=$tst_buffsize -instsecondary=__RCV_INSTNAME__ $updok" >>&! restart_source.out
END

BEGIN "Look for REPL_ROLLBACK_FIRST message in receiver log"
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_restart.log -message "Received REPL_ROLLBACK_FIRST message" -duration 120 -waitcreation -grep'
$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'
END

$MSR RUN INST1 "$MUPIP replic -source -shut -time=0 >>& source_shut2.out"
$MSR RUN INST2 "$MUPIP replic -source -shut -time=0 >>& rcvr_shut2.out"
$MSR RUN INST2 'set msr_dont_trace ; source $gtm_tst/com/portno_release.csh'
$gtm_tst/com/dbcheck.csh -noshut
