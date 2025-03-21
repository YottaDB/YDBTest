#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Signal dbcheck_base.csh (called in various places below) to not try to do a "mupip backup" on the *.dat files
# (it would do this before doing "mupip upgrade" and "mupip reorg -upgrade") as it would get a DBRDONLY error.
setenv dbcheck_base_skip_upgrade_check 1

$echoline
echo "Test various issues identified with the READ_ONLY db characteristic (new feature in GT.M V6.3-003)"
$echoline

# If "gtm_db_counter_sem_incr" env var is set to a high value, then the calls to "leftover_ipc_cleanup_if_needed.csh" below
# would generate a %YDB-E-DBRDONLY error. But they won't show up in the reference file since the call to "backup_dbjnl.csh"
# which is done immediately afterwards does a "gzip" of the "leftover_ipc_cleanup_if_needed.out" file thereby removing this
# from being a candidate for looking at by com/errors.csh at the end of the subtest (it only look at "*.out", not "*.out.gz").
# But if "ydb_test_4g_db_blks" env var is non-zero, then "backup_dbjnl.csh" does not gzip any files and so
# "leftover_ipc_cleanup_if_needed.out" would say as is resulting in it being looked at by com/errors.csh and the %YDB-E-DBRDONLY
# error in it being identified at the end of the test and resulting in a test failure. Therefore disable the 4g blk scheme.
setenv ydb_test_4g_db_blks 0

setenv gtm_test_db_format "NO_CHANGE"	# do not switch db format as that will cause incompatibilities with MM
					# which this test sets the access method to in the early stages.
# This test requires MM (READ_ONLY requires that access method).
# So force MM and therefore disable encryption & nobefore as they are incompatible with MM
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
source $gtm_tst/com/mm_nobefore.csh	# Force NOBEFORE image journaling with MM

foreach permission ("READ-WRITE" "READ-ONLY")
	echo ""
	echo "# Create database with $permission permissions and READ_ONLY flag"
	$echoline
	$gtm_tst/com/dbcreate.csh mumps >& create_$permission.out
	$MUPIP set -nostats -read_only -acc=MM -reg "*" >& mupipset_$permission.out
	if ($status) then
		echo "TEST-E-FAIL : mupip set -nostats -read_only -acc=MM -reg * : failed. Output of command follows"
		cat mupipset_$permission.out
		exit -1
	endif
	if ($permission == "READ-ONLY") then
		chmod a-w mumps.dat
	endif
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak "*.gld *.dat *.mjl* *.repl*" cp nozip	# Take backup for later restore
	echo ""
	echo "# Test that READ_ONLY database with $permission permissions works fine even after argumentless mupip rundown"
	echo "# Test that help database works fine even after argumentless rundown"
	$GTM << YDB_EOF
	write "Open the READ_ONLY database mumps.dat",!  set x=\$get(^x)
	write "Open the help database",!  set x=\$\$^%PEEKBYNAME("sgmnt_data.file_corrupt","DEFAULT")
	write "Concurrently run argumentless MUPIP RUNDOWN",!  zsystem "\$ydb_dist/mupip rundown >& rundown_$permission.outx"
	write "Expect no errors while halting out"
	quit
YDB_EOF
	$gtm_tst/com/dbcheck.csh >& dbcheck_$permission.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak1 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test that READ_ONLY database works fine after a MUPIP command that gets standalone access"
	cp ${permission}_bak/* .
	$MUPIP integ -file mumps.dat >& integ_$permission.out
	$GTM << YDB_EOF
	write "Open the READ_ONLY database mumps.dat. Expect no errors during open",!  set x=\$get(^x)
	write "Expect no errors while halting out"
	quit
YDB_EOF
	$gtm_tst/com/dbcheck.csh >& dbcheck_$permission.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak2 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test that ftok semaphore is not left around after halt from a READ_ONLY database"
	cp ${permission}_bak/* .
	set ftok_value = `$MUPIP ftok mumps.dat |& $grep mumps.dat | $tst_awk '{print substr($10, 2, 10);}'`
	echo "Validate our ftok_value by printing it here and check it with the reference file - mumps.dat ftok: $ftok_value"
	set before = `$gtm_tst/com/ipcs -a | $grep $ftok_value`
	$GTM << YDB_EOF
	write "Open the READ_ONLY database mumps.dat. Expect no errors during open",!  set x=\$get(^x)
	write "Expect no errors while halting out"
	quit
YDB_EOF
	set after = `$gtm_tst/com/ipcs -a | $grep $ftok_value`
	if ("" != "$after") then
		echo "TEST-E-FAIL : ftok semaphore is left around"
		echo "ipcs before = $before"
		echo "ipcs after  = $after"
	endif
	$gtm_tst/com/dbcheck.csh >& dbcheck_$permission.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak3 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test for cases where READONLYNOSTATS error should and should not be issued"
	cp ${permission}_bak/* .
	# Use multiple iterations of this for loop to exercise -reg and -file codepaths of MUPIP SET
	if ($permission == "READ-ONLY") then
		chmod a+w mumps.dat	# Restore write permissions as we are going to change file header settings
		set noglob	# do not try to expand the * in $regorfile
		set regorfile = '-reg *'
	else
		set regorfile = "-file mumps.dat"
	endif
	echo "  --> Try setting STATS on a database that has READ_ONLY already set. This should error out."
	$MUPIP set -stats $regorfile
	echo "  --> Try setting READ_ONLY on a database that has STATS already set. This should error out."
	$MUPIP set -noread_only -stats $regorfile
	$MUPIP set -read_only $regorfile
	echo "  --> Try setting READ_ONLY, STATS and MM on a database at the same time. This should error out."
	$MUPIP set -noread_only -nostats $regorfile
	$MUPIP set -stats -read_only -access_method=MM $regorfile
	echo "  --> Try setting READ_ONLY, STATS and BG on a database at the same time. This should error out."
	$MUPIP set -noread_only -nostats $regorfile
	$MUPIP set -stats -read_only -access_method=BG $regorfile
	echo "  --> Try setting READ_ONLY and NOSTATS on a database at the same time. This should NOT error out."
	$MUPIP set -nostats -read_only $regorfile
	echo "  --> Try setting NOREAD_ONLY and STATS on a database at the same time. This should NOT error out."
	$MUPIP set -stats -noread_only $regorfile
	echo "  --> Try setting NOREAD_ONLY and NOSTATS on a database at the same time. This should NOT error out."
	$MUPIP set -nostats -noread_only $regorfile
	echo "  --> Try setting READ_ONLY on a database that has NOSTATS already set. This should NOT error out."
	$MUPIP set -nostats $regorfile
	$MUPIP set -read_only $regorfile
	echo "  --> Try setting STATS on a database that has NOREAD_ONLY already set. This should NOT error out."
	$MUPIP set -noread_only $regorfile
	$MUPIP set -stats $regorfile
	$gtm_tst/com/dbcheck.csh >& dbcheck_$permission.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak4 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test for cases where READONLYNOBG error should and should not be issued"
	unset noglob	# need * expansion in below line
	cp ${permission}_bak/* .
	# Use multiple iterations of this for loop to exercise -reg and -file codepaths of MUPIP SET
	if ($permission == "READ-ONLY") then
		chmod a+w mumps.dat	# Restore write permissions as we are going to change file header settings
		set noglob		# continue noglob for * in $regorfile
	endif
	echo "  --> Try setting BG on a database that has READ_ONLY already set. This should error out."
	$MUPIP set -nostats -read_only $regorfile
	$MUPIP set -access_method=BG $regorfile
	echo "  --> Try setting READ_ONLY on a database that has BG already set. This should error out."
	$MUPIP set -noread_only -access_method=BG $regorfile
	$MUPIP set -read_only $regorfile
	echo "  --> Try setting READ_ONLY and BG on a database at the same time. This should error out."
	$MUPIP set -noread_only -access_method=MM $regorfile
	$MUPIP set -read_only -access_method=BG $regorfile
	echo "  --> Try setting NOREAD_ONLY and BG on a database at the same time. This should not error."
	$MUPIP set -noread_only -access_method=BG $regorfile
	echo "  --> Try setting READ_ONLY and MM on a database at the same time. This should not error."
	$MUPIP set -read_only -access_method=MM $regorfile
	echo "  --> Try setting NOREAD_ONLY and MM on a database at the same time. This should not error."
	$MUPIP set -noread_only -access_method=MM $regorfile
	echo "  --> Try setting READ_ONLY on a database that has MM already set. This should NOT error out."
	$MUPIP set -read_only $regorfile
	echo "  --> Try setting BG on a database that has NOREAD_ONLY already set. This should NOT error out."
	$MUPIP set -noread_only $regorfile
	$MUPIP set -access_method=BG $regorfile
	$gtm_tst/com/dbcheck.csh >& dbcheck_$permission.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak5 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test for cases where READONLYLKFAIL error should be issued"
	unset noglob	# need * expansion in below line
	cp ${permission}_bak/* .
	# Use multiple iterations of this for loop to exercise -reg and -file codepaths of MUPIP SET
	if ($permission == "READ-ONLY") then
		chmod a+w mumps.dat	# Restore write permissions as we are going to change file header settings
		set regorfile = "-reg '*'"	# Modify regorfile (use single-quote instead of double-quote) so zsystem can work fine
		set noglob		# continue noglob for * in $regorfile
	endif
	echo "  --> Test of READONLYLKFAIL error from MUPIP SET"
	$GTM << YDB_EOF
	write "Open the READ_ONLY database mumps.dat.",!  set x=\$get(^x)
	write "Concurrently run argumentless MUPIP SET -NOREAD_ONLY. It should error out",!  zsystem "\$ydb_dist/mupip set -noread_only $regorfile"
	write "Expect no errors while halting out"
	quit
YDB_EOF

	echo "  --> Test of READONLYLKFAIL error from a non-MUPIP-SET process"
	if ($permission == "READ-ONLY") then
		# Restore permissions as they should be now onwards since we are not going to modify the db
		chmod a-w mumps.dat
	endif
	# It is not easy to make the non-MUPIP-SET process access the database while the MUPIP SET command is running
	# (and has an exclusive lock on the database file). Therefore, we simulate that by using the shell flock command
	# to get an exclusive lock on the file and running the non-MUPIP-SET command to access the READ_ONLY db.
	flock -x mumps.dat $ydb_dist/mumps -run %XCMD 'write ^x'
	$gtm_tst/com/dbcheck.csh >& dbcheck_$permission.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak6 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test for multiple processes accessing a READ_ONLY database with ftok semaphore counter overflow"
	# Note that we do not explicitly set gtm_db_counter_sem_incr to 16K here. That is because we rely
	# on the test framework to randomly set this env var thereby exercising more codepaths (16K, 8K, 4K, 1)
	# than just the 16K one.
	unset noglob	# need * expansion in below line
	cp ${permission}_bak/* .
	$ydb_dist/mumps -run readonlysemcntr
	$gtm_tst/com/dbcheck.csh >& dbcheck_$permission.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak7 "*.gld *.dat *.mjl* *.repl* *.out*" mv
end

