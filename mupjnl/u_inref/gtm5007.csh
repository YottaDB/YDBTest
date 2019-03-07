#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test case to verify -parallel in mupip command overrides $gtm_mupjnl_parallel

if (! $?gtm_test_replay) then
	setenv gtm5007_rand1 `$gtm_tst/com/genrandnumbers.csh 2 2 20`
	setenv gtm5007_rand2 `$gtm_tst/com/genrandnumbers.csh 2 2 1000000`
	echo "setenv gtm5007_rand1 '$gtm5007_rand1'"	>>&! settings.csh
	echo "setenv gtm5007_rand2 '$gtm5007_rand2'"	>>&! settings.csh
endif

set smallrange = ($gtm5007_rand1)
set largerange = ($gtm5007_rand2)

setenv gtm_test_jnl SETJNL # To turn on journaling
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 -allocation=2048 -extension_count=2048

$gtm_tst/com/backup_dbjnl.csh save "*.dat" cp nozip

$gtm_tst/com/imptp.csh >&! imptp.out
sleep 5 # There are no framework scripts to wait for n updates in a non-replicated environment
$gtm_tst/com/endtp.csh >&! endtp.out

# Case 1 : set gtm_mupjnl_parallel > 1 ; -parallel=1
# -parallel=1 should override gtm_mupjnl_parallel value
if (10 > $smallrange[1]) then
	# ~ 50% of the time set it to 2-9
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_mupjnl_parallel gtm_mupjnl_parallel $smallrange[1]
else
	# ~ 50% of the time set it to a large number
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_mupjnl_parallel gtm_mupjnl_parallel $largerange[1]
endif

echo "# Case 1 : Set gtm_mupjnl_parallel to > 1 and explicitly pass -parallel=1 - Expect -parallel setting to override gtm_mupjnl_parallel"
echo "# gtm_mupjnl_parallel is set to : GTM_TEST_DEBUGINFO $gtm_mupjnl_parallel"
cp -f ./save/* .

echo "# journal recover"
$MUPIP journal -recover -forward "*" -verbose -parallel=1 >&! journal_recover_case_1.out
echo "# Do not expect any region prefix messages in the recover output"
$grep -E '^(AREG|BREG|CREG|DEFAULT) : %YDB-I' journal_recover_case_1.out

echo "# journal show"
$MUPIP journal -show=broken -forward '*' -parallel=1 >&! journal_show_case_1.out
echo "# The region order in journal show output should be deterministic"
$tst_awk -F / '/SHOW output for/ {print $NF}' journal_show_case_1.out

# Case 2 : set gtm_mupjnl_parallel to 1 ; -parallel=4
# -parallel=4 should override gtm_mupjnl_parallel value
@ isodd = $smallrange[2] % 2
if ($isodd) then
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_mupjnl_parallel gtm_mupjnl_parallel 1
else
	source $gtm_tst/com/unset_ydb_env_var.csh ydb_mupjnl_parallel gtm_mupjnl_parallel
endif
if (10 > $smallrange[2]) then
	# ~ 50% of the time pass 2-10 as the value to -parallel
	set parallel =  $smallrange[2]
else if (15 > $smallrange[2]) then
	# ~ 25% of the time pass 2-1000000 as the value to -parallel
	set parallel = $largerange[2]
else
	# ~ 25% of the time pass 0 as the value to -parallel
	set parallel = 0
endif

echo "# Case 2 : Set gtm_mupjnl_parallel to 1 or unset it and explicitly pass -parallel=n - Expect -parallel setting to override gtm_mupjnl_parallel"
echo "# The value passed to -parallel= is : GTM_TEST_DEBUGINFO $parallel"
# Create a file with the default journal order, for comparison later
cat > jnl_order.out << CAT_EOF
a.mjl
b.mjl
c.mjl
mumps.mjl
CAT_EOF

cp -f ./save/* .
echo "# Do journal recover with -parallel=n"
$MUPIP journal -recover -forward "*" -verbose -parallel=$parallel >&! journal_recover_case_2.out
echo "# Expect region prefix messages in the recover output"
$grep -q -E '^(AREG|BREG|CREG|DEFAULT) : %YDB-I' journal_recover_case_2.out
if ($status) then
	echo "RECOV-E-PARALLEL : Region name prefix expected in recover output, but not found"
	echo "Check journal_recover_case_1.out"
endif

echo "# Do journal show with -parallel=n"
echo "# The region order in journal show output should not be deterministic"
# Since it is possible that the random order can be the same as the region order, doing it 20 times to see
# at least one has a random order. Note that this can still fail one out of a million runs but the probability
# is too small that we dont expect to see failures in practice.
@ i = 1
@ maxtries = 20
set testcase = "journal_show_case_2"
while ($i <= $maxtries)
	$MUPIP journal -show=broken -forward '*' -parallel=$parallel  >&! ${testcase}_${i}.out
	$tst_awk -F / '/SHOW output for/ {print $NF}' ${testcase}_${i}.out >&! ${testcase}_${i}_regorder.out
	cmp -s jnl_order.out ${testcase}_${i}_regorder.out
	if ($status) then
		break
	endif
	@ i++
end

if ($maxtries == $i) then
	echo "JOURNAL-E-PARALLEL : mupip journal show -parallel=n had the deterministic region order $maxtries out of $maxtries times, which is unexpected"
	echo "Check ${testcase}* files"
endif
$gtm_tst/com/dbcheck.csh
