#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$echoline
echo "Test various issues identified with the READ_ONLY db characteristic (new feature in GT.M V6.3-003)"
$echoline
#

setenv gtm_test_db_format "NO_CHANGE"	# do not switch db format as that will cause incompatibilities with MM
					# which this test sets the access method to in the early stages.
# This test requires MM (READ_ONLY requires that access method).
# So force MM and therefore disable encryption & nobefore as they are incompatible with MM
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
source $gtm_tst/com/mm_nobefore.csh	# Force NOBEFORE image journaling with MM

# Disable semaphore counter overflow in this test as otherwise we might see DBRDONLY errors in leftover_ipc_cleanup_if_needed.out
unsetenv gtm_db_counter_sem_incr

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
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak2 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test that ftok semaphore is not left around after halt from a READ_ONLY database"
	cp ${permission}_bak/* .
	set ftok_value = `$ydb_dist/ftok mumps.dat | $grep mumps.dat | $tst_awk '{print $5}'`
	set before = `ipcs -a | $grep $ftok_value`
	$GTM << YDB_EOF
	write "Open the READ_ONLY database mumps.dat. Expect no errors during open",!  set x=\$get(^x)
	write "Expect no errors while halting out"
	quit
YDB_EOF
	set after = `ipcs -a | $grep $ftok_value`
	if ("" != "$after") then
		echo "TEST-E-FAIL : ftok semaphore is left around"
		echo "ipcs before = $before"
		echo "ipcs after  = $after"
	endif
	$gtm_tst/com/dbcheck.csh >& dbcheck_$permission.out
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak3 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test for cases where READONLYNOSTATS error should and should not be issued"
	cp ${permission}_bak/* .
	# Use multiple iterations of this for loop to exercise -reg and -file codepaths of MUPIP SET
	if ($permission == "READ-ONLY") then
		chmod a+w mumps.dat	# Restore write permissions as we are going to change file header settings
		set noglob	# do not try to expand the * in $regorfile
		set regorfile = '-reg "*"'
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
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak4 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test for cases where READONLYNOBG error should and should not be issued"
	unset noglob	# need * expansion in below line
	cp ${permission}_bak/* .
	# Use multiple iterations of this for loop to exercise -reg and -file codepaths of MUPIP SET
	if ($permission == "READ-ONLY") then
		chmod a+w mumps.dat	# Restore write permissions as we are going to change file header settings
		set noglob		# continue noglob for "*" in $regorfile
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
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak5 "*.gld *.dat *.mjl* *.repl* *.out*" mv

	echo ""
	echo "# Test for cases where READONLYLKFAIL error should be issued"
	unset noglob	# need * expansion in below line
	cp ${permission}_bak/* .
	# Use multiple iterations of this for loop to exercise -reg and -file codepaths of MUPIP SET
	if ($permission == "READ-ONLY") then
		chmod a+w mumps.dat	# Restore write permissions as we are going to change file header settings
		set regorfile = "-reg '*'"	# Modify regorfile (use single-quote instead of double-quote) so zsystem can work fine
		set noglob		# continue noglob for "*" in $regorfile
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
	$gtm_tst/com/backup_dbjnl.csh ${permission}_bak6 "*.gld *.dat *.mjl* *.repl* *.out*" mv
end

