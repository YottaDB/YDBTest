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
echo "# [#1310] DBFILERDONLY and MUUPGRDNRDY on a partly upgraded V6 database are issued in full      #"
echo "#-----------------------------------------------------------------------------------------------#"
echo

# Three error message calls reached on a V6 database that MUPIP UPGRADE has converted but MUPIP REORG -UPGRADE has
# not yet finished each declared one more argument than they passed:
#   - Stage 2 : mm_read() issues DBFILERDONLY and TEXT for an MM database with the READ_ONLY flag set when it reads
#     an index block that still needs its block pointers adjusted.
#   - Stage 3 : mm_read() issues the same two messages from a second call when it reads a local bit map that still
#     has a V6 block version.
#   - Stage 4 : mu_reorg_upgrd_dwngrd() issues MUUPGRDNRDY when MUPIP REORG -UPGRADE is interrupted.
# All three are issued through rts_error_csa() or gtm_putmsg_csa(), whose loop then reads one more message id from
# beyond the argument list. In practice that value is not a message id, so the message is followed by a line such
# as "%SYSTEM-E-UNKNOWN, Unknown system error 1777467514" whose number changes from run to run. Each stage
# therefore checks the exact sequence of message lines rather than looking for that line.
#
# Stage 4 interrupts MUPIP REORG -UPGRADE the way Ctrl-C does, by setting mu_ctrlc_occurred, but from gdb at the
# first call to find_gvt_roots(), so that the index block upgrade has started and the interrupt is seen there.

# MM is needed for the READ_ONLY flag, which does not go with before-image journaling or with statistics sharing.
# The database is created with BG by the prior version and switched to MM below.
source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv gtm_test_jnl NON_SETJNL
setenv gtm_test_spanreg 0
setenv gtm_test_use_V6_DBs 0	# This subtest creates its V6 database itself
setenv gtm_test_asyncio 0	# MM cannot be enabled on a database with ASYNCIO
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

echo '# Stage 1 : create a V6 database with a prior V6 version, then run MUPIP UPGRADE on it with this version'
$gtm_tst/com/random_ver.csh -type V6 >&! prior_ver.txt
if (0 != $status) then
	echo "WRONG : no prior V6 version is available - see prior_ver.txt"
	exit 1
endif
set prior_ver = `cat prior_ver.txt`
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
echo '# Command : $gtm_tst/com/dbcreate.csh mumps 1 255 1024 4096   (with the prior version)'
$gtm_tst/com/dbcreate.csh mumps 1 255 1024 4096 >&! dbcreate.out
if (0 == $status) then
	echo "PASS : the V6 database was created"
else
	echo "WRONG : dbcreate.csh failed - see dbcreate.out"
	cat dbcreate.out
endif
echo '# Command : $gtm_exe/mumps -run %XCMD '"'"'for i=1:1:5000 set ^a(i)=$justify(i,200)'"'"'   (with the prior version)'
$gtm_exe/mumps -run %XCMD 'for i=1:1:5000 set ^a(i)=$justify(i,200)' >&! fill.out
if ((0 == $status) && (-z fill.out)) then
	echo "PASS : 5000 nodes were set, so ^a has index blocks"
else
	echo "WRONG : the updates failed - see fill.out"
	cat fill.out
endif
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo '# Command : $GDE exit   (converts the global directory)'
$GDE exit >&! gde_exit.out
echo y >&! yes.txt
echo '# Command : $MUPIP upgrade -region DEFAULT'
$MUPIP upgrade -region DEFAULT < yes.txt >&! upgrade.out
$grep -q 'MUPIP MASTERMAP UPGRADE of .* completed' upgrade.out
if (0 == $status) then
	echo "PASS : MUPIP UPGRADE completed, leaving the index blocks and local bit maps to MUPIP REORG -UPGRADE"
else
	echo "WRONG : MUPIP UPGRADE did not complete - see upgrade.out"
	cat upgrade.out
endif
echo '# Command : $MUPIP set -access_method=MM -region DEFAULT'
$MUPIP set -access_method=MM -region DEFAULT >&! set_mm.out
set stat1 = $status
echo '# Command : $MUPIP set -nostats -region DEFAULT'
$MUPIP set -nostats -region DEFAULT >&! set_nostats.out
set stat2 = $status
echo '# Command : $MUPIP set -read_only -region DEFAULT'
$MUPIP set -read_only -region DEFAULT >&! set_read_only.out
set stat3 = $status
if ((0 == $stat1) && (0 == $stat2) && (0 == $stat3)) then
	echo "PASS : the database is now MM with the READ_ONLY flag set"
else
	echo "WRONG : could not make the database MM and READ_ONLY - see set_mm.out, set_nostats.out and set_read_only.out"
	cat set_mm.out set_nostats.out set_read_only.out
endif
echo

echo '# Stage 2 : reading a global goes through an index block that needs its pointers adjusted'
echo '# Command : $gtm_exe/mumps -run %XCMD '"'"'write $data(^a(4000)),!'"'"
$gtm_exe/mumps -run %XCMD 'write $data(^a(4000)),!' >&! read.out
$grep '^%' read.out >&! read_msgs.logx
$tst_awk '(1 == NR) && /^%YDB-E-DBFILERDONLY, / {d++} (2 == NR) && /^%YDB-I-TEXT, read-only region needs to be read write and upgraded$/ {t++} END {exit !((2 == NR) && d && t)}' read_msgs.logx
if (0 == $status) then
	echo "PASS : the process reported DBFILERDONLY followed by TEXT, and no other message"
else
	echo "WRONG : expected exactly DBFILERDONLY then TEXT - see read.out"
	cat read_msgs.logx
endif
$gtm_tst/com/check_error_exist.csh read.out DBFILERDONLY >&! check_read.logx
echo

echo '# Stage 3 : DSE reads local bit map 0, which still has a V6 block version'
echo '# Command : $DSE dump -block=0'
$DSE dump -block=0 < /dev/null >&! dse_dump.out
$grep '^%' dse_dump.out >&! dse_msgs.logx
$tst_awk '(1 == NR) && /^%YDB-E-DBFILERDONLY, / {d++} (2 == NR) && /^%YDB-I-TEXT, read-only region needs to be read write and upgraded$/ {t++} END {exit !((2 == NR) && d && t)}' dse_msgs.logx
if (0 == $status) then
	echo "PASS : DSE reported DBFILERDONLY followed by TEXT, and no other message"
else
	echo "WRONG : expected exactly DBFILERDONLY then TEXT - see dse_dump.out"
	cat dse_msgs.logx
endif
$gtm_tst/com/check_error_exist.csh dse_dump.out DBFILERDONLY >&! check_dse.logx
echo

echo '# Stage 4 : interrupt MUPIP REORG -UPGRADE once its index block upgrade has started'
echo '# Command : $MUPIP set -noread_only -region DEFAULT'
$MUPIP set -noread_only -region DEFAULT >&! set_noread_only.out
if (0 == $status) then
	echo "PASS : the READ_ONLY flag is cleared"
else
	echo "WRONG : could not clear the READ_ONLY flag - see set_noread_only.out"
	cat set_noread_only.out
endif
cat > gdb_reorg.cmd << EOF
set breakpoint pending on
set pagination off
break find_gvt_roots
run reorg -upgrade -region DEFAULT < yes.txt
set var mu_ctrlc_occurred = 1
continue
EOF
echo '# Command : gdb -batch -x gdb_reorg.cmd $MUPIP   (gdb sets mu_ctrlc_occurred at the first find_gvt_roots() call)'
gdb -batch -x gdb_reorg.cmd $gtm_exe/mupip < /dev/null >&! reorg_gdb.out
$grep '^%' reorg_gdb.out >&! reorg_msgs.logx
$tst_awk '(1 == NR) && /^%YDB-E-MUUPGRDNRDY, / {m++} (2 == NR) && /^%YDB-I-REORGCTRLY, / {r++} (3 == NR) && /^%YDB-E-MUNOFINISH, / {f++} END {exit !((3 == NR) && m && r && f)}' reorg_msgs.logx
if (0 == $status) then
	echo "PASS : MUPIP REORG -UPGRADE reported MUUPGRDNRDY, then REORGCTRLY and MUNOFINISH, and no other message"
else
	echo "WRONG : expected exactly MUUPGRDNRDY, REORGCTRLY, MUNOFINISH - see reorg_gdb.out"
	cat reorg_msgs.logx
endif
$gtm_tst/com/check_error_exist.csh reorg_gdb.out MUUPGRDNRDY MUNOFINISH >&! check_reorg.logx
echo

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if (0 == $status) then
	echo "PASS : dbcheck.csh found no integrity errors"
else
	echo "WRONG : dbcheck.csh failed - see dbcheck.out"
	cat dbcheck.out
endif
