#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2005, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# pre-create the settings.log file as tagged ascii so that
# all future writes into the file as written in the desired chset.
if ! ( -e settings.log ) then
	touch settings.log
	$convert_to_gtm_chset settings.log
endif
setenv gtm_test_spanreg 0  # The test sets a specific TN, does updates and expects a specific TN at the end
setenv ydb_test_4g_db_blks 0 # Disable debug-only huge db scheme as this test uses the incompatible MM access method

# if the transaction is not updating the database and the db has no jouraling either,
# we will then consider a dupsetnoop update as NO update at all but instead treat it as a read-only TP transaction.
# So the db curr_tn will NOT be incremented. If the db is journaled, then the db curr_tn will be incremented.
# The below test randomly enables journaling. In order to have consistent reference file, we'll disable dupsetnoop
echo "# Disable gtm_gvdupsetnoop (reason stated in subtest comment)" >> settings.log
unsetenv gtm_gvdupsetnoop

foreach accmethod (BG MM)
	if (("MM" == $accmethod) && ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype")) then
		continue;
	endif
	# ##TEMP## beowulf has an issue with MM (check mails with subject : "Weird MM issues on Beowulf"). Disable MM tests temporarily
	if (("MM" == $accmethod) && ("beowulf" == "$HOST:r:r:r")) then
		continue
	endif
	setenv acc_meth $accmethod
	echo "**** This is for access method $accmethod ****"
	echo ""
	#alloc enough number of blocks initially so that random updates do not cause file extension
	$gtm_tst/com/dbcreate.csh mumps 1 -acc_meth=$accmethod -alloc=600
	if (!($?basic_jnl_rand) )then
		@ basic_jnl_rand = `$gtm_exe/mumps -run rand 3`
		echo "setenv basic_jnl_rand $basic_jnl_rand" >>! settings.csh
	endif
	if (("MM" == $accmethod) && (2 == $basic_jnl_rand)) then
		@ basic_jnl_rand = 1
	endif
	echo "The acc_method is $accmethod and the database is single-region" >>settings.log
	if (0 == $basic_jnl_rand) then
		# Journaling is OFF by default
		echo "The value of 'basic_jnl_rand' is $basic_jnl_rand and so Journaling is set OFF" >> settings.log
	else if (1 == $basic_jnl_rand) then
		$MUPIP set -journal="on,enable,nobefore" -region DEFAULT >>&! journal_on_nobefore_single.out
		echo "The value of 'basic_jnl_rand' is $basic_jnl_rand and so Journaling is set ON,ENABLE,NOBEFORE" >> settings.log
	else
		$MUPIP set -journal="on,enable,before" -region DEFAULT >>&! journal_on_before_single.out
		echo "The value of 'basic_jnl_rand' is $basic_jnl_rand and so Journaling is set ON,ENABLE,BEFORE" >> settings.log
	endif

	set v1 = "1"
	set v2 = "F7FFFDFF"		# TN_RESET_32 - 512
	set v3 = "FFFFFDFF"		# M32 - 512
	set v4 = "FFFFFFFEE00"		# M32 * 0X1000 - 512
	set v5 = "FFFFFFFEFE00"		# M32 * 0X10000 - 512
	set v6 = "FFFFFFFEFFE00"	# M32 * 0X100000 - 512
	set v7 = "FFFFFFD000000000"	# A value close to but < MAX_WARN_TN
	set v8 = "FFFFFFFFDFFFFDFF"	# MAX_TN_NEW -512

	foreach new_tn ($v1 $v2 $v3 $v4 $v5 $v6 $v7 $v8 )
		$gtm_tst/$tst/u_inref/check_tn.csh "DEFAULT" "^a" $new_tn
	end
	$gtm_tst/com/dbcheck.csh
	$gtm_tst/com/backup_dbjnl.csh single_region_$accmethod "*.dat *.gld *.mjl* dse_dump_*" mv

	echo "*** Now do the same for Multi-region database *** "
	echo ""

	$gtm_tst/com/dbcreate.csh mumps 4 -acc_meth=$accmethod -alloc=600

	echo "The acc_method is $accmethod and the database is multi-region" >>settings.log
	if (0 == $basic_jnl_rand) then
		# Journaling is OFF by default
		echo "The value of 'basic_jnl_rand' is $basic_jnl_rand and so Journaling is set OFF (for all regions)" >> settings.log
	else if (1 == $basic_jnl_rand) then
		$MUPIP set -journal="on,enable,nobefore" -region "*" >>&! journal_on_nobefore_multi.log
		echo "The value of 'basic_jnl_rand' is $basic_jnl_rand and so Journaling is set ON,ENABLE,NOBEFORE (for all regions)" >> settings.log
	else
		$MUPIP set -journal="on,enable,before" -region "*" >>&! journal_on_before_multi.log
		echo "The value of 'basic_jnl_rand' is $basic_jnl_rand and so Journaling is set ON,ENABLE,BEFORE (for all regions)" >> settings.log
	endif

	$gtm_tst/$tst/u_inref/check_tn.csh "AREG" "^a" $v1
	$gtm_tst/$tst/u_inref/check_tn.csh "BREG" "^b" $v2
	$gtm_tst/$tst/u_inref/check_tn.csh "CREG" "^c" $v5
	$gtm_tst/$tst/u_inref/check_tn.csh "DEFAULT" "^d" $v4
	$gtm_tst/com/dbcheck.csh
end
