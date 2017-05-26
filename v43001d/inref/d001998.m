;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
d001998	;
	; this tests three issues that were seen as part of D9B12-001998
	;
	do init
	do d001998a
	do d001998b
	do d001998c
	quit

init	;
	Set unix=$ZVersion'["VMS"
	if unix  do
	.	set mupstr1="$gtm_dist/mupip integ -reg DEFAULT -full -subscript="
	if 'unix  do
	.	set mupstr1="MUPIP integ /reg $DEFAULT /full /subscript="
	set endstr=""""
	set mupipstr=mupstr1_endstr
	quit

d001998a;
	;
	; this is to test that MUPIP INTEG /SUBSCRIPT gives correct and meaningful error messages
	;	in cases where the key range specified was invalid
	;
	write !,"---------------- d001998a testing BEGIN -------------------------------",!
	;
	set zsystr=mupipstr_endstr
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^"_endstr
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_":"_endstr
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"abcd"_endstr	; key does not begin with ^
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:abcd"_endstr	; second key does not begin with ^
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^%abcd"_endstr	; key name begins with %
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:^%abcd"_endstr	; second key name begins with %
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^1abcd"_endstr	; key name does not begin with alphabet or %
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:^1abcd"_endstr	; second key name does not begin with alphabet or %
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^a123b"_endstr	; key name contains alphanumeric characters
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:^a123b"_endstr	; second key name contains alphanumeric characters
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^a123#"_endstr	; key name does not contain alphanumeric characters
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:^a123#"_endstr	; second key name does not contain alphanumeric characters
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^abcd(1,23a)"_endstr	; non-string subscript contains non-numeric characters
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:^abcd(1,23a)"_endstr ; second key non-string subscript contains non-numeric characters
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^abcd(1,)"_endstr	; empty subscript specified
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:^abcd(1,)"_endstr ; second key empty subscript specified
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^abcd(1,"_endstr	; empty subscript specified without right-paren
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:^abcd(1,"_endstr; second key empty subscript specified without right-paren
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^abcd("_endstr	; empty subscript specified without right-paren
	write !,zsystr,!  zsystem zsystr
	set zsystr=mupipstr_"^a:^abcd("_endstr; second key empty subscript specified without right-paren
	write !,zsystr,!  zsystem zsystr
	;
	if unix  set zsystr=mupstr1_"\""^a\(1,\""\""a\""\"":^abcd\(1,2\"""	; first key terminating right parentheses not found
	if 'unix set zsystr=mupstr1_"""^a(1,""""a"""":^abcd(1,2"
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^a:^b:^c"_endstr	; more than two keys specified
	write !,zsystr,!  zsystem zsystr
	;
	; --------------- test that not specifying a terminating double-quote for string subscript issues appropriate error -----
	;
	; SUBSCRIPT qualifier as seen by shell : \"^TEST\(\"\"a\)\"
	; SUBSCRIPT qualifier as seen by MUPIP : "^TEST(""a)"
	; Actual key in db this translates to  : ^TEST("a)
	;
	; SUBSCRIPT qualifier as seen by DCL   : "^TEST(""a)"
	; SUBSCRIPT qualifier as seen by MUPIP : "^TEST(""a)"
	; Actual key in db this translates to  : ^TEST("a)
	;
	if unix  set allstr="\""^TEST\(\""\""a\)\"""
	if 'unix set allstr="""^TEST(""""a)"""
	set zsystr=mupstr1_allstr
	write !,zsystr,!  zsystem zsystr
	;
	; --------------- test that SUBSCRIPT qualifier can be used to input a range of keys ----------------
	;
	set ^TEST("A")=1	; extra records
	set ^TEST("a")=1
	set ^TEST("a","a")=1
	set ^TEST("a","bc")=1
	set ^TEST("a","cba")=1
	set ^TEST("b")=1
	set ^TEST("b","abc")=1
	set ^TEST("b","ba")=1
	set ^TEST("b","c")=1
	set ^TEST("c")=1
	set ^TEST("z")=1	; extra records
	;
	; SUBSCRIPT qualifier as seen by shell : \"^TEST\(\"\"a\"\"\):^TEST\(\"\"b\"\"\)\"
	; SUBSCRIPT qualifier as seen by MUPIP : "^TEST(""a""):^TEST(""b"")"
	; Actual key in db this translates to  : ^TEST("a"):^TEST("b")
	;
	; SUBSCRIPT qualifier as seen by DCL   : "^TEST("a"):^TEST("b")"
	; SUBSCRIPT qualifier as seen by MUPIP : "^TEST("a"):^TEST("b")"
	; Actual key in db this translates to  : ^TEST("a"):^TEST("b")
	;
	if unix  set allstr="\""^TEST\(\""\""a\""\""\):^TEST\(\""\""b\""\""\)\"""
	if 'unix set allstr="""^TEST(""""a""""):^TEST(""""b"""")"""
	set zsystr=mupstr1_allstr
	write !,zsystr,!  zsystem zsystr
	;
	; test some other ranges too
	;
	if unix  set allstr="\""^TEST\(\""\""A\""\""\):^TEST\(\""\""z\""\""\)\"""
	if 'unix set allstr="""^TEST(""""A""""):^TEST(""""z"""")"""
	set zsystr=mupstr1_allstr
	write !,zsystr,!  zsystem zsystr
	;
	if unix  set allstr="\""^TEST\(\""\""b\""\""\):^TEST\(\""\""c\""\""\)\"""
	if 'unix set allstr="""^TEST(""""b""""):^TEST(""""c"""")"""
	set zsystr=mupstr1_allstr
	write !,zsystr,!  zsystem zsystr
	;
	if unix  set allstr="\""^TEST\(\""\""a\""\""\):^TEST\(\""\""c\""\""\)\"""
	if 'unix set allstr="""^TEST(""""a""""):^TEST(""""c"""")"""
	set zsystr=mupstr1_allstr
	write !,zsystr,!  zsystem zsystr
	;
	if unix  set allstr="\""^TEST\(\""\""a\""\"",\""\""a\""\""\):^TEST\(\""\""b\""\"",\""\""abc\""\""\)\"""
	if 'unix set allstr="""^TEST(""""a"""",""""a""""):^TEST(""""b"""",""""abc"""")"""
	set zsystr=mupstr1_allstr
	write !,zsystr,!  zsystem zsystr
	;
	if unix  set allstr="\""^TEST\(\""\""a\""\"",\""\""bc\""\""\):^TEST\(\""\""b\""\"",\""\""ba\""\""\)\"""
	if 'unix set allstr="""^TEST(""""a"""",""""bc""""):^TEST(""""b"""",""""ba"""")"""
	set zsystr=mupstr1_allstr
	write !,zsystr,!  zsystem zsystr
	;
	if unix  set allstr="\""^TEST\(\""\""a\""\"",\""\""cba\""\""\):^TEST\(\""\""b\""\"",\""\""c\""\""\)\"""
	if 'unix set allstr="""^TEST(""""a"""",""""cba""""):^TEST(""""b"""",""""c"""")"""
	set zsystr=mupstr1_allstr
	write !,zsystr,!  zsystem zsystr
	;
	; -------------------------------------------------------------------------------------------------------
	;               test for GVSUBOFLOW error. the test needs to be different in Unix and VMS
	; -------------------------------------------------------------------------------------------------------
	;
	if unix  do umaxinit
	;
	; Construct a long subscript of 1's to test that INTEG can handle it
	set strgen=",1",longstr="1"
	if unix set top=338				; / MAX_KEY_SZ is 1023 on unix, but 255 on vms. So it takes about 4 times
	else  set top=82				;   the subscript length to get a GVSUBOFLOW /
	for i=1:1:top set longstr=longstr_strgen
	;
	; ------ the following SHOULD NOT issue a GVSUBOFLOW error
	;
	set zsystr=mupipstr_"^xxxxx("_longstr_")"_endstr
	if unix write !,"echo """""
	write !,zsystr
	if 'unix zsystem zsystr
	;
	; ------ the following SHOULD     issue a GVSUBOFLOW error
	;
	set zsystr=mupipstr_"^xxxxx("_longstr_strgen_")"_endstr
	if unix write !,"echo """""
	write !,zsystr
	if unix write !,"unset verbose"
	if 'unix zsystem zsystr
	;
	if unix  do umaxclos
	quit

umaxinit;
	;
	; trying to zsystem the mupip command causes an INVSTRLEN error in Unix due to a 205 length limitation
	;	for the zsystem command in GT.M
	; therefore we write the command into a file which we then execute through zsystem
	;
	set file="tmpfile.csh"
	open file
	use file
	write "#!/usr/local/bin/tcsh -f",!
	write "set verbose",!
	quit

umaxclos;
	close file
	use $p
	zsystem "/usr/local/bin/tcsh "_file
	quit

d001998b;
	;
	; this is to test that MUPIP INTEG /SUBSCRIPT does not print false integrity errors in cases where
	;	a lot of data blocks have to be examined for the key-range specified in /SUBSCRIPT
	;
	write !,"---------------- d001998b testing BEGIN -------------------------------",!
	;
	for index=1:1:10000 s ^x(index)=$j(index,200)
	;
	set zsystr=mupipstr_"^x(0)"_endstr
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^x(1)"_endstr
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^x("_index_")"_endstr
	write !,zsystr,!  zsystem zsystr
	;
	set zsystr=mupipstr_"^x("_(index+1)_")"_endstr
	write !,zsystr,!  zsystem zsystr
	;
	quit

d001998c;
	;
	; this is to test MUPIP INTEG /SUBSCRIPT integs only those globals that qualify in the range
	;	specified in the /SUBSCRIPT qualifier.
	;
	; set globals with same length and different lengths using same characters a,b
	; make the records in each global a power of 2 so total of any combination of them uniquely gives a different value
	;
	write !,"---------------- d001998c testing BEGIN -------------------------------",!
	;
	set numkeys=1
	set allkeys="a,ab,b,ba"
	set length=$length(allkeys,",")
	for index=1:1:length  do
	.	set key=$piece(allkeys,",",index)
	.	for keynum=1:1:numkeys  do
	.	.	set str="set ^"_key_"("_keynum_")="_keynum
	.	.	xecute str
	.	set numkeys=numkeys*2
	;
	; generate strings that will integ across different subscript ranges
	;
	for index=0:1:length  do
	.	write "-------------------------------------------------------------------------------------",!
	.	if (index'=0) set beginkey=$piece(allkeys,",",index)
	.	else  set beginkey="A"	; something lesser than all keys in "allkeys"
	.	set zsystr=mupipstr_"^"_beginkey_endstr
	.	write !,zsystr,!
	.	zsystem zsystr
	.	for jindex=(index+1):1:(length+1)  do
	.	.	if (jindex'=(length+1)) set endkey=$piece(allkeys,",",jindex)
	.	.	else  set endkey="z"	; something larger than all keys in "allkeys"
	.	.	set zsystr=mupipstr_"^"_beginkey_":^"_endkey_endstr
	.	.	write !,zsystr,!
	.	.	zsystem zsystr
	.	.	set zsystr=mupipstr_"^"_endkey_":^"_beginkey_endstr
	.	.	write !,zsystr,!
	.	.	zsystem zsystr
	quit

