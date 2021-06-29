#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This subtest can be invoked with or without -replic.
# In the case of -replic, journaling will automatically be turned on.
# But without -replic, this test relies on journaling to be turned on.
# So force that.
if (! $?test_replic) then
	# Turn on journaling as the test relies on that.
	setenv gtm_test_jnl SETJNL
endif

# Since this test does a LOT of mallocs, turn off malloc storage chain verification in case it gets randomly turned on.
unsetenv gtmdbglvl

# In case this test is run with -replic, set a huge receive pool buffer size to avoid REPLTRANS2BIG errors.
# Since this test can generate transactions with up to 1Gib of journal data, set receive pool buffer size to 2Gib.
# Note that tst_buffsize sets both source and receive pool buffer size even though we need only receive pool buffer size.
# It does not hurt to set it on the source side so we keep this simple env var setting.
setenv tst_buffsize 2147483648 # 2Gib

echo "# Run dbcreate.csh"
$gtm_tst/com/dbcreate.csh mumps 1 -record_size=1000

@ case = 0

foreach numupdates (1009155 1009156 1500000 2500000 1009157)
	@ case = $case + 1
	echo "# --------------------------------------------------"
	switch($case)
	case 1:
		set str = "# Expect NO errors (i.e. work fine). Used to also work fine before YDB#749 was fixed."
		set randomrange = 0
		breaksw
	case 2:
		set str = "# Expect TRANSREPLJNL1GB error. Used to work fine before YDB#749 was fixed."
		set randomrange = 0
		breaksw
	case 3:
	case 4:
		set str = "# Expect TRANSREPLJNL1GB error. Used to cause JNLCNTRL/REPLJNLCLOSED error before YDB#749 was fixed."
		set randomrange = 0
		breaksw
	case 5:
		set str = "# Expect TRANSREPLJNL1GB error."
		set randomrange = 2000000
	endsw
	echo -n '# Case '$case' : Run HUGE transaction with '$numupdates
	if (0 != $randomrange) then
		echo -n ' + $random('$randomrange')'
	endif
	echo ' updates'
	echo $str
	echo "# --------------------------------------------------"
	$ydb_dist/yottadb -run ydb749 $numupdates $randomrange
end

echo "# Run dbcheck.csh -extract to ensure db extract on primary matches secondary"
$gtm_tst/com/dbcheck.csh -extract

