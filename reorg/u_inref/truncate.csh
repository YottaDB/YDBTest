#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	# use spanning regions, only for the last test case.
	setenv use_test_specific_gde $gtm_tst/$tst/inref/reorg_truncate_col${colno}.gde
endif
setenv gtm_test_spanreg 0 	# The calculated number of sets below doesn't work with spanningregions
				# Test expects YDB-I-MUTRUNCNOSPACE, but due to global distribution, it doesn't happen
#
setenv test_reorg NON_REORG
setenv gtm_test_mupip_set_version "V5"
$gtm_tst/com/dbcreate.csh mumps 3 -block_size=1024	# The truncate tests below are sensitive to block layout
$GDE << EOF
add -name c* -region=breg
add -name C* -region=breg
EOF

#----- Begin simple tests -----#
$GTM << EOF
f i=1:1:18400 s ^a(i)=\$j(i,20)
f i=1:1:18400 s ^b(i)=\$j(i,20)
h
EOF

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 63  # WBTEST_REORG_DEBUG
setenv gtm_white_box_test_case_count 1
echo "# Try -truncate=100"
$MUPIP reorg -truncate=100 >& trunc_err1.outx
if (("BG" == $acc_meth) && ("dbg" == "$tst_image")) then
	set plvalue = `$tst_awk '/GTMPOOLLIMIT used for mupip reorg :/ {print $NF; exit}' trunc_err1.outx`
	if ($gtm_poollimit_value != $plvalue) then
		echo "YDB-E-POOLLIMIT value mismatch. expected : $gtm_poollimit_value, found : $plvalue"
	endif
endif
$grep "MUTRUNCPERCENT" trunc_err1.outx

echo "# Try -truncate=99"
$MUPIP reorg -truncate=99 >& trunc_err2.outx
$grep "TRUNC" trunc_err2.outx

echo "# A plain reorg -truncate should work"
$MUPIP reorg -truncate >&! trunc_1.out
if ($status) then
	cat trunc_1.out
        echo "TEST failed in MUPIP reorg -truncate"
	exit 1
else
	if (("BG" == $acc_meth) && ("dbg" == "$tst_image")) then
		set plvalue = `$tst_awk '/GTMPOOLLIMIT used for mupip reorg :/ {print $NF; exit}' trunc_1.out`
		if ($gtm_poollimit_value != $plvalue) then
			echo "YDB-E-POOLLIMIT value mismatch. expected : $gtm_poollimit_value, found : $plvalue"
		endif
	endif
	$grep "Trunc" trunc_1.out
endif

echo "# No local bitmaps eligible for truncate yet"
$MUPIP reorg -truncate >&! trunc_2.outx
if ($status) then
	cat trunc_2.outx
        echo "TEST failed in MUPIP reorg -truncate"
	exit 1
else
	$grep "TRUNC" trunc_2.outx
	$grep "Truncated" trunc_2.outx
endif

echo "# The below commands will create a full local bitmap eligible for truncation"
$GTM << EOF
f i=1:1:100 s ^c(i)=\$j(i,20)
k ^c
h
EOF
$MUPIP reorg -truncate >&! trunc_3.outx
if ($status) then
	cat trunc_3.outx
        echo "TEST failed in MUPIP reorg -truncate"
	exit 1
else
	if (("BG" == $acc_meth) && ("dbg" == "$tst_image")) then
		set plvalue = `$tst_awk '/GTMPOOLLIMIT used for mupip reorg :/ {print $NF; exit}' trunc_3.outx`
		if ($gtm_poollimit_value != $plvalue) then
			echo "YDB-E-POOLLIMIT value mismatch. expected : $gtm_poollimit_value, found : $plvalue"
		endif
	endif
	$grep "TRUNC" trunc_3.outx
	$grep "Truncated" trunc_3.outx
endif

set rand_ext = `date | $tst_awk '{srand(); print (32768 + int(rand() * 50))}'`
echo "# Extending AREG by rand_ext :GTM_TEST_DEBUGINFO $rand_ext"
$MUPIP extend -b="$rand_ext" AREG >&! mupip_extend.out
$MUPIP reorg -truncate >&! trunc_4.outx
if ($status) then
	cat trunc_4.outx
        echo "TEST failed in MUPIP reorg -truncate"
	exit 1
else
	if (("BG" == $acc_meth) && ("dbg" == "$tst_image")) then
		set plvalue = `$tst_awk '/GTMPOOLLIMIT used for mupip reorg :/ {print $NF; exit}' trunc_4.outx`
		if ($gtm_poollimit_value != $plvalue) then
			echo "YDB-E-POOLLIMIT value mismatch. expected : $gtm_poollimit_value, found : $plvalue"
		endif
	endif
	$grep "Truncated" trunc_4.outx
	$grep "TRUNC" trunc_4.outx
endif
unsetenv gtm_white_box_test_case_enable

echo "# Test -REGION qualifier"
$MUPIP extend -bl=1000 AREG >>&! mupip_extend.out
$MUPIP extend -bl=1000 BREG >>&! mupip_extend.out
$MUPIP extend -bl=1000 DEFAULT >>&! mupip_extend.out
$MUPIP reorg -truncate -region AREG |& $grep -E "Truncated|TRUNC"

$gtm_tst/com/dbcheck.csh
#------ End simple tests ------#

echo ""
$gtm_tst/com/dbcreate.csh mumps 1 255 500 1024

echo "# Verify truncate frees up space, even when root blocks and directory tree blocks lie towards the end of the file"
$GTM << EOF
for i=1:1:100000 s ^spacefiller(i)=\$j(i,200)
do set^lotsvar
kill ^spacefiller
EOF
$MUPIP reorg -truncate >&! trunc_root1.outx
$grep -E "Truncated|TRUNC" trunc_root1.outx
$MUPIP reorg -truncate >&! trunc_root2.outx
echo "# Second truncate shouldn't move root blocks unnecessarily"
$grep "Total root blocks moved" trunc_root2.outx
$grep -E "Truncated|TRUNC" trunc_root2.outx

$gtm_tst/com/dbcheck.csh

# GTM-7820 - MUPIP REORG -TRUNCATE -SELECT truncates differently based on $data(^global) return value
echo ""
echo '# GTM-7820 - MUPIP REORG -TRUNCATE -SELECT truncates differently based on $data(^global) return value'
echo "# do not kill ^x entirely; keep node ^x and kill ^x(1,*) subtree"
if ($?use_test_specific_gde) then
	setenv test_specific_gde $use_test_specific_gde
endif
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=1024      # The truncate output below is sensitive to block layout
$gtm_exe/mumps -run gtm7820 0 $?use_test_specific_gde
$MUPIP reorg -truncate -select="^x*"
$gtm_tst/com/dbcheck.csh
echo "# kill ^x entirely (i.e. kill node ^x and kill ^x(1,*) subtree)"
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=1024      # The truncate output below is sensitive to block layout
$gtm_exe/mumps -run gtm7820 1 $?use_test_specific_gde
$MUPIP reorg -truncate -select="^x*"
$gtm_tst/com/dbcheck.csh
