;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb1152 ;
	do T1^ydb1152
	do T2^ydb1152
	do T3^ydb1152
	do T4^ydb1152
	do T5^ydb1152
	do T6^ydb1152
	do T7^ydb1152
	do T8^ydb1152
	do T9^ydb1152
	do T10^ydb1152
	do T11a^ydb1152

	quit

T0a ;
	write "## Test 0a: Various tests of code paths in sr_port/m_zyencode.c and sr_port/m_zydecode.c.",!
	write "## See also: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2956960973",!
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution) in various error cases below
	; sr_port/m_zyencode.c tests
	write "# Run [s src(""key"")=""value""]",!
	s src("key")="value"
	write "# Run [s lhs=""dst"",rhs=""src"",sub=1]",!
	s lhs="dst",rhs="src",sub=1
	write "# Run [zyen dst(1,=src ; 46]",!
	zyen dst(1,=src ; 46
	write "# Run [zyen ^dst(1,=src ; 62]",!
	zyen ^dst(1,=src ; 62
	write "# Run [zyen @lhs@ ; 80]",!
	zyen @lhs@ ; 80
	write "# Run [zyen @lhs ; 83-86]",!
	zyen @lhs ; 83-86
	write "# Run [zyen 123=src ; 108-109]",!
	zyen 123=src ; 108-109
	write "# Run [zyen dst,=src ; 113-114]",!
	zyen dst,=src ; 113-114
	write "# Run [zyen dst=src(1, ; 123]",!
	zyen dst=src(1, ; 123
	write "# Run [zyen dst=^src(1, ; 130]",!
	zyen dst=^src(1, ; 130
	write "# Run [zyen @lhs=@rhs@ ; 138-139]",!
	zyen @lhs=@rhs@ ; 138-139
	write "# Run [zyen dst=123 ; 151-152]",!
	zyen dst=123 ; 151-152
	write "# Run [zyen dst(sub)=@rhs ; 162-164]",!
	zyen dst(sub)=@rhs ; 162-164
	; sr_port/m_zydecode.c
	write "# Run [s src=1,src(1)=""{""""key"":""""value""""}""]"
	s src=1,src(1)="{""key"":""value""}"
	write "# Run [s lhs=""dst"",rhs=""src"",sub=1]",!
	s lhs="dst",rhs="src",sub=1
	write "# Run [zyde dst(1,=src ; 46]",!
	zyde dst(1,=src ; 46
	write "# Run [zyde ^dst(1,=src ; 62]",!
	zyde ^dst(1,=src ; 62
	write "# Run [zyde @lhs@ ; 80]",!
	zyde @lhs@ ; 80
	write "# Run [zyde @lhs ; 83-86]",!
	zyde @lhs ; 83-86
	write "# Run [zyde 123=src ; 108-109]",!
	zyde 123=src ; 108-109
	write "# Run [zyde dst,=src ; 113]",!
	zyde dst,=src ; 113
	write "# Run [zyde dst=src(1, ; 123]",!
	zyde dst=src(1, ; 123
	write "# Run [zyde dst=^src(1, ; 130]",!
	zyde dst=^src(1, ; 130
	write "# Run [zyde @lhs=@rhs@ ; 138-139]",!
	zyde @lhs=@rhs@ ; 138-139
	write "# Run [zyde dst=123 ; 151-152]",!
	zyde dst=123 ; 151-152
	write "# Run [zyde dst(sub)=@rhs ; 162-164]",!
	zyde dst(sub)=@rhs ; 162-164
	write !

	quit

T0b ;
	write "## Test 0b: Various tests of code paths in sr_port/m_zyencode.c, sr_port/op_indzyencode.c, sr_port/op_zyencode.c, sr_port/op_zydecode.c, sr_port/m_zydecode.c, and sr_port/op_indzydecode.c.",!
	write "## See also: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2956960973",!
	write "## Run a series of commands and expect a series runtime error in each case.",!
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution) in various error cases below
	; sr_port/m_zyencode.c tests
	write "# Run [s src(""key"")=""value""]",!
	s src("key")="value"
	write "# Run [s lhs=""dst"",rhs=""src"",sub=1]",!
	s lhs="dst",rhs="src",sub=1
	write "# Run [zyen dst(1,=src ; 46]",!
	zyen dst(1,=src ; 46
	write "# Run [zyen ^dst(1,=src ; 62]",!
	zyen ^dst(1,=src ; 62
	write "# Run [zyen @lhs@ ; 80]",!
	zyen @lhs@ ; 80
	write "# Run [zyen @lhs ; 83-86]",!
	zyen @lhs ; 83-86
	write "# Run [zyen @lhs=src]",!
	zyen @lhs=src ; 100-102
	write "# Run [zyen 123=src ; 108-109]",!
	zyen 123=src ; 108-109
	write "# Run [zyen dst,=src ; 113-114]",!
	zyen dst,=src ; 113-114
	write "# Run [zyen dst=src(1, ; 123]",!
	zyen dst=src(1, ; 123
	write "# Run [zyen dst=^src(1, ; 130]",!
	zyen dst=^src(1, ; 130
	write "# Run [zyen @lhs=@rhs@ ; 138-139]",!
	zyen @lhs=@rhs@ ; 138-139
	write "# Run [zyen dst=123 ; 151-152]",!
	zyen dst=123 ; 151-152
	write "# Run [zyen dst(sub)=@rhs ; 162-164]",!
	zyen dst(sub)=@rhs ; 162-164
	; sr_port/op_indzyencode.c tests
	write "# Run [s src(""key"")=""value""]",!
	s src("key")="value"
	write "# Run [s rhs=""src"",at=""@rhs""]",!
	s rhs="src",at="@rhs"
	write "# Run [zyen dst=@at ; 76, 78-86]",!
	zyen dst=@at ; 76, 78-86
	write "# Run [s at=123]",!
	s at=123
	write "# Run [zyen dst=@at ;]",!
	zyen dst=@at ;
	; sr_port/op_zyencode.c tests
	write "# Run [zyen ^lhs=^empty ; 103: make sure that ^empty has a $DATA of 0]",!
	zyen ^lhs=^empty ; 103: make sure that ^empty has a $DATA of 0
	write "# Run [s ^src(1,$zch(136))=5]",!
	s ^src(1,$zch(136))=5
	write "# Run [zyen dst=@at ;]",!
	zyen ^dst=^src(1) ; 155
	write "# Run [s src(1,$zch(136))=5]",!
	s src(1,$zch(136))=5
	write "# Run [zyen dst=src(1) ; 355]",!
	zyen dst=src(1) ; 355
	write "# Run [zyen ^dst=src(1) ; 450-458]",!
	zyen ^dst=src(1) ; 450-458
	; sr_port/m_zydecode.c
	write "# Run [s src=1,src(1)=""{""""key"":""""value""""}""]"
	s src=1,src(1)="{""key"":""value""}"
	write "# Run [s lhs=""dst"",rhs=""src"",sub=1]",!
	s lhs="dst",rhs="src",sub=1
	write "# Run [zyde dst(1,=src ; 46]",!
	zyde dst(1,=src ; 46
	write "# Run [zyde ^dst(1,=src ; 62]",!
	zyde ^dst(1,=src ; 62
	write "# Run [zyde @lhs@ ; 80]",!
	zyde @lhs@ ; 80
	write "# Run [zyde @lhs ; 83-86]",!
	zyde @lhs ; 83-86
	write "# Run [zyde @marray=@json ; 100-102] (also tests sr_port/format_key_mvals.c:48, per https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2973059636)",!
	s marray="src(1)",json="src"
	zyde @marray=@json
	write "# Run [zyde 123=src ; 108-109]",!
	zyde 123=src ; 108-109
	write "# Run [zyde dst=src(1, ; 123]",!
	zyde dst=src(1, ; 123
	write "# Run [zyde dst=^src(1, ; 130]",!
	zyde dst=^src(1, ; 130
	write "# Run [zyde @lhs=@rhs@ ; 138-139]",!
	zyde @lhs=@rhs@ ; 138-139
	write "# Run [zyde dst=123 ; 151-152]",!
	zyde dst=123 ; 151-152
	write "# Run [zyde dst(sub)=@rhs ; 162-164]",!
	zyde dst(sub)=@rhs ; 162-164
	; sr_port/op_indzydecode.c
	s src=1,src(1)="{""key"":""value""}"
	s rhs="src",at="@rhs"
	write "# Run [zyde dst=@at ; 76, 78-86]",!
	zyde dst=@at ; 76, 78-86
	s at=123
	write "# Run [zyde dst=@at ; 88]",!
	zyde dst=@at ; 88
	; sr_port/op_zydecode.c
	s ^src=0,^src(1)="{""key"":""value""}"
	write "# Run [zyde dst=^src ; 275-281]",!
	zyde dst=^src ; 275-281
	write "# Run [zyde dst=^src ; 328-332]",!
	k ^src(1) s ^src=1
	zyde dst=^src ; 328-332
	write "# Run [zyde ^dst(1)=src ; 542-553, 561]",!
	s src=1,src(1)="{""key"":""value""}"
	zyde ^dst(1)=src ; 542-553, 561
	write "# Run [zyde ^dst=src ; 550-559]",!
	s src=2,src(1)="{""key"":"
	zyde ^dst=src ; 550-559

	quit

T1 ;
	write "#### Test 1: ZYENCODE error cases",!
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution) in various error cases below
	write "# Run [set src(""key1"")=""value1""]",!
	set src("key1")="value1"
	write "# Run [set src(""key1"",""key2"")=""value1""]",!
	set src("key1","key2")="value1"
	write "# Run [set ^src(""key1"")=""value1""]",!
	set ^src("key1")="value1"
	write "# Run [set ^src(""key1"",""key2"")=""value1""]",!
	set ^src("key1","key2")="value1"
	write !

	write "### Test 1a: Source is descendant of destination (%YDB-E-ZYENCODEDESC)",!
	write "# Run [zyencode src(""key1"")=src(""key1"",""key2"")]",!
	write "# Expect '%YDB-E-ZYENCODEDESC, ZYENCODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zyencode src("key1")=src("key1","key2")
	write "# Run [set x=""a""]",!
	set x="a"
	write "# Run [zyencode x=x]",!
	write "# Expect '%YDB-E-ZYENCODEDESC, ZYENCODE operation not possible. x is a descendant of x",!
	zyencode x=x
	write !

	write "### Test 1b: Destination is descendant of source (%YDB-E-ZYENCODEDESC)",!
	write "# Run [zyencode src(""key1"",""key2"")=src(""key1"")]'",!
	write "# Expect '%YDB-E-ZYENCODEDESC, ZYENCODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zyencode src("key1","key2")=src("key1")
	write "# Run [zyencode ^src(""key1"",""key2"")=^src(""key1"")]'",!
	write "# Expect '%YDB-E-ZYENCODEDESC, ZYENCODE operation not possible. ^src(""key1"",""key2"") is a descendant of ^src(""key1"")'",!
	zyencode ^src("key1","key2")=^src("key1")
	write !

	write "### Test 1c: Undefined local variable passed as source raises %YDB-E-ZYENCODESRCUNDEF",!
	write "# Run [zyencode dest=notanlvn]'",!
	write "# Expect '%YDB-E-ZYENCODESRCUNDEF'",!
	zyencode dest=notanlvn
	write !

	write "### Test 1d: Errors from the underlying ydb_encode_s()",!
	write "## Test $ZSTATUS is set and %YDB-W-ZYENCODEINCOMPL issued",!
	write "# Run [set x=$ZCH(167)]",!
	set x=$ZCH(167)
	write "# Run [zyencode dest=x]",!
	write "# Expect '%YDB-W-ZYENCODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONENCODEERROR",!
	zyencode dest=x
	write "## Test invalid node value between multiple nodes at same subscript level",!
	kill ^y,z
	write "# Run [set ^y=3,^y(1)=""value1"",^y(2)=$ZCH(167),^y(3)=""value3""]",!
	set ^y=3,^y(1)="value1",^y(2)=$ZCH(167),^y(3)="value3"
	write "# Run [zyencode z=^y]",!
	write "# Expect '%YDB-W-ZYENCODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONENCODEERROR",!
	zyencode z=^y
	write "# Run [zyencode z=^y(2)]",!
	write "# Expect '%YDB-W-ZYENCODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONENCODEERROR",!
	zyencode z=^y(2)
	write "## Test invalid subscript value in separate subtree under a single root node",!
	kill ^y,z
	write "# Run [set ^y(1,2,3)=1,^y(4,$ZCH(167),6)=2]",!
	set ^y(1,2,3)=1,^y(4,$ZCH(167),6)=2
	write "# Run [zyencode z=^y]",!
	write "# Expect '%YDB-W-ZYENCODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONENCODEERROR",!
	zyencode z=^y
	write "## Test invalid subscript value in subtree under a single root node",!
	kill ^y,z
	write "# Run [set ^y(1)=1,^y(1,$ZCH(167))=2]",!
	set ^y(1)=1,^y(1,$ZCH(167))=2
	write "# Run [zyencode z=^y]",!
	write "# Expect '%YDB-W-ZYENCODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONENCODEERROR",!
	zyencode z=^y
	write "## Test invalid subscript value in subtree with its own subtree under a single root node",!
	kill ^y,z
	write "# Run [set ^y(1)=1,^y(1,$ZCH(167))=2,^y(1,$ZCH(167),3)=3]",!
	set ^y(1)=1,^y(1,$ZCH(167))=2,^y(1,$ZCH(167),3)=3
	write "# Run [zyencode z=^y]",!
	write "# Expect '%YDB-W-ZYENCODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONENCODEERROR",!
	zyencode z=^y

	write !
	quit

T2 ;
	kill src
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution) in various error cases below

	write "#### Test 2: ZYDECODE error cases",!
	write "# Run [set src(""key1"")=""value1""]",!
	set src("key1")="value1"
	write "# Run [set src(""key1"",""key2"")=""value1""]",!
	set src("key1","key2")="value1"
	write "# Run [set ^src(""key1"")=""value1""]",!
	set ^src("key1")="value1"
	write "# Run [set ^src(""key1"",""key2"")=""value1""]",!
	set ^src("key1","key2")="value1"
	write !

	write "### Test 2a: Source is descendant of destination (%YDB-E-ZYDECODEDESC)",!
	write "# Run [zydecode src(""key1"")=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEDESC, ZYDECODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zydecode src("key1")=src("key1","key2")
	write "# Expect '%YDB-E-ZYDECODEDESC, ZYDECODE operation not possible. ^src(""key1"",""key2"") is a descendant of ^src(""key1"")'",!
	zydecode ^src("key1")=^src("key1","key2")
	write !

	write "### Test 2b: Destination is descendant of source (%YDB-E-ZYDECODEDESC)",!
	write "# Run [zydecode src(""key1"",""key2"")=src(""key1"")]'",!
	write "# Expect '%YDB-E-ZYDECODEDESC, ZYDECODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zydecode src("key1","key2")=src("key1")
	write "# Run [zydecode ^src(""key1"",""key2"")=^src(""key1"")]'",!
	write "# Expect '%YDB-E-ZYDECODEDESC, ZYDECODE operation not possible. ^src(""key1"",""key2"") is a descendant of ^src(""key1"")'",!
	zydecode ^src("key1","key2")=^src("key1")
	write !

	write "### Test 2c: Various %YDB-E-ZYDECODEWRONGCNT scenarios",!
	write "## T2c1: Root node of source = 0 (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set src=0]",!
	set src=0
	write "# Run [zydecode dest=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode dest=src("key1","key2")
	write !
	write "## T2c2: Root node of source < 0 (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set src=-1]",!
	set src=-1
	write "# Run [zydecode dest=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode dest=src("key1","key2")
	write !
	write "## T2c3: Root node of source = non-numeric string (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set src=""abc""]",!
	set src="abc"
	write "# Run [zydecode dest=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode dest=src("key1","key2")
	write !
	write "## T2c4: Root node of source = positive floating point value (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set src=1.1]",!
	set src=1.1
	write "# Run [zydecode dest=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode dest=src("key1","key2")
	write !
	write "## T2c5: Source is empty LVN, destination is empty GVN (%YDB-E-ZYDECODEWRONGCNT)",!
	kill ^a,a
	write "# Run [zydecode ^a=a]",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode ^a=a
	write !
	write "## T2c6: Source is empty GVN, destination is the same GVN (%YDB-E-ZYDECODEWRONGCNT)",!
	kill ^b
	write "# Run [zydecode ^b=^b]",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode ^b=^b
	write !
	write "## T2c7: Source is empty LVN, destination is the same LVN (%YDB-E-ZYDECODEWRONGCNT)",!
	kill b
	write "# Run [zydecode b=b]",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode b=b
	write !
	write "## T2c8: Source is empty LVN, destination is the different empty LVN (%YDB-E-ZYDECODEWRONGCNT)",!
	kill c,d
	write "# Run [zydecode c=d]",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode c=d
	write !
	write "## T2c9: Source is empty LVN, destination is an empty GVN (%YDB-E-ZYDECODEWRONGCNT)",!
	kill ^d,e
	write "# Run [zydecode ^d=e]",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode ^d=e
	write !
	write "## T2c10: Source is LVN set to 0 (explicitly indicating an empty JSON tree), destination is an empty GVN or LVN (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set d=0]",!
	set d=0
	write "# Run [zydecode ^e=d]",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode ^e=d
	write "# Run [zydecode e=d]",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode e=d
	write !

	write "## Test 2d: LVN in series starting from root node's positive integer doesn't exist (%YDB-E-LVUNDEF)",!
	write "# Run:",!
	write "#  [kill]",!
	kill
	write "#  [set src=3]",!
	set src=3
	write "#  [set src(1)=""{""""key1"""":""""value1"""",""]",!
	set src(1)="{""key1"":""value1"","
	write "#  (skip setting src(2))",!
	write "#  [set src(3)=""""key3"""":""""value3""""}""]",!
	set src(3)="""key3"":""value3""}"
	write "# Run [zydecode dest=src]'",!
	write "# Expect '%YDB-E-LVUNDEF'",!
	zydecode dest=src
	kill
	write !

	write "## Test 2e: GVN in series starting from root node's positive integer doesn't exist (%YDB-E-GVUNDEF)",!
	write "# Run:",!
	write "#  [set ^src=3]",!
	set ^src=3
	write "#  [set ^src(1)=""{""""key1"""":""""value1"""",""]",!
	set ^src(1)="{""key1"":""value1"","
	write "#  (skip setting ^src(2))",!
	write "#  [set ^src(3)=""""key3"""":""""value3""""}""]",!
	set ^src(3)="""key3"":""value3""}"
	write "# Run [zydecode ^dest=^src]",!
	write "# Expect '%YDB-E-GVUNDEF'",!
	zydecode ^dest=^src
	write !

	write "## Test 2f: Error from the underlying ydb_decode_s(): $ZSTATUS is set and %YDB-W-ZYDECODEINCOMPL issued",!
	set ^src=1
	set ^src(1)="{""key1"":"""_$ZCH(167)_"""}"
	write "# Expect '%YDB-W-ZYDECODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONINVALIDJSON",!
	zydecode dest=^src
	write !

	write "## Test 2g: ZYDECODEINCOMPL and JANSSONINVALIDJSON errors issued when using ZYDECODE to decode a node containing `$C(0)` from a node previously encoded with ZYENCODE",!
	write "# Run [x(1)=$c(0)]",!
	set x(1)=$c(0)
	write "# Run [zyencode y=x]",!
	zyencode y=x
	write "# Run [zydecode z=y]",!
	write "# Expect '%YDB-W-ZYDECODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONINVALIDJSON",!
	zydecode z=y
	write !

	write "## Test 2h: ZYDECODEINCOMPL and GVSUBOFLOW errors issued when using subscripts that meet or exceed key size (256 in this case)",!
	write "# Run [set x($justify(1,256))=1]",!
	kill x,y,z,^z
	set x($justify(1,256))=1
	write "# Run [zyencode y=x]",!
	zyencode y=x
	write "# Run [zyencode ^z=y]",!
	write "# Expect '%YDB-W-ZYDECODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-GVSUBOFLOW",!
	zydecode ^z=y
	write "# Run [set x($justify(1,64),$justify(1,64),$justify(1,64),$justify(1,64))=1]",!
	kill x,y,z,^z
	set x($justify(1,64),$justify(1,64),$justify(1,64),$justify(1,64))=1
	write "# Run [zyencode y=x]",!
	zyencode y=x
	write "# Run [zyencode ^z=y]",!
	write "# Expect '%YDB-W-ZYDECODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-GVSUBOFLOW",!
	zydecode ^z=y
	write "# Run [set x($justify(1,257))=1]",!
	kill x,y,z,^z
	set x($justify(1,257))=1
	write "# Run [zyencode y=x]",!
	zyencode y=x
	write "# Run [zyencode ^z=y]",!
	write "# Expect '%YDB-W-ZYDECODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-GVSUBOFLOW",!
	zydecode ^z=y
	write "# Run [set x($justify(1,65),$justify(1,64),$justify(1,64),$justify(1,64))=1]",!
	kill x,y,z,^z
	set x($justify(1,65),$justify(1,64),$justify(1,64),$justify(1,64))=1
	write "# Run [zyencode y=x]",!
	zyencode y=x
	write "# Run [zyencode ^z=y]",!
	write "# Expect '%YDB-W-ZYDECODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-GVSUBOFLOW",!
	zydecode ^z=y
	write !

	quit

T3 ;
	write "### Test 3: ZYENCODE properly handles input trees containing ~1MiB of data (YDB max string length)",!
	write "### See also the discussion at: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854162278",!

	write "## Test 3a: ZYENCODE properly handles input trees containing exactly 1MiB (1048576 bytes) of data",!
	do runZyencodeTest^ydb1152("T3a",1048576)
	write !

	write "## Test 3b: ZYENCODE properly handles input trees containing exactly 1MiB-1 (1048575 bytes) of data",!
	do runZyencodeTest^ydb1152("T3b",1048575)
	write !

	write "## Test 3c: ZYENCODE properly handles input trees containing exactly 1MiB-2 (1048574 bytes) of data",!
	do runZyencodeTest^ydb1152("T3c",1048574)
	write !

	write "## Test 3d: ZYENCODE properly handles input trees containing exactly 1MiB+1 (1048577 bytes) of data",!
	do runZyencodeTest^ydb1152("T3d",1048577)
	write !

	write "## Test 3e: ZYENCODE properly handles input trees containing exactly 1MiB+2 (1048578 bytes) of data",!
	do runZyencodeTest^ydb1152("T3e",1048578)
	write !

	quit

T4 ;
	write "### Test 4: ZYENCODE properly handles input trees containing random data sizes and arbitrary data types",!
	write "### See also the discussion at: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854162278",!
	write "## Test 4a: ZYENCODE properly handles input trees containing random data sizes, up to 3MiB",!
	do runZyencodeTest^ydb1152("T4a",$RANDOM(1048576*3))
	write "## Test 4b: ZYENCODE properly handles input trees containing random data sizes, < 1MiB",!
	do runZyencodeTest^ydb1152("T4b",$RANDOM(1048576))
	write "## Test 4c: ZYENCODE properly handles input nodes containing arbitrary data types",!
	kill ^x,^y,^z,z
	write "# Run [set ^x=$C(0)_""null""]",!
	set ^x=$C(0)_"null"
	write "# Run [zyencode z=^x]",!
	write "# Expect no errors",!
	zyencode z=^x
	write "# Run [set ^x=$C(0)_""true""]",!
	set ^y=$C(0)_"true"
	write "# Run [zyencode z=^y]",!
	write "# Expect no errors",!
	zyencode z=^y
	write "# Run [set ^x=$C(0)_""false""]",!
	set ^z=$C(0)_"false"
	write "# Run [zyencode z=^z]",!
	write "# Expect no errors",!
	zyencode z=^z
	write "# Run [set ^x(1)=1.1]",!
	set ^x(1)=1.1
	write "# Run [zyencode z=^z]",!
	write "# Expect no errors",!
	zyencode z=^z
	write !

	quit

T5 ;
	write "### Test 5: ZYDECODE properly handles input trees containing ~1MiB of data (YDB max string length)",!
	write "### See also the discussion at: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854162278",!

	write "## Test 5a: ZYDECODE properly handles input trees containing exactly 1MiB (1048576 bytes) of data",!
	do runZydecodeTest^ydb1152("T5a",1048576)
	write !

	write "## Test 5b: ZYDECODE properly handles input trees containing exactly 1MiB-1 (1048575 bytes) of data",!
	do runZydecodeTest^ydb1152("T5b",1048575)
	write !

	write "## Test 5c: ZYDECODE properly handles input trees containing exactly 1MiB-2 (1048574 bytes) of data",!
	do runZydecodeTest^ydb1152("T5c",1048574)
	write !

	write "## Test 5d: ZYDECODE properly handles input trees containing exactly 1MiB+1 (1048577 bytes) of data",!
	do runZydecodeTest^ydb1152("T5d",1048577)
	write !

	write "## Test 5e: ZYDECODE properly handles input trees containing exactly 1MiB+2 (1048578 bytes) of data",!
	do runZydecodeTest^ydb1152("T5e",1048578)
	write !

	quit

T6 ;
	write "### Test 6: ZYDECODE properly handles input trees containing arbitrary types and random data sizes ",!
	write "### See also the discussion at: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854162278",!
	write "## Test 6a: ZYDECODE properly handles input trees containing arbitrary (random) data sizes, up to 3MiB",!
	do runZydecodeTest^ydb1152("T6a",$RANDOM(1048576*3))
	write "## Test 6b: ZYDECODE properly handles input trees containing arbitrary (random) data sizes, < 1MiB",!
	do runZydecodeTest^ydb1152("T6b",$RANDOM(1048576))
	write !
	write "## Test 6c: ZYDECODE properly handles input trees containing arbitrary data types",!
	kill f,g
	write "# Run [set f=2,f(1)=""{""""array"""": [1, 2, 3, 4, 5], """"key"""": """"value"""", """"null"""": "",f(2)=""null, """"string"""": """"null"""", """"real"""": 3.1459, """"bool1"""": true, """"bool2"""": false}""",!
	set f=2,f(1)="{""array"": [1, 2, 3, 4, 5], ""key"": ""value"", ""null"": ",f(2)="null, ""string"": ""null"", ""real"": 3.1459, ""bool1"": true, ""bool2"": false}"
	write "# Run [zydecode g=f]",!
	write "# Expect decode to complete without error",!
	zydecode g=f
	write "# ZWRITE decoded output [zwrite g]",!
	zwrite g
	write !
	quit

T7 ;
	write "### Test 7: Data encoded with ZYENCODE can be decoded with ZYDECODE and re-encoded with ZYENCODE to produce the same result as the initial ZYENCODE call",!
	; Initialize test variables
	set testNum="T7"
	set dataSize=$RANDOM(1048576*3)
	do initTest^ydb1152(testNum)
	; Store subscripted GVN values in abbreviated LVNs for readability
	set in=^testConfig(testNum,"in")
	set out=^testConfig(testNum,"out")
	set supp=^testConfig(testNum,"supp")
	set enc=^testConfig(testNum,"enc")

	write "# Run the [populateTree] label to generate a tree with "_dataSize_" bytes of data in the ["""_in_"""] variable",!
	do populateTree^ydb1152(testNum,dataSize)
	write "# Run [zyencode "_enc_"="_in_"] to encode the generated tree into JSON format in the "_enc_" variable",!
	zyencode @enc=@in
	write "# Log generated JSON",!
	do logJSONToFile^ydb1152(testNum_"a",enc)
	write "# Confirm encoding output is valid",!
	do validateEncodedOutput^ydb1152(testNum,dataSize,enc)

	write "# Run [zydecode "_out_"="_enc_"] to decode the encoded tree from JSON format into the "_out_" variable",!
	zydecode @out=@enc
	do validateDecodedOutput^ydb1152(testNum)

	set file="node-"_testNum_"b-"_dataSize_".out"
	set openParen=$find(out,"(")
	set outBase=$select(openParen:$extract(out,0,openParen-2),1:out)
	write "# Log "_outBase_" to "_file_" file",!
	open file:(newversion:stream:nowrap:chset="M")
	use file
	set $x=0 ; Prevent newline
	zwrite @outBase ; Log the node to a file
	close file

	write "# Run [zyencode "_supp_"="_out_"] to encode the generated tree into JSON format in the "_supp_" variable",!

	zyencode @supp=@out
	set file="node-"_testNum_"c-"_dataSize_".out"
	set openParen=$find(supp,"(")
	set suppBase=$select(openParen:$extract(supp,0,openParen-2),1:supp)
	write "# Log "_suppBase_" to "_file_" file",!
	open file:(newversion:stream:nowrap:chset="M")
	use file
	set $x=0 ; Prevent newline
	zwrite @suppBase ; Log the node to a file
	close file

	write "# Log generated JSON",!
	do logJSONToFile^ydb1152(testNum_"b",supp)
	write "# Confirm encoding output is valid",!
	do validateEncodedOutput^ydb1152(testNum,dataSize,supp)
	write !

	quit

T8 ;
	write "### Test 8: No ZYDECODEWRONGCNT for trees with many subscripts at the same level",!
	write "### For details, see discussion at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2844227740",!
	write "## Test 8a: Using global variables",!
	set subslen=10,vallen=2**14
	write "# Set a random length subscript, up to ("_subslen_")",!
	set subs=$$^%RANDSTR(subslen)
	write "# Set a random length value, up to ("_vallen_")",!
	set val=$$^%RANDSTR(vallen)

	kill ^x,^y,^z
	set maxi=10000
	write "# Set "_maxi_" global variable nodes to the random value",!
	for i=1:1:maxi set ^x(subs,i)=val
	write "# Use ZYENCODE to encode the nodes",!
	zyencode ^y=^x
	write "# Use ZYDECODE to decode the nodes, expect no ZYDECODEWRONGCNT error",!
	zydecode ^z=^y

	write "## Test 8b: Using local variables"
	set subslen=10,vallen=2**14
	write "# Set a random length subscript, up to ("_subslen_")",!
	set subs=$$^%RANDSTR(subslen)
	write "# Set a random length value, up to ("_vallen_")",!
	set val=$$^%RANDSTR(vallen)

	kill x,y,z
	set maxi=10000
	write "# Set "_maxi_" local variable nodes to the random value",!
	for i=1:1:maxi set x(subs,i)=val
	write "# Use ZYENCODE to encode the nodes",!
	zyencode y=x
	write "# Use ZYDECODE to decode the nodes, expect no ZYDECODEWRONGCNT error",!
	zydecode z=y
	write !

	quit

T9 ;
	write "### Test 9: Confirm no errors for subscripts or values less than the string length of 4294967295",!
	write "## Test 9a: Using global variables",!
	set maxsubslen=64,maxvallen=2**14
	write "# Set a random length subscript, up to the maximum ("_maxsubslen_")",!
	set subs=$$^%RANDSTR($random(maxsubslen))
	write "# Set a random length value, up to the maximum ("_maxvallen_")",!
	set val=$$^%RANDSTR($random(maxvallen))
	kill ^x,^y,^z
	set maxi=10000
	write "# Set "_maxi_" global variable nodes to the random value",!
	for i=1:1:maxi set ^x(subs,i)=val
	write "# Use ZYENCODE to encode the nodes, expect no errors",!
	zyencode ^y=^x
	write "# Use ZYDECODE to decode the nodes, expect no ZYDECODEWRONGCNT error",!
	zydecode ^z=^y

	write "## Test 9b: Using local variables",!
	set maxsubslen=64,maxvallen=2**14
	write "# Set a random length subscript, up to the maximum length ("_maxsubslen_")",!
	set subs=$$^%RANDSTR($random(maxsubslen))
	write "# Set a random length value, up to the maximum ("_maxvallen_")",!
	set val=$$^%RANDSTR($random(maxvallen))
	kill x,y,z
	set maxi=10000
	write "# Set "_maxi_" local variable nodes to the random value",!
	for i=1:1:maxi set x(subs,i)=val
	write "# Use ZYENCODE to encode the nodes, expect no errors",!
	zyencode y=x
	write "# Use ZYDECODE to decode the nodes, expect no ZYDECODEWRONGCNT error",!
	zydecode z=y
	write !

	quit

T10 ;
	write "### Test 10: ZYENCODE behavior with null subscripts",!
	write "## Test 10a: No assert failure for ZYENCODE with null subscript and string node value",!
	write "## See: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854172324",!
	set lcl(5,"")="five_null"
	zyencode ^x=lcl(5,"")
	write "## Test 10b: No hang for ZYENCODE with null subscript and integer node value",!
	write "## See: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854172331",!
	set x(5,"")=1
	zyencode ^y=x
	write !

	quit

T11a ;
	write "### Test 11: ZYDECODE can nest with triggers",!
	write "### See: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854196286",!
	write "## Test 11a: Trigger combination 1, expect no ASSERT failures",!
	do T11b^ydb1152("T11c")
	write "## Test 17b: Trigger combination 2, expect no ASSERT failures",!
	do T11b^ydb1152("T11d")
	write !

	quit

T11b(tnum) ;
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution)
	write "# Set triggers",!
	set X=$ztrigger("ITEM","-*")
	set X=$ztrigger("ITEM","+^x(*) -commands=S -xecute=""do "_tnum_"^ydb1152""")
	write "# Set nodes in LVN",!
	for i=1:1:1000 set x(i)=$j(i,20)
	write "# Run ZYENCODE to encode nodes into ^x",!
	zyencode ^x=x
	write "# Run MERGE of ^x into ^y",!
	merge ^y=^x
	write "# Kill ^x",!
	kill ^x
	write "# Run ZYDECODE of ^y into ^x",!
	write "# Expect no ASSERT failure",!
	zydecode ^x=^y

	quit

T11c ;
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution)
	set a=1
	zyencode b=a
	zydecode c=b
	quit

T11d ;
	set a=1
	zyencode ^b=a
	zydecode c=^b
	quit



T13a ;
	write "set maxlen=2**20",!
	write "set maxstr=$$^%RANDSTR(maxlen)",!
	for i=1:1:31 do
	. set xstr="set x(" for j=1:1:i-1 set xstr=xstr_"maxstr,"
	. set xstr=xstr_"maxstr)=maxstr"
	. write xstr,!
	write "zyencode y=x zydecode z=y"

	quit

T13b ;
	write "set x($justify(1,2**20))=1",!
	write "zyencode y=x",!
	write "zydecode ^z=y",!

	quit

T14a ;
	write "# Start test routine",!
	write "# Choose random subscript and value lengths:",!
	set maxsubslen=32,maxvallen=256
	set subslen=$random(maxsubslen)+1
	set vallen=$random(maxvallen)+1
	set ^ready=0
	set break=$RANDOM(3)
	zwrite subslen,vallen

	set subs=$$^%RANDSTR(subslen)
	set val=$$^%RANDSTR(vallen)

	kill ^x,^y,^z
	set maxi=100000
	set ^T14=$job
	write "# Set "_maxi_" nodes to the random value",!
	for i=1:1:maxi set ^x(subs,i)=val

	write "# Run ZYENCODE to encode the tree",!
	set:break=0 ^ready=1
	zyencode ^y=^x
	write "# Run ZYDECODE to decode the newly encoded tree",!
	set:break=1 ^ready=1
	zydecode ^z=^y

	write "# ZKILL each node in the decoded tree",!
	set:break=2 ^ready=1
	for i=1:1:maxi zkill:^z(subs,i)=val ^z(subs,i)
	write "# Confirm all decoded nodes killed",!
	if $data(^z) write "TEST-E-FAIL",!  zshow "s"  zwrite ^z  halt

	quit

T14b ;
	write "# Wait for test routine to signal ready for termination",!
	for i=1:1  quit:$get(^ready,0)  hang 0.001
	write "# Issue MUPIP INTRPT to test routine",!
	zsystem "$ydb_dist/mupip intrpt "_^T14

	quit

T15 ;
	set maxsubslen=32,maxvallen=256
	set subslen=maxsubslen
	set vallen=maxvallen
	zwrite subslen,vallen
	write "# Randomly generate a subscript and value",!
	write "# Run [set subs=$$^%RANDSTR(subslen)]",!
	set subs=$$^%RANDSTR(subslen)
	write "# Run [set val=$$^%RANDSTR(vallen)]",!
	set val=$$^%RANDSTR(vallen)

	kill ^x,^y
	set maxi=10000
	write "# Set "_maxi_" nodes containing the random subscript to the random value",!
	for i=1:1:maxi s ^x(subs,i)=val
	write "# Run ZYENCODE to encode the tree",!
	zyencode ^y=^x
	write "# Run ZYDECODE to decode the newly encoded tree",!
	zydecode ^z=^y
	write "# ZKILL each node in the decoded tree",!
	for i=1:1:maxi zkill:^z(subs,i)=val ^z(subs,i)
	write "# Confirm all decoded nodes killed",!
	if $data(^z) write "TEST-E-FAIL",!  zshow "s"  halt

	quit

T16 ;
	write "set x($j(1,256))=1",!
	write "zyencode ^y=x",!
	write "zyencode @""y""=^x",!

	quit

T17a ;
	set ^stop=0,^njobs=32
	set tnum="T17"
	set totaljobs=^njobs*2

	write "# Set nodes for encoding",!
	kill ^x
	; Loop for a max of 15 seconds OR 10000 iterations whichever comes first.
	set start=$horolog
	for i=1:1:10000  quit:$$^difftime($horolog,start)>15  set ^x(i)=$j(i,20)

	write "# Start "_^njobs_" child jobs to test ZYDECODEINCMPL error scenario",!
	for i=1:1:^njobs do
	. set jobstr="job "_tnum_"b^ydb1152:(output="""_tnum_".mjo"_i_""":error="""_tnum_".mje"_i_""")"
	. xecute jobstr
	. set ^job(i)=$zjob,^jobindex($zjob)=i

	write "# Start "_^njobs_" child jobs to test ZYENCODEINCMPL error scenario",!
	for i=1:1:^njobs do
	. set jobnum=i+^njobs
	. set jobstr="job "_tnum_"c^ydb1152:(output="""_tnum_".mjo"_jobnum_""":error="""_tnum_".mje"_jobnum_""")"
	. xecute jobstr
	. set ^job(jobnum)=$zjob,^jobindex($zjob)=jobnum

	write "# Wait for all child processes to die from ZYENCODEINCOMPL and ZYDECODEINCOMPL error scenarios, i.e. "_totaljobs_" processes",!
	for i=1:1:totaljobs  do
	. set pid=^job(i)
	. for  quit:'$zgetjpi(pid,"ISPROCALIVE")  hang 0.1
	write "# All child processes terminated",!

	quit

T17b ;
	; Test for ZYDECODEINCOMPL
	set $etrap="zwrite $zstatus  trollback:$tlevel  halt"
	; Loop for a max of 15 seconds OR 10000 iterations whichever comes first.
	set start=$horolog
	for i=1:1:10000 do  quit:$$^difftime($horolog,start)>15
	. tstart ():serial
	. zyencode ^y($j)=^x
	. zydecode ^z($j)=^y($j)
	. tcommit
	quit

T17c ;
	; Test for ZYENCODEINCOMPL
	set $etrap="zwrite $zstatus  trollback:$tlevel  halt"
	; Loop for a max of 15 seconds OR 10000 iterations whichever comes first.
	set start=$horolog
	for i=1:1:10000 do  quit:$$^difftime($horolog,start)>15
	. tstart ():serial
	. zyencode ^w($j)=^x
	. tcommit
	quit

T19 ;
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution)
	set x="test"
	zyencode src=x
	set X=$ztrigger("ITEM","+^dst -commands=S -xecute=""do T19a^ydb1152""")
	zydecode ^dst=src

	set X=$ztrigger("ITEM","+^dst2 -commands=S -xecute=""do T19b^ydb1152""")
	zydecode ^dst2=src
	quit

T19a ;
	write "# Test sr_port/op_zydecode_arg.c:82"
	zydecode ^dst=src
	quit

T19b ;
	write "# Test sr_port/op_zydecode_arg.c:120"
	merge ^src=src
	zydecode dst=^src
	quit

T20 ;
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution)
	write "## Test 20a: Decoding a JSON array with more than 31 elements works without issue",!
	kill f
	write "# Run [set f=2,f(1)=""{""""array"""": [1, 2, 3, 4, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], """"key"""": """"value"""", """"null"""": """,!
	set f=2,f(1)="{""array"": [1, 2, 3, 4, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], ""key"": ""value"", ""null"": "
	write "# Run [set f(2)=""null, """"string"""": """"null""""}""]",!
	set f(2)="null, ""string"": ""null""}"
	write "# Run [zydecode g=f]",!
	write "# Expect no error messsages to occur",!
	zydecode g=f
	write "## Test 20b: Encoding the M array created by 2i correctly creates a JSON array without issue",!
	kill f
	write "# Run [zyencode f=g(""array"")]",!
	write "# Expect no error messages to occur, and a proper JSON array to be encoded",!
	zyencode f=g("array")
	write f(1),!
	write !

	quit

T21 ;
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; Needed to transfer control to next M line after error (instead of stopping execution)
	write "## Test 21a: Encoding an M array that does not match the condition for a JSON array, it starts with a subscript other than 0",!
	kill marray
	write "# Run [set marray(0)=""zero"",marray(1)=""one"",marray(2)=""two"",marray(3)=""three"",marray(4)=""four"",marray(5)=""five"",marray(6)=""six""]",!
	set marray(0)="zero",marray(1)="one",marray(2)="two",marray(3)="three",marray(4)="four",marray(5)="five",marray(6)="six"
	write "# Run [set marray(7)=""seven"",marray(8)=""eight"",marray(9)=""nine"",marray(10)=""ten"",marray(11)=""eleven"",marray(12)=""twelve""]",!
	set marray(7)="seven",marray(8)="eight",marray(9)="nine",marray(10)="ten",marray(11)="eleven",marray(12)="twelve"
	write "# Run [set marray(-1)=""negative one""]",!
	set marray(-1)="negative one"
	write "# Run [zyencode json=marray]",!
	zyencode json=marray
	write json(1),!
	write "# Run [kill marray(-1)]",!
	kill marray(-1)
	write "## Test 21b: Encoding an M array that does not match the condition for a JSON array, it doesn't strictly increment by an integer for each element",!
	write "# Run [kill marray(5)]",!
	kill marray(5)
	write "# Run [zyencode json=marray]",!
	zyencode json=marray
	write json(1),!
	write "# Run [set marray(5)=""five""]",!
	set marray(5)="five"
	write "## Test 21c: Encoding an M array that does not match the condition for a JSON array, it has a subscript at the same level which is not an integer",!
	write "# Run [set marray(""key"")=""value""]",!
	set marray("key")="value"
	write "# Run [zyencode json=marray]",!
	zyencode json=marray
	write json(1),!
	write "# Run [kill marray(""key"")]",!
	kill marray("key")
	write "## Test 21d: Encoding an M array that does not match the condition for a JSON array, its parent node contains data",!
	write "# Run [set marray=""numbers""]",!
	set marray="numbers"
	write "# Run [zyencode json=marray]",!
	zyencode json=marray
	write json(1),!
	write !

	quit

initTest(testNum)
	; Randomly choose whether to use a global variable for input
	set inVar=$select($RANDOM(2):"^",1:"")_testNum_"I"
	set in=inVar
	; Randomly choose whether to use a global variable for ZYENCODE output
	set encVar=$select($RANDOM(2):"^",1:"")_testNum_"E"
	set enc=encVar
	; Randomly choose whether to use a global variable for output
	set outVar=$select($RANDOM(2):"^",1:"")_testNum_"O"
	set out=outVar
	; Randomly choose whether to use a global variable for secondary output
	set suppVar=$select($RANDOM(2):"^",1:"")_testNum_"S"
	set supp=suppVar

	; Randomly assign additional subscripts to test data stored in deeply nested trees
	set inSubs="",encSubs="",outSubs="",suppSubs=""
	set numInSubs=$RANDOM(30) ; Subscript max 32 - 2 (2 subs required by populateTree)
	set numEncSubs=$RANDOM(30) ; Subscript max 32 - 2 (2 subs required by populateTree)
	set numOutSubs=$RANDOM(30) ; Subscript max 32 - 2 (2 subs required by populateTree)
	set numSuppSubs=$RANDOM(30) ; Subscript max 32 - 2 (2 subs required by populateTree)
	set maxSubs=$select((numInSubs>numOutSubs):numInSubs,1:numOutSubs)
	set maxSubs=$select((numEncSubs>maxSubs):numEncSubs,1:maxSubs)
	set maxSubs=$select((numSuppSubs>maxSubs):numSuppSubs,1:maxSubs)
	for i=1:1:maxSubs  do
	. set:i<=numInSubs inSubs=inSubs_i_","
	. set:i<=numEncSubs encSubs=encSubs_i_","
	. set:i<=numOutSubs outSubs=outSubs_i_","
	. set:i<=numSuppSubs suppSubs=suppSubs_i_","
	; Compose full node specification for input, output, encoded, and supplementary variables
	set:inSubs'="" in=in_"("_$$R^%TRIM(inSubs,",")_")"
	set:encSubs'="" enc=enc_"("_$$R^%TRIM(encSubs,",")_")"
	set:outSubs'="" out=out_"("_$$R^%TRIM(outSubs,",")_")"
	set:suppSubs'="" supp=supp_"("_$$R^%TRIM(suppSubs,",")_")"

	set ^testConfig(testNum,"in")=in
	set ^testConfig(testNum,"inVar")=inVar
	set ^testConfig(testNum,"inSubs")=inSubs
	set ^testConfig(testNum,"numInSubs")=numInSubs
	set ^testConfig(testNum,"enc")=enc
	set ^testConfig(testNum,"encVar")=encVar
	set ^testConfig(testNum,"encSubs")=encSubs
	set ^testConfig(testNum,"out")=out
	set ^testConfig(testNum,"outVar")=outVar
	set ^testConfig(testNum,"outSubs")=outSubs
	set ^testConfig(testNum,"supp")=supp
	set ^testConfig(testNum,"suppVar")=suppVar
	set ^testConfig(testNum,"suppSubs")=suppSubs

	quit

logJSONToFile(filename,out) ;
	set file=filename_".json"
	write "# Log encoded JSON to file ["_file_"]",!
	open file:(newversion:stream:nowrap:chset="M")
	use file
	for i=1:1:@out  do
	. set node=$$extendNode^ydb1152(out,i)
	. set $x=0 ; Prevent newline
	. write @node
	close file

	quit

validateEncodedOutput(testNum,dataSize,out) ;
	; Calculate the number of expected nodes based on the M max string length of 1 MiB.
	; If the data size is not a multiple of 1 MiB, then there will be an additional node
	; with the remaining data.
	set expectedNodes=(dataSize\MiB)+(dataSize#MiB'=0)
	write "# Confirm the root node reports the correct number of output nodes. Expect "_expectedNodes_":",!
	if expectedNodes=@out  do
	. write "PASS"
	else  do
	. write "FAIL"
	write " : Expected "_expectedNodes_" output node(s). Got "_@out_" output node(s).",!

	write "# Confirm the JSON output is of the correct size.  Expect "_dataSize_":",!
	set resultSize=0
	for i=1:1:expectedNodes  do
	. set node=$$extendNode^ydb1152(out,i)
	. set resultSize=resultSize+$length(@node)
	if resultSize=dataSize  do
	. write "PASS"
	else  do
	. write "FAIL"
	write " : Expected JSON output of size "_dataSize_". Got JSON output of size "_resultSize_".",!

	quit

validateDecodedOutput(testNum,out) ;
	; Store subscripted GVN values in abbreviated LVNs for readability
	set in=^testConfig(testNum,"in")
	set out=^testConfig(testNum,"out")
	set numInSubs=^testConfig(testNum,"numInSubs")

	write "# Check each node of the decoded data against the input data.",!
	write "# Expect the values to be identical.",!
	if $find(out,"(")  do
	. set outBase=$extract(out,0,$find(out,")")-2)_","
	else  do
	. set outBase=out_"("

	set fail=0
	for  set in=$query(@in) quit:in=""!fail   do
	. ; Construct the corresponding output node by adding the relevant trailing subscripts from the input node,
	. ; i.e. those added by populateTree to those randomly specified by initTest.
	. set startPosition=$find(in,($select(numInSubs>0:numInSubs_",",1:"(")))
	. if numInSubs>0  do
	. . set out=outBase_$extract(in,startPosition,$length(in))
	. else  do
	. . set out=outBase_$extract(in,startPosition,$length(in))
	. ; Compare the input and output nodes
	. if @in'=@out  do
	. . set fail=1
	. . write "FAIL: ZYDECODE output node does not match corresponding node in input tree:",!
	. . write in,"=",@in,!
	. . write out,"=",@out,!
	write:'fail "PASS: ZYDECODE output mirrors input data",!

	quit

extendNode(base,trailingSub) ;
	new node

	if $find(base,"(")  do
	. ; The output variable contains subscripts
	. set node=$extract(base,0,$find(out,")")-2)_","
	else  do
	. ; The output variable does not contain subscripts
	. set node=base_"("
	set node=node_trailingSub_")"

	quit node

populateTree(testNum,dataSize) ;
	set file="populate-"_testNum_"-"_dataSize_".out"
	open file
	use file
	write "# Set target output data size to "_dataSize,!
	set MiB=1048576
	set targetChars=dataSize
	write "# Set tree size: "
	set breadth=4
	set depth=4
	set pair=2
	set done=0,toggle=0
	for i=1:1  quit:done  do
	. set numChunks=breadth*depth
	. if (dataSize/numChunks)>MiB  do
	. . set:toggle breadth=breadth+1
	. . set:'toggle depth=depth+1
	. . set toggle='toggle
	. else  do
	. . set done=1
	write breadth_"x"_depth,!

	write "# Compute number of formatting characters expected in the output string",!
	set numQuotes=(numChunks*pair*pair)+(depth*pair)
	set numBrackets=(breadth*pair)+pair
	set numColons=(numChunks)+depth
	set numCommas=((breadth-1)*depth)+depth-1
	set numSpaces=numCommas+numColons
	set numDigits=0
	for i=1:1:breadth  do
	. set numDigits=numDigits+$length(i)
	. for j=1:1:depth  do
	. . set numDigits=numDigits+$length(j)
	set numFormatChars=(numQuotes+numBrackets+numColons+numCommas+numSpaces+numDigits)
	write "  numCommas="_numCommas,!
	write "  numQuotes="_numQuotes,!
	write "  numBrackets="_numBrackets,!
	write "  numColons="_numColons,!
	write "  numSpaces="_numSpaces,!
	write "  numDigits="_numDigits,!
	write "  numFormatChars="_numFormatChars,!

	write "# Compute the expected number of data characters, i.e. targetChars - numformatChars",!
	set numDataChars=targetChars-numFormatChars
	write "numDataChars="_numDataChars,!
	write "# Compute the number of characters remaining after dividing the total number of data characters by the number of chunks",!
	set shortfall=(numDataChars#(numChunks))
	write "shortfall="_shortfall,!
	write "# If the number of data characters is cannot be evenly divided, subtract the remainder from the total",!
	set:shortfall>0 numDataChars=numDataChars-shortfall
	write "numDataChars-shortfall="_numDataChars,!
	write "# Compute the expected total number of characters, including both formatting and data characters",!
	set expectedTotalChars=numDataChars+numFormatChars
	write "expectedTotalChars="_expectedTotalChars,!
	write "# Compute data node chunk size",!
	set chunkSize=((numDataChars)\(numChunks))
	write "chunkSize="_chunkSize,!

	write "# Populate "_testNum_" with "_numChunks_" "_chunkSize_" size chunks",!
	for i=1:1:breadth  do
	. for j=1:1:depth  do
	. . ; Add the remaining characters to the last data chunk only
	. . set node=^testConfig(testNum,"inVar")_"("_^testConfig(testNum,"inSubs")_i_","_j_")"
	. . write "# Populating node: "_node,!
	. . set @node=$$^%RANDSTR(chunkSize+$select((i=breadth)&(j=depth):shortfall,1:0),"32:1:126","AN")
	close file

	set file="node-"_testNum_"-"_dataSize_".out"
	open file:(newversion:stream:nowrap:chset="M")
	use file
	set $x=0 ; Prevent newline
	zwrite @^testConfig(testNum,"inVar") ; Log the node to a file
	close file

	quit

runZyencodeTest(testNum,dataSize)
	set $etrap="use $p write !,""$ZSTATUS=""_$ZSTATUS,! halt"
	; Initialize test variables
	do initTest^ydb1152(testNum)
	; Store subscripted GVN values in abbreviated LVNs for readability
	set in=^testConfig(testNum,"in")
	set out=^testConfig(testNum,"out")
	set inVar=^testConfig(testNum,"inVar")

	write "# Run the [populateTree] label to generate a tree with "_dataSize_" bytes of data in the ["""_inVar_"""] variable",!
	do populateTree^ydb1152(testNum,dataSize)

	write "# Set a GVN to update $REFERENCE and store the last GVN referenced by ZYENCODE.",!
	set ^last="^last"
	set:$find(in,"^") ^last=in
	set:$find(out,"^") ^last=out
	write "# Run [zyencode "_out_"="_in_"] to encode the generated tree into JSON format in the "_inVar_" variable",!
	zyencode @out=@in
	write "# Store the value of $REFERENCE",!
	set ref=$REFERENCE
	write "# Confirm $REFERENCE (the naked indicator) is correctly set to the "_^last_" variable:",!
	if ref=^last  do
	. write "PASS: "
	else  do
	. write "FAIL: "
	write "$REFERENCE="_ref,!

	do logJSONToFile^ydb1152(testNum,out)
	do validateEncodedOutput^ydb1152(testNum,dataSize,out)

	quit

runZydecodeTest(testNum,dataSize)
	; Initialize test variables
	do initTest^ydb1152(testNum)
	; Store subscripted GVN values in abbreviated LVNs for readability
	set in=^testConfig(testNum,"in")
	set enc=^testConfig(testNum,"enc")
	set out=^testConfig(testNum,"out")

	write "# Run the [populateTree] label to generate a tree with "_dataSize_" bytes of data in the ["""_testNum_"""] variable",!
	do populateTree(testNum,dataSize)

	write "# Run [zyencode "_enc_"="_in_"] to encode the generated tree into JSON format in the "_enc_" variable",!
	zyencode @enc=@in
	; Set a GVN to update $REFERENCE and store the last GVN referenced by ZYENCODE.
	set ^last="^last"
	set:$find(enc,"^") ^last=enc
	set:$find(out,"^") ^last=out
	write "# Run ZYDECODE to decode encoded input data",!
	write "# Run [zydecode "_out_"="_enc_"] to decode the encoded tree from JSON format into the "_out_" variable",!
	zydecode @out=@enc
	set ref=$REFERENCE
	write "# Confirm $REFERENCE (the naked indicator) is correctly set to the "_^last_" variable:",!
	if ref=^last  do
	. write "PASS: "
	else  do
	. write "FAIL: "
	write "$REFERENCE="_ref,!

	do validateDecodedOutput^ydb1152(testNum)

	quit
