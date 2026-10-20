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

echo "#-----------------------------------------------------------------------------------------------#"
echo "# [#1310] The receiver server reports REPLERR when it cannot fork the update process            #"
echo "#-----------------------------------------------------------------------------------------------#"
echo

# The receiver server tries to fork the update process up to 16 times, a second apart, and then logs REPLERR with
# the text "Too many failed attempts to fork Update Process. Aborting..." and exits. That sgtm_putmsg() call passed
# no FAO count, so the consumption loop took the text length as the FAO count, and the length itself came from
# SIZEOF() of a pointer. The text was taken from beyond the argument list; on a Debug build the receiver server
# failed an assert and dumped a core instead of logging REPLERR.
#
# ydb1310_forkfail.c is LD_PRELOADed into the receiver server to make every fork() it makes fail with EAGAIN.
# The receiver server log is named rcv.logx because every failed attempt logs UPDPROC and ENO11 errors there,
# which are expected; the stages below check that log for what they need.

setenv gtm_test_spanreg 0
setenv gtm_test_jnl NON_SETJNL
unsetenv gtm_db_counter_sem_incr	# the instance file is created without -qdbrundown
setenv gtm_repl_instance mumps.repl

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo '# Stage 1 : make this instance a secondary with a passive source server, and build the fork library'
echo '# Command : $MUPIP replicate -instance_create -name=INSTB'
$MUPIP replicate -instance_create -name=INSTB >&! instcreate.out
set stat1 = $status
echo '# Command : $MUPIP set -replication=on -region DEFAULT'
$MUPIP set -replication=on -region DEFAULT >&! setrepl.out
set stat2 = $status
echo '# Command : $MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src.log'
$MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src.log >&! srcstart.out
set stat3 = $status
if ((0 == $stat1) && (0 == $stat2) && (0 == $stat3)) then
	echo "PASS : the instance file, replication and the passive source server are in place"
else
	echo "WRONG : the replication setup failed - see instcreate.out, setrepl.out and srcstart.out"
	cat instcreate.out setrepl.out srcstart.out
endif
echo '# Command : compile and link ydb1310_forkfail.c into libydb1310_forkfail'
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/ydb1310_forkfail.c -o ydb1310_forkfail.o >&! forkfail_cc.out
$gt_ld_shl_linker ${gt_ld_option_output}libydb1310_forkfail${gt_ld_shl_suffix} $gt_ld_shl_options ydb1310_forkfail.o $gt_ld_sysrtns -ldl >&! forkfail_ld.out
if (-e libydb1310_forkfail${gt_ld_shl_suffix}) then
	echo "PASS : libydb1310_forkfail was built"
else
	echo "WRONG : libydb1310_forkfail was not built - see forkfail_cc.out and forkfail_ld.out"
	cat forkfail_cc.out forkfail_ld.out
endif
echo

echo '# Stage 2 : start a receiver server that cannot fork the update process'
source $gtm_tst/com/portno_acquire.csh >>& portno.out
echo '# Command : env LD_PRELOAD=./libydb1310_forkfail'${gt_ld_shl_suffix}' $MUPIP replicate -receiver -start -listenport=<port> -log=rcv.logx -buffsize=1048576'
env LD_PRELOAD=./libydb1310_forkfail${gt_ld_shl_suffix} $MUPIP replicate -receiver -start -listenport=$portno -log=rcv.logx -buffsize=1048576 >&! rcvstart.out
# The receiver server gives up after 16 attempts a second apart. Wait (at most 120 seconds) for it to exit.
set i = 0
while ($i < 120)
	$grep -q 'Receiver server exiting' rcv.logx >& /dev/null
	if (0 == $status) break
	sleep 1
	@ i = $i + 1
end
$grep -q 'Receiver server exiting' rcv.logx
if (0 == $status) then
	echo "PASS : the receiver server exited"
else
	echo "WRONG : the receiver server did not exit within 120 seconds - see rcv.logx"
endif
$grep -q '%YDB-I-TEXT, Could not fork update process' rcv.logx
if (0 == $status) then
	echo "PASS : the receiver server logged that it could not fork the update process"
else
	echo "WRONG : no 'Could not fork update process' in rcv.logx"
endif
$grep -q ' : %YDB-E-REPLERR, Too many failed attempts to fork Update Process. Aborting...$' rcv.logx
if (0 == $status) then
	echo "PASS : the receiver server logged REPLERR with its complete text"
else
	echo "WRONG : no complete REPLERR in rcv.logx - its last lines follow"
	tail -n 3 rcv.logx
endif
ls -1 core* >& /dev/null
if (0 != $status) then
	echo "PASS : no core file"
else
	echo "WRONG : the receiver server dumped a core"
	foreach corename (core*)
		mv $corename hidden_unexpected_core_$corename
	end
endif
echo

echo '# Stage 3 : clean up'
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop.out
if (0 == $status) then
	echo "PASS : the passive source server shut down"
else
	echo "WRONG : could not shut down the passive source server - see srcstop.out"
	cat srcstop.out
endif
$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if (0 == $status) then
	echo "PASS : dbcheck.csh found no integrity errors"
else
	echo "WRONG : dbcheck.csh failed - see dbcheck.out"
	cat dbcheck.out
endif
