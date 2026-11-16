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

# [limit] is the largest allowed ratio of the instructions MUPIP REORG executes on a database with 40000 globals to those
# on a database with 10000 globals. The ratio is 4 when the instructions grow linearly with the number of globals. It was
# measured at 11.2 without the YDB#1240 fix and at 4.06 with it, so the limit is drawn in between.
set limit = 6
# The instructions of MUPIP REORG are counted, so turn off journaling, and the storage checks of gtmdbglvl, whose cost
# grows faster than the number of globals, if the test framework chose them at random.
setenv gtm_test_jnl NON_SETJNL
unsetenv gtmdbglvl ydb_dbglvl
echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1240] The instructions MUPIP REORG executes grow linearly with the number of globals           #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# Each stage creates a database with 1 KiB blocks, sets the globals ^g1 to ^gN (one node each), and counts"
echo "# the instructions that MUPIP REORG executes on the database with perf."
echo "# Before the fix : MUPIP REORG compared each global name in the directory tree with the list of selected"
echo "#                  globals from its start, so the instructions grew with the square of the number of globals"
echo "# With the fix   : expect the instructions to grow linearly with the number of globals"

set stage = 0
foreach count (10000 40000)
	@ stage = $stage + 1
	echo
	echo "# Stage $stage : $count globals"
	setenv gtmgbldir g${count}.gld
	echo "# Run [dbcreate.csh g${count} -block_size=1024]"
	$gtm_tst/com/dbcreate.csh g${count} -block_size=1024 >&! dbcreate_${count}.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed (see dbcreate_${count}.out)"
		exit 1
	endif
	echo '# Run [$gtm_dist/mumps -run %XCMD '"'"'for i=1:1:'$count' set @("^g"_i)=1'"'"']'
	$gtm_dist/mumps -run %XCMD 'for i=1:1:'$count' set @("^g"_i)=1' >&! set_${count}.out
	set ngbl = `$gtm_dist/mumps -run %XCMD 'set g="^g",n=0 for  set g=$order(@g) quit:""=g  set n=n+1  write:""=$order(@g) n,!'`
	if (("$ngbl" == "$count") && (-z set_${count}.out)) then
		echo "PASS : the database has the $count globals"
	else
		echo "FAIL : the database has [$ngbl] globals, expected $count (see set_${count}.out)"
	endif
	echo '# Run [perf stat $gtm_dist/mupip reorg]'
	$gtm_tst/com/perfstat.csh $gtm_dist/mupip reorg >&! reorg_${count}.out
	set instr = `$tst_awk -f $gtm_tst/com/perfstat_count.awk reorg_${count}.out`
	if (10000 == $count) then
		set instr_10000 = "$instr"
	else
		set instr_40000 = "$instr"
	endif
	set nreorg = `$grep -c "^Global: g" reorg_${count}.out`
	set nerr = `$grep -c -- "-[EFW]-" reorg_${count}.out`
	if (("$nreorg" == "$count") && (0 == $nerr)) then
		echo "PASS : MUPIP REORG reorganized the $count globals without an error"
	else
		echo "FAIL : MUPIP REORG reorganized $nreorg globals, expected $count, with $nerr errors (see reorg_${count}.out)"
	endif
	$gtm_tst/com/dbcheck.csh >&! dbcheck_${count}.out
	if ($status) then
		echo "FAIL : dbcheck.csh failed (see dbcheck_${count}.out)"
	endif
end

echo
echo "# Stage 3 : the ratio of the instructions with 40000 globals to those with 10000 globals is at most ${limit}"
if (("" == "$instr_10000") || ("" == "$instr_40000")) then
	echo "FAIL : no instruction count from perf (10000 globals: [$instr_10000], 40000 globals: [$instr_40000])"
	exit 1
endif
set ratio = `echo "scale=2; $instr_40000 / $instr_10000" | bc`
if (`echo "$ratio <= $limit" | bc -l`) then
	echo "PASS : the instructions grew at most ${limit}x from 10000 to 40000 globals"
else
	echo "FAIL : the instructions grew ${ratio}x, more than ${limit}x, from 10000 to 40000 globals (10000 globals: $instr_10000, 40000 globals: $instr_40000)"
endif
