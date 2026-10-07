#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#----------------------------------------------------------------------------------------------------#"
echo "# A MUPIP JOURNAL -ROLLBACK that exits with an error must not leave a journal file whose header has   #"
echo "# a start sequence number greater than its end sequence number                                       #"
echo "#----------------------------------------------------------------------------------------------------#"
echo

# mur_open_files() sets both csd->repl_state and the process-private csa->repl_state to repl_closed for the duration
# of a ROLLBACK, saving the real value in csd->intrpt_recov_repl_state, and mur_close_files() restores it. On success
# it restores both; on the error path it restored only csd->repl_state, so a ROLLBACK that exited with an error kept
# csa->repl_state as repl_closed.
#
# The same process then runs gds_rundown() on its way out. When it is the last writer and the journal file is still
# open in shared memory, gds_rundown() calls jnl_file_close(), which writes an EOF record whose sequence number is
# csa->hdr->reg_seqno only "if (REPL_ALLOWED(csa))" and 0 otherwise, and then stores that into the journal file
# header as end_seqno along with crash = FALSE. With csa->repl_state at repl_closed, REPL_ALLOWED is FALSE, so the
# header ends up with a non-zero start_seqno, an end_seqno of 0, and no crash flag to warn anyone.
#
# Every later ROLLBACK that has to read that file then fails in mur_fopen() with BEGSEQGTENDSEQ, and the journal
# file can never be rolled back again. In the field this arises when all YottaDB processes are killed without
# rundown, for example by the OOM killer, and a recovery script running an ONLINE FETCHRESYNC rollback is then
# restarted repeatedly while the primary instance is unreachable.
#
# Three conditions have to hold together, and -ONLINE supplies all three:
#
#   1. csa->repl_state must be repl_closed when the journal file is closed. This holds for any ROLLBACK that exits
#      with an error, ONLINE or not, since both take the same error path in mur_close_files().
#   2. The process must be the last writer at rundown, or gds_rundown() passes clean = FALSE to jnl_file_close()
#      and the whole EOF-and-header block is skipped. Stage 2 leaves the shared memory orphaned with no live
#      writer, so the rollback is the last writer.
#   3. jb->rsrv_freeaddr must differ from jb->end_of_data_at_open, or jnl_file_close() sets write_eof to FALSE and
#      leaves the header alone. An ONLINE rollback ATTACHES to the existing shared memory, where end_of_data_at_open
#      was set before the updates of stage 1; a standalone rollback instead runs that shared memory down and creates
#      its own, where the two are equal, and then writes nothing. This is the condition that decides it.
#
# The trigger is WBTEST_REPL_INIT_ERR2 (160), which forces the listen() in gtmrecv_comm_init() to fail, so
# gtmrecv_fetchresync() returns an error and mupip_recover() takes mupip_exit(ERR_MUNOACTION). In practice this
# path is reached more often by a FETCHRESYNC connection timeout, where gtmrecv_fetchresync waits 60 seconds for
# the primary's source server and then issues REPLCOMM; both reach the same mupip_exit(ERR_MUNOACTION). 160 is
# used rather than 159 (the BIND hook) because 160 sets save_errno to 98 before issuing the message, so the
# SYSTEM-E-ENO98 text is deterministic, where 159 reports whatever errno happened to be set.
#
# WBTEST_KILL_ROLLBACK (100) looks like the obvious hook and is not: it SIGKILLs, so gds_rundown never runs and no
# EOF is written. The damage needs an ORDERLY exit after an error.
#
# Note the database file header keeps Replication State ON throughout, because the error path does restore
# csd->repl_state. That is why the symptom is BEGSEQGTENDSEQ rather than the REPLNOTON that mur_fopen()
# raises for a journal file whose own header says replication was off.
#
# Stages 4 and 5 assert the FIXED behaviour, so this subtest fails on a build carrying the defect: stage 4 reports
# WRONG because the header holds an end_seqno of 0, and stage 5 reports WRONG because the next rollback gets
# BEGSEQGTENDSEQ. On a fixed build both print PASS.
#
# Sequence numbers are deliberately not printed, only compared. The values depend on how many updates the test
# framework itself does, so printing them would make the reference file unreproducible.

# Before-image journaling requires BG, so do not let the test system pick MM
source $gtm_tst/com/gtm_test_setbgaccess.csh
# This subtest wants a single region and a known journal state, so keep the test system from randomly
# spanning regions or turning journaling on behind us. Journaling is turned on explicitly below.
setenv gtm_test_spanreg 0
setenv gtm_test_jnl NON_SETJNL
# The instance file below is created without -qdbrundown, so a large random counter semaphore increment would
# overflow the instance file ftok semaphore (ERANGE) when the source server starts. And this subtest deliberately
# orphans shared memory, so it must not run with the ftok counter halted either.
unsetenv gtm_db_counter_sem_incr

setenv gtm_repl_instance mumps.repl
set instname = "INSTRLBK"
set secname  = "INSTRLBKSEC"

$gtm_tst/com/dbcreate.csh mumps

echo '# Stage 1 : build a replicated instance with before-image journaling and advance the journal sequence number'
echo '# Command : $MUPIP replicate -instance_create -name='$instname
$MUPIP replicate -instance_create -name=$instname >&! instcreate.log
if (0 == $status) then
	echo "PASS : the replication instance file was created"
else
	echo "WRONG : could not create the replication instance file - see instcreate.log"
	cat instcreate.log
endif

echo '# Command : $MUPIP set -replication=on -journal=enable,on,before -region "*"'
$MUPIP set -replication=on -journal=enable,on,before -region "*" >&! setrepl.log
if (0 == $status) then
	echo "PASS : replication and before-image journaling are on"
else
	echo "WRONG : could not turn on replication and journaling - see setrepl.log"
	cat setrepl.log
endif

source $gtm_tst/com/portno_acquire.csh >>& portno.out

# -updok makes this instance update-enabled (a root primary). Without it the updates below get
# SCNDDBNOUPD, because an instance whose source server was never started -updok is a secondary.
echo '# Command : $MUPIP replicate -source -start -passive -updok -instsecondary='$secname' -log=src.log'
$MUPIP replicate -source -start -passive -updok -instsecondary=$secname -log=src.log >&! srcstart.log
if (0 == $status) then
	echo "PASS : the passive source server started, so the journal pool exists"
else
	echo "WRONG : the passive source server did not start - see srcstart.log and src.log"
	cat srcstart.log
endif

echo '# Command : $gtm_dist/mumps -run %XCMD '"'"'for i=1:1:100 set ^a(i)=i'"'"
$gtm_dist/mumps -run %XCMD 'for i=1:1:100 set ^a(i)=i' >&! update.log
if (0 == $status) then
	echo "PASS : 100 updates were applied"
else
	echo "WRONG : the updates failed - see update.log"
	cat update.log
endif

echo '# Command : $MUPIP journal -show=header -forward -noverify mumps.mjl'
$MUPIP journal -show=header -forward -noverify mumps.mjl >&! jnlhdr_before.logx
set startseq = `$tst_awk '/Start Region Sequence Number/ {print $5}' jnlhdr_before.logx`
set endseq   = `$tst_awk '/End Region Sequence Number/ {print $5}' jnlhdr_before.logx`
if (("" != "$startseq") && ("" != "$endseq") && (0 < $startseq) && ($endseq >= $startseq)) then
	echo "PASS : the journal file header starts with a non-zero start seqno and an end seqno at or above it"
else
	echo "WRONG : baseline header is not as expected - start seqno [$startseq] end seqno [$endseq]"
	cat jnlhdr_before.logx
endif
echo

echo '# Stage 2 : crash the instance, so the shared memory is left orphaned with the journal file open in it'
echo '#           and freeaddr advanced past the point at which the file was opened (condition 3)'
set srcpid = `$gtm_tst/com/get_pid.csh passive $secname`
echo '# Command : $gtm_tst/com/kill9.csh <passive source server pid>'
$gtm_tst/com/kill9.csh $srcpid >&! kill9.log
if (0 == $status) then
	echo "PASS : the source server was killed with SIGKILL"
else
	echo "WRONG : could not kill the source server - see kill9.log"
	cat kill9.log
endif

echo '# Command : $MUPIP journal -show=header -forward -noverify mumps.mjl'
$MUPIP journal -show=header -forward -noverify mumps.mjl >&! jnlhdr_crashed.logx
set crashflag = `$tst_awk '/^ Crash/ {print $2}' jnlhdr_crashed.logx`
if ("TRUE" == "$crashflag") then
	echo "PASS : the journal file is marked as crashed, so nothing has closed it cleanly yet"
else
	echo "WRONG : the journal file Crash flag is [$crashflag], expected TRUE"
	cat jnlhdr_crashed.logx
endif
echo

echo '# Stage 3 : run a ROLLBACK that exits with an error after mur_open_files has set repl_state to repl_closed.'
echo '#           WBTEST_REPL_INIT_ERR2 (160) makes the listen() in gtmrecv_comm_init fail, so FETCHRESYNC errors out.'
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 160
setenv gtm_white_box_test_case_count 1
echo '# Command : $MUPIP journal -rollback -backward -online -fetchresync=<portno> -losttrans=lost1.glo "*"'
$MUPIP journal -rollback -backward -online -fetchresync=$portno -losttrans=lost1.glo "*" >&! rollback_fail.out
set rbstat = $status
# White box testing is enabled by the mere PRESENCE of the enable variable, so all three must be unsetenv'd
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count
if (0 != $rbstat) then
	echo "PASS : the rollback exited with an error, as this stage intends"
else
	echo "WRONG : the rollback unexpectedly succeeded, so the rest of this subtest proves nothing"
	cat rollback_fail.out
endif
$gtm_tst/com/check_error_exist.csh rollback_fail.out REPLCOMM MUNOACTION ENO98 ORLBKTERMNTD >&! check_rollback_fail.logx
if (0 == $status) then
	echo "PASS : the rollback failed with the expected REPLCOMM, MUNOACTION, ENO98 and ORLBKTERMNTD messages"
else
	echo "WRONG : the expected REPLCOMM, MUNOACTION and ENO98 messages were not found - see check_rollback_fail.logx"
	cat check_rollback_fail.logx
endif
echo

echo '# Stage 4 : no journal file may have start seqno > end seqno'
echo '# Command : $MUPIP journal -show=header -forward -noverify <each journal file generation>'
set nbad = 0
foreach jnlfile (*.mjl*)
	$MUPIP journal -show=header -forward -noverify $jnlfile >&! jnlhdr_after.logx
	set fstart = `$tst_awk '/Start Region Sequence Number/ {print $5}' jnlhdr_after.logx`
	set fend   = `$tst_awk '/End Region Sequence Number/ {print $5}' jnlhdr_after.logx`
	if (("" != "$fstart") && ("" != "$fend")) then
		if ($fstart > $fend) then
			@ nbad = $nbad + 1
			echo "# offending journal file header follows" >>! jnlhdr_bad.logx
			cat jnlhdr_after.logx			  >>! jnlhdr_bad.logx
		endif
	endif
end
if (0 == $nbad) then
	echo "PASS : no journal file has a start sequence number greater than its end sequence number"
else
	echo "WRONG : $nbad journal file generation(s) have a start sequence number greater than the end"
	echo "        sequence number - see jnlhdr_bad.logx"
endif
echo

echo '# Stage 5 : and a plain backward rollback must still be able to recover the instance'
echo '# Command : $MUPIP journal -rollback -backward -losttrans=lost2.glo "*"'
$MUPIP journal -rollback -backward -losttrans=lost2.glo "*" >&! rollback2.out
set rb2stat = $status
if (0 == $rb2stat) then
	echo "PASS : the instance was rolled back successfully"
else
	echo "WRONG : the rollback failed. Error mnemonics it reported :"
	$grep -o 'YDB-[EF]-[A-Z0-9]*' rollback2.out | $tst_awk -F- '{print "        "$3}' | sort -u
endif
echo

echo "# Done"

$gtm_tst/com/dbcheck.csh
