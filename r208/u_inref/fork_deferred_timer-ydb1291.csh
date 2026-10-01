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
echo "# [YDB#1291] A SimpleAPI process forked while a flush timer was deferred can make YottaDB calls in   #"
echo "# the child                                                                                          #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# A child inherits the parent's timer queue, including a timer whose handling the parent deferred,"
echo "# and the record that a POSIX timer was created, but not the POSIX timer itself. The first YottaDB"
echo "# call in the child ran the deferred timer handler, which restarted the system timer with the"
echo "# parent's timer id, and failed with %YDB-E-SYSCALL from timer_settime() (ENO22)."
echo "#"
echo "# Without the fix, stage 2 prints WRONG. Stage 1 is a control that forks before any timer is due."
echo

# The fork times below rely on the flush timers of a BG database coming due 1 second after an update
setenv acc_meth BG
echo "# Create a database with regions DEFAULT and AREG (^a maps to AREG)"
$gtm_tst/com/dbcreate.csh mumps 2 >&! dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
echo '# Command : $MUPIP set -flush_time=100 -region "*"'
$MUPIP set -flush_time=100 -region "*" >&! mupip_set.out
if ($status) then
	echo "# MUPIP SET failed. Output follows."
	cat mupip_set.out
endif

set file = ydb1291_fork
$gt_cc_compiler $gtt_cc_shl_options -I$ydb_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
echo

echo "# Stage 1 : update ^x, then ^a 500 milliseconds later, fork 300 milliseconds after the ^x update (no"
echo "#           flush timer is due yet) and read ^x in the child"
echo "# Command : ./$file 300"
echo "#   expect the read to work and the child to exit with status 0"
./$file 300
echo

echo "# Stage 2 : the same, but fork 1200 milliseconds after the ^x update, when the DEFAULT flush timer has"
echo "#           come due and been deferred and the AREG flush timer is still pending"
echo "# Command : ./$file 1200"
echo "#   expect the read to work and the child to exit with status 0"
./$file 1200
echo

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
