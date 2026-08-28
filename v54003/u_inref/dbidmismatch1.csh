#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# dbidmismatch1 : Exercise DBIDMISMATCH error in "mupip rundown -reg *"
#

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#
BEGIN "Choose randomly between -reg OR -file qualifier"
	@ choice = `$gtm_exe/mumps -run rand 2`
END

BEGIN "Create backup.dat and mumps.dat"
$gtm_tst/com/dbcreate.csh backup 1
mv backup.dat backup.dat.orig
$gtm_tst/com/dbcreate.csh mumps 1
mv backup.dat.orig backup.dat
END

BEGIN "Access mumps.dat and crash it"
# at this point, gtmgbldir points to mumps.gld
$GTM << GTM_EOF
	write "set ^x=1"
	set ^x=1
	zsy "$gtm_dist/dse all -buff"
	zsy "$kill9 "_\$j
GTM_EOF
END

BEGIN "get the ftok semid for mumps.dat. Then switch to backup.dat and access database. It should issue DBIDMISMATCH error"
set ftok_key = `$MUPIP ftok mumps.dat |& $grep mumps | $tst_awk '{print substr($10, 2, 10);}'`
set ftok_id = `$gtm_tst/com/ipcs -a | $grep $ftok_key | $tst_awk '{print $2}'`

# switch to backup.gld
# Keep the original mumps.dat inode linked so that it cannot be recycled. The ftok key of the
# semaphore left behind by the "kill -9" above is a 24-bit hash of this file's st_dev and st_ino
# ("gtm_ftok" in sr_unix/gtm_ftok.c). If the "mv" below were to free that inode, a concurrently
# running test whose database or statsDB file lands on the same inode number would compute the same
# key and share this semaphore, and the "ipcrm -s" at the end of this subtest would then remove it
# out from under that process (YDBTest#1046) - or that process would remove it first, which is the
# "invalid id" this subtest used to report. A hard link costs nothing and takes the inode out of
# circulation for the rest of the subtest. Its name must not end in ".dat" because
# "com/dbcheck_base.csh" counts "*.dat" files to determine the number of regions.
ln mumps.dat mumps.dat.inode_holder
cp mumps.dat backup.dat
mv backup.dat mumps.dat
$GTM << GTM_EOF
	write "set ^y=1"
	set ^y=1
GTM_EOF
END

BEGIN "Do MUPIP RUNDOWN and acccess database. This database access should be clean"
if ( $choice == 0 ) then
	echo 'mupip rundown -reg "*"'
	$MUPIP rundown -reg "*"
else
	echo 'mupip rundown -file mumps.dat'
	$MUPIP rundown -file mumps.dat
endif

$GTM << GTM_EOF
	write "set ^y=1"
	set ^y=1
	write "clean database access"
GTM_EOF
END

BEGIN  "Remove leftover ftok semaphore"
echo "ftok id="$ftok_id
# The "kill -9" done earlier left this semaphore's counter at 0 (the counter increment is done with
# SEM_UNDO, so the kernel undid it), so any process that computes the same ftok key can attach to
# it. The inode the key was computed from is held by the "mumps.dat.inode_holder" link created
# earlier and so cannot be recycled, but "gtm_ftok" truncates the hash of st_dev and st_ino to 24
# bits, so a database or statsDB file on another filesystem can still land on this key. A statsDB is
# as likely a sharer as a ".dat": every region goes through "ftok_sem_get(reg, ..., GTM_ID, ...)",
# so both are drawn from the same key space.
#
# "ipcrm -s" removes by id with no counter check, so removing this semaphore unconditionally would
# take it away from such a sharer, which would then fail in "gds_rundown" with an assert and a core
# on a dbg build, or a CRITSEMFAIL on a pro build (YDBTest#1046). So read the counter first and
# leave the semaphore alone unless nothing is counted on it, the way "com/rem_ftok_sem.csh" already
# does for the same reason. The check is not atomic with the removal, so it narrows the window
# rather than closing it.
#
# If the semaphore is already gone, the ipcrm fails with an "invalid id" error. That is not a test
# failure so filter that message out (any other ipcrm error is still let through).
set ftok_semval = `$MUPIP semaphore $ftok_id |& $grep "sem  1" | $tst_awk '{print($4);}' | sed 's/,//'`
if ("$ftok_semval" == "0") then
	$gtm_tst/com/ipcrm -s $ftok_id | $grep -v "invalid id"
else
	# Either another database is counted on this semaphore or it is already gone (in which case
	# MUPIP SEMAPHORE printed nothing and $ftok_semval is empty). Either way there is nothing for
	# this subtest to remove. Whether this branch is taken at all depends on what other tests are
	# doing at the time, so the message below must not reach the compared output. Writing it to a
	# file rather than to stdout is most of that. The ".outx" rather than ".out" is for the step
	# after: "com/submit_subtest.csh" appends "com/errors.csh" output to the compared log, and
	# "com/errors.csh" scans "*.out" while skipping "*.*x".
	echo "Did not remove ftok semaphore $ftok_id : counter is [$ftok_semval]" >> ftok_sem_not_removed.outx
endif
END

$gtm_tst/com/dbcheck.csh
