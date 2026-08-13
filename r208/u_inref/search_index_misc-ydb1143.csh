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

echo "#--------------------------------------------------------------------------------------------------#"
echo "# [#1143] Three claims the other subtests do not reach : standalone access, REORG, statsDB         #"
echo "#--------------------------------------------------------------------------------------------------#"
echo

source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv gtm_test_use_V6_DBs 0
setenv test_reorg NON_REORG

# Checks rather than displays : every call names the pair the stage expects. See the comment in
# search_index_check-ydb1143.csh for why a displayed value is not a checked one.
alias check_idx '$gtm_tst/$tst/u_inref/search_index_check-ydb1143.csh DEFAULT'
# MUPIP SET names the database file in its confirmation and that path varies by run, so it is
# normalized here.
#
# Stage 1 below deliberately holds the database open in a SECOND process while MUPIP SET runs, which
# is the whole point of testing that MUPIP SET demands standalone access. That is also what makes the
# counter semaphore overflow when the framework sets gtm_db_counter_sem_incr high. Every process
# attaching bumps that counter by the value of the variable, and the system ceiling is the semaphore
# maximum, 32767 on the test systems, so TWO processes at 16384 sum to 32768 and overflow by one. One
# process alone at 16384 does not, which is why the other three search index subtests carry no cap :
# none of them ever has two processes attached at the same time, and all three were measured clean at
# 16384 without one.
#
# Reaching that overflow is exactly what the variable is for - see ydb_db_counter_sem_incr in
# gbldefs.c, "Higher values exercise the ERANGE code better when the ftok/access/jnlpool counter
# semaphore overflows". Once it overflows an IPC is left behind, the database looks abnormally shut
# down, and the MUPIP SET is refused outright with MUUSERECOV, doing nothing at all. Measured on this
# subtest : 3 runs in 8 failed at 16384, 0 in 8 with the variable unset, 10 in 10 clean once capped.
#
# Capping at 8192 is the fix rather than filtering the messages, since two processes at 8192 sum to
# 16384 and stay well inside the ceiling. The SEMREMOVED and MUUSERECOV messages are real, and a
# MUPIP SET that silently did nothing has to keep failing this subtest.
if ($?gtm_db_counter_sem_incr) then
	if (8192 < $gtm_db_counter_sem_incr) then
		setenv gtm_db_counter_sem_incr 8192
	endif
endif
alias strip_path 'sed "s;Database file .* now has;Database file now has;"'

$gtm_tst/com/dbcreate.csh mumps 1 250 1024 4096

echo "## 1. MUPIP SET of the size needs STANDALONE access"
echo "# The size decides how large the shared memory segment is, so it cannot change under processes"
echo "# already attached. With another process holding the database open, the command must be refused"
echo "# and the file header must be left exactly as it was."
echo "# The size asked for is DIFFERENT from the one the database holds, checked just below as 1024,"
echo "# and doubling it doubles the memory the segment needs. So a refusal here cannot be MUPIP"
echo "# declining to do nothing : it is MUPIP declining a change it cannot make under an attached"
echo "# process."
check_idx 1024 1024
$gtm_tst/$tst/u_inref/search_index_hold-ydb1143.csh 15 >& hold.out
sleep 5
echo "# mupip set -search_index_size=2048 -region DEFAULT, against the 1024 shown above"
echo "# mupip set -search_index_size=2048 -region DEFAULT >& standalone.out"
$ydb_dist/mupip set -search_index_size=2048 -region DEFAULT >& standalone.out
echo -n "# MUPIP SET refused it, saying the file is open by another process : "
$grep -c "already open by another process" standalone.out
$gtm_tst/com/check_error_exist.csh standalone.out WCWRNNOTCHG
echo "# and the field is unchanged"
check_idx 1024 1024
# WAIT for the holder rather than sleeping a guessed interval. A fixed sleep raced it on a loaded
# machine and left the database abnormally shut down, which surfaced as MUUSERECOV in a later stage.
set waited = 0
while (`ps -u $user -o args= | grep -c "[s]et ^hold"` > 0)
	sleep 1
	@ waited = $waited + 1
	if ($waited > 60) then
		echo "TEST-E-FAIL : the holder process did not exit"
		break
	endif
end
echo

echo "## 2. MUPIP REORG runs against a database with search indexes enabled"
echo "# REORG does not use search indexes : it rewrites the very blocks it walks, so an index it built"
echo "# would be invalidated by its own next update before the samples could be reused. What is checked"
echo "# here is that REORG completes and leaves the data intact with the feature on."
echo "#"
echo "# The stage first proves the feature really IS on for an ordinary process, by peeking this"
echo "# process own sgmnt_addrs.search_idx_base, which is the field a search tests. Without that,"
echo "# matching answers would prove nothing : a database with the feature off matches them too."
echo "#"
echo "# REORG own exclusion is still NOT tested, and cannot be from outside : mupip_reorg clears"
echo "# that field in REORG own address space, which is private, so no other process can read it."
echo "# mumps -run %XCMD, do peek^ydb1143 : expecting the feature present in this process"
$ydb_dist/mumps -run %XCMD 'set ^a=1 do peek^ydb1143("DEFAULT",1)'
$ydb_dist/yottadb -run build^ydb1143
$ydb_dist/yottadb -run verify^ydb1143 > before.reorg.out
echo "# mupip reorg >& reorg.out"
$ydb_dist/mupip reorg >& reorg.out
echo "reorg exit status $status"
$grep -cE "%YDB-E-|%YDB-F-" reorg.out
$ydb_dist/yottadb -run verify^ydb1143 > after.reorg.out
diff before.reorg.out after.reorg.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ across MUPIP REORG"
	diff before.reorg.out after.reorg.out
else
	echo "answers unchanged across MUPIP REORG"
endif
check_idx 1024 1024
echo

echo "## 3. A statsDB gets NO search index"
echo "# Not because its tree is small, it carries one record per live process, but because next to"
echo "# nothing searches it : a process finds its own record once and holds on to it. An index there"
echo "# would be shared memory spent for nothing, once per base region."
echo "# A STATSDB region is named for its base region in lower case, so DEFAULT gives default, and"
echo "# statistics sharing has to be on for a process to reach it."
setenv ydb_statshare 1
setenv gtm_statshare 1
echo "# mumps -run %XCMD, reading sgmnt_data.search_idx_size and search_idx_slots"
echo "# through PEEKBYNAME for region default"
$ydb_dist/mumps -run %XCMD 'set ^statstrigger=1 write "statsdb size  = ",$$^%PEEKBYNAME("sgmnt_data.search_idx_size","default"),$C(10),"statsdb slots = ",$$^%PEEKBYNAME("sgmnt_data.search_idx_slots","default"),$C(10)' >& statsdb.out
cat statsdb.out
# and checked, not merely shown : 0 and 0 is the whole claim of this stage
set ssize = `awk '/statsdb size/{print $NF}' statsdb.out`
set sslots = `awk '/statsdb slots/{print $NF}' statsdb.out`
if (("$ssize" == "0") && ("$sslots" == "0")) then
	echo "statsDB carries no search index, as expected"
else
	echo "WRONG : statsDB has size $ssize and slots $sslots, expected 0 and 0"
endif
echo "# against the base region, which has them"
echo "# mumps -run %XCMD, reading sgmnt_data.search_idx_size and search_idx_slots"
echo "# through PEEKBYNAME for region DEFAULT"
$ydb_dist/mumps -run %XCMD 'write "base    size  = ",$$^%PEEKBYNAME("sgmnt_data.search_idx_size","DEFAULT"),$C(10),"base    slots = ",$$^%PEEKBYNAME("sgmnt_data.search_idx_slots","DEFAULT"),$C(10)' >& basedb.out
cat basedb.out
set bsize = `awk '/base    size/{print $NF}' basedb.out`
set bslots = `awk '/base    slots/{print $NF}' basedb.out`
if (("$bsize" == "1024") && ("$bslots" == "1024")) then
	echo "base region carries one, as expected"
else
	echo "WRONG : base region has size $bsize and slots $bslots, expected 1024 and 1024"
endif
setenv ydb_statshare 0
setenv gtm_statshare 0
echo

echo "## 4. Turning the feature on and off changes the FILE HEADER and not one database block"
echo "# The release note says the blocks of a database with search indexes enabled are byte for byte"
echo "# those of one without them. The file header does change - it carries the two settings - so the"
echo "# comparison starts after it. The header occupies the first start_vbn minus one 512 byte blocks."
set svbn = `echo "dump -fileheader" | $ydb_dist/dse |& $grep -i "Starting VBN" | sed 's/.*Starting VBN *//;s/ .*//'`
@ hdrbytes = ( $svbn - 1 ) * 512
echo "# comparing from byte $hdrbytes onwards"
cp mumps.dat before.toggle.dat
echo "# mupip set -nosearch_index -region DEFAULT"
$ydb_dist/mupip set -nosearch_index -region DEFAULT |& strip_path
cmp -i $hdrbytes before.toggle.dat mumps.dat
if ($status) then
	echo "TEST-E-FAIL : a database block changed when the feature was turned off"
else
	echo "every database block is byte for byte identical with the feature off"
endif
echo "# mupip set -search_index_size=1024,1024 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1024,1024 -region DEFAULT |& strip_path
cmp -i $hdrbytes before.toggle.dat mumps.dat
if ($status) then
	echo "TEST-E-FAIL : a database block changed when the feature was turned back on"
else
	echo "and identical again with it back on"
endif
check_idx 1024 1024
echo

$gtm_tst/com/dbcheck.csh
echo "# YDB1143 SEARCH INDEX MISC TEST DONE"
