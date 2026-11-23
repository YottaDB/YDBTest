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
echo '# [YDB#1408] MUPIP CREATE does not issue JNLALLOCGROW if journal ALLOCATION equals AUTOSWITCHLIMIT   #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# GDE, MUPIP SET -JOURNAL and MUPIP CREATE increase the journal ALLOCATION to the AUTOSWITCHLIMIT, with a'
echo '# JNLALLOCGROW message, if the ALLOCATION plus the EXTENSION is greater than the AUTOSWITCHLIMIT. MUPIP CREATE'
echo '# issued the message even if the ALLOCATION in the global directory was already the same as the AUTOSWITCHLIMIT,'
echo '# in which case the message showed the same value as the old and the new ALLOCATION.'
echo

# Journaling settings are part of the test cases below so do not let the test framework turn journaling on.
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : ALLOCATION in the global directory is the same as the AUTOSWITCHLIMIT'
echo '# Command : GDE change -region DEFAULT -journal=(nobefore_image,allocation=16384,autoswitchlimit=16384)'
echo '# Expect no JNLALLOCGROW message from GDE'
$GDE 'change -region DEFAULT -journal=(nobefore_image,allocation=16384,autoswitchlimit=16384)' >& gde1.out
$grep -E 'JNLALLOCGROW|-[EWF]-' gde1.out
rm mumps.dat
echo '# Command : mupip create'
echo '# Before the fix : JNLALLOCGROW, Increased Journal ALLOCATION from [16384 blocks] to [16384 blocks]'
echo '# With the fix   : expect no JNLALLOCGROW message'
$MUPIP create >& create1.out
$grep -E 'JNLALLOCGROW|-[EWF]-' create1.out
echo '# Expect Journal Allocation 16384 and Journal AutoSwitchLimit 16384 in the database file header'
$DSE dump -fileheader >& dse1.out
$tst_awk '/Journal Allocation/ {print "Journal Allocation " $3} /Journal AutoSwitchLimit/ {print "Journal AutoSwitchLimit " $3}' dse1.out
echo

echo '# Stage 2 : GDE increases the ALLOCATION to the AUTOSWITCHLIMIT'
echo '# Command : GDE change -region DEFAULT -journal=(nobefore_image,allocation=4096,extension=32768,autoswitchlimit=32768)'
echo '# Expect JNLALLOCGROW from [4096 blocks] to [32768 blocks] from GDE'
$GDE 'change -region DEFAULT -journal=(nobefore_image,allocation=4096,extension=32768,autoswitchlimit=32768)' >& gde2.out
$grep -E 'JNLALLOCGROW|-[EWF]-' gde2.out
rm mumps.dat
echo '# Command : mupip create'
echo '# Before the fix : JNLALLOCGROW, Increased Journal ALLOCATION from [32768 blocks] to [32768 blocks]'
echo '# With the fix   : expect no JNLALLOCGROW message'
$MUPIP create >& create2.out
$grep -E 'JNLALLOCGROW|-[EWF]-' create2.out
echo '# Expect Journal Allocation 32768 and Journal AutoSwitchLimit 32768 in the database file header'
$DSE dump -fileheader >& dse2.out
$tst_awk '/Journal Allocation/ {print "Journal Allocation " $3} /Journal AutoSwitchLimit/ {print "Journal AutoSwitchLimit " $3}' dse2.out
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
