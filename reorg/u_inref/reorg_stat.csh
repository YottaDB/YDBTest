#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
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
#
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	# Since the test output relies on integ output, have a static spanning regions file
	setenv test_specific_gde $gtm_tst/$tst/inref/reorg_stat_col${colno}.gde
endif
setenv gtm_test_spanreg 0	# We have already pointed a spanning gld to test_specific_gde
setenv test_reorg "NON_REORG"
setenv gtm_test_do_eotf 0	# The test does mupip integ <file> which needs standalone access
echo "# Adjacency and % Used:"
$gtm_tst/com/dbcreate.csh mumps 2
$GTM << EOF
w "d in4^sfill(""set"",1,1)"  d in4^sfill("set",1,1)
EOF

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 63  # WBTEST_REORG_DEBUG
setenv gtm_white_box_test_case_count 1
$MUPIP integ a.dat >& integ_before_reorg.out
echo "# Data blocks, records, % used and adjacency before reorg"
$grep "Data" integ_before_reorg.out

$MUPIP reorg -select="afill" >& reorg.out
if (("BG" == $acc_meth) && ("dbg" == "$tst_image")) then
	set plvalue = `$tst_awk '/GTMPOOLLIMIT used for mupip reorg : /{print $NF; exit}' reorg.out`
	if ($gtm_poollimit_value != $plvalue) then
		echo "YDB-E-POOLLIMIT value mismatch. expected : $gtm_poollimit_value, found : $plvalue"
	endif
endif

$MUPIP integ a.dat >& integ_after_reorg.out
echo "# Data blocks, records, % used and adjacency after reorg"
$grep "Data" integ_after_reorg.out

echo "# If a global spans multiple regions, when -reg is passed, mupip reorg should act only on the select regions"
#Region Name in Mixed cases should be accpeted
$MUPIP reorg -select="afill" -reg aReg >&! reorg_AREG.out
$grep "Global:" reorg_AREG.out
if (("BG" == $acc_meth) && ("dbg" == "$tst_image")) then
	set plvalue = `$tst_awk '/GTMPOOLLIMIT used for mupip reorg :/ {print $NF; exit}' reorg_AREG.out`
	if ($gtm_poollimit_value != $plvalue) then
		echo "YDB-E-POOLLIMIT value mismatch. expected : $gtm_poollimit_value, found : $plvalue"
	endif
endif
unsetenv gtm_white_box_test_case_enable
$gtm_tst/com/dbcheck.csh
