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
echo '# [YDB#1337] $ZPEEK() issues BADZPEEKARG for a first argument longer than 63 bytes, and no longer    #'
echo '# overwrites the process stack                                                                       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# $ZPEEK() copied the part of its first argument before the first colon (the mnemonic) into a stack'
echo '# buffer of 31 bytes without checking the length, so a longer first argument overwrote the process'
echo '# stack. $ZPEEK() now copies into a buffer of 63 bytes (31 for the mnemonic, 1 for the colon, 31 for'
echo '# the argument), so a first argument of 32 to 63 bytes gets the same BADZPEEKARG as before, and'
echo '# $ZPEEK() issues BADZPEEKARG with "length" (the length of the first argument) for a longer first'
echo '# argument.'
echo '# Each stage runs its case in a new process and prints PASS or FAIL.'
echo

cp $gtm_tst/$tst/inref/ydb1337.m .
echo '# Create a database (stage 6 peeks at its region)'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
echo '# Create a global directory r31.gld with a region whose name has 31 bytes, the maximum, and its'
echo '# database, for stages 7 to 9'
set r31 = RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
set r31gld = $PWD/r31.gld
echo "change -segment DEFAULT -file=$PWD/r31default.dat" > r31.gde
echo "add -segment SEG31 -file=$PWD/r31.dat" >> r31.gde
echo "add -region $r31 -dynamic_segment=SEG31" >> r31.gde
echo "add -name y -region=$r31" >> r31.gde
(setenv gtmgbldir $r31gld; setenv ydb_gbldir $r31gld; $gtm_dist/mumps -run GDE < r31.gde >& r31_gde.out; \
	$gtm_dist/mupip create >& r31_create.out)
if ($status) then
	echo "# Creating r31.gld or its databases failed. Output follows."
	cat r31_gde.out r31_create.out
endif
echo

foreach label (len100000 len64 len63 len32 arglong valid gdrreg31 critreg31 gdrreg32)
	switch ($label)
	case "len100000":
		echo '# Stage 1 : $ZPEEK(<100000 bytes, no colon>,0,0)'
		echo '# Before the fix : the process was killed by a signal 11 (SIG-11)'
		echo '# With the fix   : expect BADZPEEKARG with "length"'
		breaksw
	case "len64":
		echo '# Stage 2 : $ZPEEK(<64 bytes, no colon>,0,0)'
		echo '# Before the fix : BADZPEEKARG with "mnemonic type", after the copy overwrote the stack, so the'
		echo '#                  line below was a FAIL line'
		echo '# With the fix   : expect BADZPEEKARG with "length"'
		breaksw
	case "len63":
		echo '# Stage 3 : $ZPEEK(<63 bytes, no colon>,0,0)'
		echo '# Before the fix : the same output, after the copy overwrote the stack'
		echo '# With the fix   : expect BADZPEEKARG with "mnemonic type", as 63 bytes is not too long but is not a'
		echo '#                  valid mnemonic'
		breaksw
	case "len32":
		echo '# Stage 4 : $ZPEEK(<32 bytes, no colon>,0,0)'
		echo '# Before the fix : the same output, after the copy overwrote the stack by 1 byte (which only an'
		echo '#                  ASAN build detects, as a stack-buffer-overflow)'
		echo '# With the fix   : expect BADZPEEKARG with "mnemonic type"'
		breaksw
	case "arglong":
		echo '# Stage 5 : $ZPEEK("GDRREG:<57 bytes>",0,0), a first argument of 64 bytes with a valid mnemonic'
		echo '# Before the fix : BADZPEEKARG with "mnemonic argument", so the line below was a FAIL line'
		echo '# With the fix   : expect BADZPEEKARG with "length"'
		breaksw
	case "valid":
		echo '# Stage 6 : $ZPEEK("GDRREG:DEFAULT",0,2,"U"), a valid first argument'
		echo '# Before the fix : the same output (this stage is a control)'
		echo '# With the fix   : expect 7, the length of the region name DEFAULT'
		breaksw
	case "gdrreg31":
		echo '# Stage 7 : $ZPEEK("GDRREG:<31-byte region name>",0,2,"U"), a valid first argument of 38 bytes'
		echo '# Before the fix : the same output (this stage is a control)'
		echo '# With the fix   : expect 31, the length of the region name'
		breaksw
	case "critreg31":
		echo '# Stage 8 : $ZPEEK("CRITREG:<31-byte region name>",0,2,"U"), a valid first argument of 39 bytes,'
		echo '#           the longest valid first argument (CRITREG is one of the longest mnemonics, 7 bytes)'
		echo '# Before the fix : the same output (this stage is a control)'
		echo '# With the fix   : expect a number, and no error'
		breaksw
	case "gdrreg32":
		echo '# Stage 9 : $ZPEEK("GDRREG:<32-byte region name>",0,0), a region name 1 byte longer than the'
		echo '#           maximum, in a first argument of 39 bytes'
		echo '# Before the fix : the same output (this stage is a control)'
		echo '# With the fix   : expect BADZPEEKARG with "mnemonic argument"'
		breaksw
	endsw
	if ($label =~ *reg3[12]) then
		echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1337, with the global directory r31.gld'
		(setenv gtmgbldir $r31gld; setenv ydb_gbldir $r31gld; $gtm_dist/mumps -run $label^ydb1337)
	else
		echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1337'
		$gtm_dist/mumps -run $label^ydb1337
	endif
	echo
end

(setenv gtmgbldir $r31gld; setenv ydb_gbldir $r31gld; $gtm_dist/mupip integ -region "*" >& r31_integ.out)
if ($status) then
	echo "# MUPIP INTEG of the databases of r31.gld failed. Output follows."
	cat r31_integ.out
endif
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
