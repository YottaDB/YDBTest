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
echo "# [YDB#1345] In UTF-8 mode, an -object value with a byte that is not valid UTF-8 issues NOTMNAME for #"
echo "# that value, as in M mode                                                                           #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# In UTF-8 mode, the command line lexer (sr_unix/cli_lex.c) dropped each byte that is not valid UTF-8'
echo '# from a token. An -object value that started with such a byte became empty, which issued NOTMNAME for'
echo '# "." (an assert failure in zl_cmd_qlf.c in a Debug build), and one that had a valid character too'
echo '# lost the invalid bytes without an error, so the object file got another name. In M mode the value is'
echo '# kept, and NOTMNAME reports it. Each byte 0xB6 in the output is shown as <0xB6>. In UTF-8 mode,'
echo '# NOTMNAME shows a byte that is not valid UTF-8 as a "."'
echo

cp $gtm_tst/$tst/inref/ydb1345.m .
echo ' write "x runs",!' > x.m
echo ' quit' >> x.m
set b6 = `printf '\266'`
$switch_chset "UTF-8" >& switch_chset_utf8.out

foreach stage (1 2 3)
	switch ($stage)
	case 1:
		set val = "$b6"
		set desc = "the byte 0xB6"
		set before = ('NOTMNAME for "." and ZLNOOBJECT in a Release build. A Debug build failed an assert' \
			'in zl_cmd_qlf.c')
		breaksw
	case 2:
		set val = "a$b6"
		set desc = "a and the byte 0xB6"
		set before = ('no error, and a.o was produced')
		breaksw
	case 3:
		set val = "${b6}a"
		set desc = "the byte 0xB6 and a"
		set before = ('no error, and a.o was produced')
		breaksw
	endsw
	echo "# Stage $stage : UTF-8 mode, -object value of $desc"
	echo '# Command : $gtm_dist/mumps -object=<value> x.m'
	set prefix = '# Before the fix :'
	foreach line ($before:q)
		echo "$prefix $line"
		set prefix = '#                 '
	end
	echo '# With the fix   : expect NOTMNAME for the value, ZLNOOBJECT, and no object file'
	$gtm_dist/mumps -object="$val" x.m |& sed 's/\xb6/<0xB6>/g' >& stage$stage.out
	$gtm_tst/com/check_error_exist.csh stage$stage.out NOTMNAME ZLNOOBJECT
	set objs = `ls | $grep '\.o$'`
	if ("" == "$objs") then
		echo "PASS: no object file was produced"
	else
		echo "WRONG: $objs was produced"
		rm -f $objs
	endif
	echo
end

echo '# Stage 4 : UTF-8 mode, ZCOMPILE with an -object value of the byte 0xB6'
echo '# Command : $gtm_dist/mumps -run %XCMD '"'"'do zc^ydb1345($zchar(182))'"'"
echo '# Before the fix : NOTMNAME in a Release build. A Debug build failed an assert in zl_cmd_qlf.c'
echo '# With the fix   : expect ZCOMPILE to issue NOTMNAME, and no object file'
$gtm_dist/mumps -run %XCMD 'do zc^ydb1345($zchar(182))'
echo

echo '# Stage 5 : UTF-8 mode, ZCOMPILE with an -object value of a and the byte 0xB6'
echo '# Command : $gtm_dist/mumps -run %XCMD '"'"'do zc^ydb1345("a"_$zchar(182))'"'"
echo '# Before the fix : no error, and a.o was produced'
echo '# With the fix   : expect ZCOMPILE to issue NOTMNAME, and no object file (not a.o)'
$gtm_dist/mumps -run %XCMD 'do zc^ydb1345("a"_$zchar(182))'
rm -f ydb1345.o
echo

$switch_chset M >& switch_chset_m.out
echo '# Stage 6 : M mode, -object values of the byte 0xB6, and of a and the byte 0xB6 (unchanged by the fix)'
echo '# Command : $gtm_dist/mumps -object=<value> x.m'
echo '# Before the fix : the same result (this stage is a control)'
echo '# With the fix   : expect NOTMNAME for each value, ZLNOOBJECT, and no object file'
$gtm_dist/mumps -object="$b6" x.m |& sed 's/\xb6/<0xB6>/g' >& stage6a.out
$gtm_tst/com/check_error_exist.csh stage6a.out NOTMNAME ZLNOOBJECT
$gtm_dist/mumps -object="a$b6" x.m |& sed 's/\xb6/<0xB6>/g' >& stage6b.out
$gtm_tst/com/check_error_exist.csh stage6b.out NOTMNAME ZLNOOBJECT
set objs = `ls | $grep '\.o$'`
if ("" == "$objs") then
	echo "PASS: no object file was produced"
else
	echo "WRONG: $objs was produced"
	rm -f $objs
endif
echo

$switch_chset "UTF-8" >& switch_chset_utf8_2.out
echo '# Stage 7 : UTF-8 mode, -object value ab (all valid characters)'
echo '# Command : $gtm_dist/mumps -object=ab x.m ; $gtm_dist/mumps -run ab'
echo '# Before the fix : the same result (this stage is a control)'
echo '# With the fix   : expect no error, and ab.o to be produced and to run as routine ab'
$gtm_dist/mumps -object=ab x.m
if (-e ab.o) then
	echo "PASS: ab.o was produced"
else
	echo "WRONG: ab.o was not produced"
endif
$gtm_dist/mumps -run ab
rm -f ab.o
echo

echo '# Stage 8 : UTF-8 mode, -object value of a and the bytes 0xF0 0x9F 0x98, then A (the start of a 4-byte'
echo '#           character whose 4th byte is not a continuation byte)'
echo '# Command : $gtm_dist/mumps -object=<value> x.m'
echo '# Before the fix : no error, and aA.o was produced (the 3 bytes that are not valid UTF-8 were dropped)'
echo '# With the fix   : expect NOTMNAME for a...A (each of the 3 bytes shown as a "."), ZLNOOBJECT, and no'
echo '#                  object file'
set val = "a`printf '\360\237\230'`A"
$gtm_dist/mumps -object="$val" x.m >& stage8.out
if (`$grep -c 'NOTMNAME, a\.\.\.A is not a valid M name' stage8.out`) then
	echo "PASS: NOTMNAME is for a...A"
else
	echo "WRONG: NOTMNAME for a...A not seen - see stage8.out(x)"
endif
$gtm_tst/com/check_error_exist.csh stage8.out NOTMNAME ZLNOOBJECT
set objs = `ls | $grep '\.o$'`
if ("" == "$objs") then
	echo "PASS: no object file was produced"
else
	echo "WRONG: $objs was produced"
	rm -f $objs
endif
