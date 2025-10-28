;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
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
	; do T16^ydb1152
	; do T17a^ydb1152

	quit

T1 ;
	write "### Test 1: ZYENCODE error cases",!
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; needed to transfer control to next M line after error in "xecute" command
	write "# Run [set src(""key1"")=""value1""]",!
	set src("key1")="value1"
	write "# Run [set src(""key1"",""key2"")=""value1""]",!
	set src("key1","key2")="value1"
	write "# Run [set ^src(""key1"")=""value1""]",!
	set ^src("key1")="value1"
	write "# Run [set ^src(""key1"",""key2"")=""value1""]",!
	set ^src("key1","key2")="value1"
	write !

	write "## Test 1a: Source is descendant of destination (%YDB-E-ZYENCODEDESC)",!
	write "# Run [zyencode src(""key1"")=src(""key1"",""key2"")]",!
	write "# Expect '%YDB-E-ZYENCODEDESC, ZYENCODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zyencode src("key1")=src("key1","key2")
	write !

	write "## Test 1b: Destination is descendant of source (%YDB-E-ZYENCODEDESC)",!
	write "# Run [zyencode src(""key1"",""key2"")=src(""key1"")]'",!
	write "# Expect '%YDB-E-ZYENCODEDESC, ZYENCODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zyencode src("key1","key2")=src("key1")
	write "# Run [zyencode ^src(""key1"",""key2"")=^src(""key1"")]'",!
	write "# Expect '%YDB-E-ZYENCODEDESC, ZYENCODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zyencode ^src("key1","key2")=^src("key1")
	write !

	write "## Test 1c: Undefined local variable passed as source raises %YDB-E-ZYENCODESRCUNDEF",!
	write "# Run [zyencode src(""key1"",""key2"")=notanlvn]'",!
	write "# Expect '%YDB-E-ZYENCODESRCUNDEF'",!
	zyencode dest=notanlvn
	write !

	write "## Test 1d: Error from the underlying ydb_encode_s(): $ZSTATUS is set and %YDB-W-ZYENCODEINCOMPL issued",!
	set x=$ZCH(167)
	write "# Expect '%YDB-W-ZYENCODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONENCODEERROR",!
	zyencode dest=x
	write !

	quit

T2 ;
	kill src
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; needed to transfer control to next M line after error in "xecute" command

	write "### Test 2: ZYDECODE error cases",!
	write "# Run [set src(""key1"")=""value1""]",!
	set src("key1")="value1"
	write "# Run [set src(""key1"",""key2"")=""value1""]",!
	set src("key1","key2")="value1"
	write "# Run [set ^src(""key1"")=""value1""]",!
	set ^src("key1")="value1"
	write "# Run [set ^src(""key1"",""key2"")=""value1""]",!
	set ^src("key1","key2")="value1"
	write !

	write "## Test 2a: Source is descendant of destination (%YDB-E-ZYDECODEDESC)",!
	write "# Run [zydecode src(""key1"")=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEDESC, ZYDECODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zydecode src("key1")=src("key1","key2")
	write "# Expect '%YDB-E-ZYDECODEDESC, ZYDECODE operation not possible. ^src(""key1"",""key2"") is a descendant of ^src(""key1"")'",!
	zydecode ^src("key1")=^src("key1","key2")
	write !

	write "## Test 2b: Destination is descendant of source (%YDB-E-ZYDECODEDESC)",!
	write "# Run [zydecode src(""key1"",""key2"")=src(""key1"")]'",!
	write "# Expect '%YDB-E-ZYDECODEDESC, ZYDECODE operation not possible. src(""key1"",""key2"") is a descendant of src(""key1"")'",!
	zydecode src("key1","key2")=src("key1")
	write !

	write "## Test 2c: Root node of source = 0 (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set src=0]",!
	set src=0
	write "# Run [zydecode dest=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode dest=src("key1","key2")
	write !

	write "## Test 2b: Root node of source < 0 (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set src=-1]",!
	set src=-1
	write "# Run [zydecode dest=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode dest=src("key1","key2")
	write !

	write "## Test 2c: Root node of source = non-numeric string (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set src=""abc""]",!
	set src="abc"
	write "# Run [zydecode dest=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode dest=src("key1","key2")
	write !

	write "## Test 2d: Root node of source = positive floating point value (%YDB-E-ZYDECODEWRONGCNT)",!
	write "# Run [set src=1.1]",!
	set src=1.1
	write "# Run [zydecode dest=src(""key1"",""key2"")]'",!
	write "# Expect '%YDB-E-ZYDECODEWRONGCNT'",!
	zydecode dest=src("key1","key2")
	write !

	write "## Test 2e: LVN in series starting from root node's positive integer doesn't exist (%YDB-E-LVUNDEF)",!
	write "# Run:",!
	write "#  [kill]",!
	kill
	write "#  [set src=3]",!
	set src=3
	write "#  [set src(1)=""{""key1"":""value1"",""]",!
	set src(1)="{""key1"":""value1"","
	write "#  (skip setting src(2))",!
	write "#  [set src=""""key3"""":""""value3""""}""]",!
	set src(3)="""key3"":""value3""}"
	write "# Run [zydecode dest=src]'",!
	write "# Expect '%YDB-E-LVUNDEF'",!
	zydecode dest=src
	kill
	write !

	write "## Test 2f: GVN in series starting from root node's positive integer doesn't exist (%YDB-E-GVUNDEF)",!
	write "# Run:",!
	write "#  [set ^src=3]"
	set ^src=3
	write "#  [set ^src(1)=""{""key1"":""value1"",""]",!
	set ^src(1)="{""key1"":""value1"","
	write "#  (skip setting ^src(2))",!
	write "#  [set ^src=""""key3"""":""""value3""""}""]",!
	set ^src(3)="""key3"":""value3""}"
	write "# Run [zydecode ^dest=^src]",!
	write "# Expect '%YDB-E-GVUNDEF'",!
	zydecode ^dest=^src
	write !

	write "## Test 2g: Error from the underlying ydb_decode_s(): $ZSTATUS is set and %YDB-W-ZYDECODEINCOMPL issued",!
	set ^src=1
	set ^src(1)="{""key1"":"""_$ZCH(167)_"""}"
	write "# Expect '%YDB-W-ZYDECODEINCOMPL' to be emitted with $ZSTATUS=%YDB-E-JANSSONINVALIDJSON",!
	zydecode dest=^src
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
	write "### Test 4: ZYENCODE properly handles input trees containing arbitrary (random) data sizes",!
	write "### See also the discussion at: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854162278",!
	write "## Test 4a: ZYENCODE properly handles input trees containing arbitrary (random) data sizes, up to 3MiB",!
	do runZyencodeTest^ydb1152("T4a",$RANDOM(1048576*3))
	write "## Test 4b: ZYENCODE properly handles input trees containing arbitrary (random) data sizes, < 1MiB",!
	do runZyencodeTest^ydb1152("T4b",$RANDOM(1048576))
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
	write "### Test 6: ZYDECODE properly handles input trees containing arbitrary (random) data sizes",!
	write "### See also the discussion at: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2854162278",!
	write "## Test 6a: ZYDECODE properly handles input trees containing arbitrary (random) data sizes, up to 3MiB",!
	do runZydecodeTest^ydb1152("T6a",$RANDOM(1048576*3))
	write "## Test 6b: ZYDECODE properly handles input trees containing arbitrary (random) data sizes, < 1MiB",!
	do runZydecodeTest^ydb1152("T6b",$RANDOM(1048576))
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
	; TODO: Bump vallen limit if possible. At 2**14, full test run takes ~1 minute. At 2**15, ~2 minutes. At 2**16, ~5 minutes.
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
	write "# Use ZYENCODE to encode the nodes, expect no ZYENCODEWRONGCNT error",!
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
	write "# Use ZYENCODE to encode the nodes, expect no ZYENCODEWRONGCNT error",!
	zyencode y=x
	write "# Use ZYDECODE to decode the nodes, expect no ZYDECODEWRONGCNT error",!
	zydecode z=y
	write !

	quit

T9 ;
	write "### Test 9: Confirm no INVSTRLEN error for subscripts or values less than the maximum string length (4294967295)",!
	write "### For details, see discussion at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2844227740",!
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
	write "# Use ZYENCODE to encode the nodes, expect no INVSTRLEN error",!
	zyencode ^y=^x
	write "# Use ZYDECODE to decode the nodes, expect no INVSTRLEN error",!
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
	write "# Use ZYENCODE to encode the nodes, expect no INVSTRLEN error",!
	zyencode y=x
	write "# Use ZYDECODE to decode the nodes, expect no INVSTRLEN error",!
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
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; needed to transfer control to next M line after error in "xecute" command
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
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; needed to transfer control to next M line after error in "xecute" command
	set a=1
	zyencode b=a
	zydecode c=b
	quit

T11d ;
	set a=1
	zyencode ^b=a
	zydecode c=^b
	quit



T13 ;
	write "set maxlen=2**20",!
	write "set maxstr=$$^%RANDSTR(maxlen)",!
	for i=1:1:31 do
	. set xstr="set x(" for j=1:1:i-1 set xstr=xstr_"maxstr,"
	. set xstr=xstr_"maxstr)=maxstr"
	. write xstr,!
	write "zyencode y=x zydecode z=y"

	quit

T14a ;
	write "# Start test routine",!
	write "# Choose random subscript and value lengths:",!
	set maxsubslen=32,maxvallen=256
	set subslen=$random(maxsubslen)+1
	set vallen=$random(maxvallen)+1
	set ^ready=0
	set break=$RANDOM(3)
	set break=2
	zwrite subslen,vallen

	set subs=$$^%RANDSTR(subslen)
	set val=$$^%RANDSTR(vallen)

	kill ^x,^y,^z
	set maxi=100000
	set ^T12=$job
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
	for i=1:1  quit:($data(^ready)'=0)&^ready  hang 0.001
	write "# Issue MUPIP INTRPT to test routine",!
	zsystem "$ydb_dist/mupip intrpt "_^T12

	quit

T15 ;
	write "# Choose random subscript and value lengths:",!
	set maxsubslen=32,maxvallen=256
	set subslen=$random(maxsubslen)+1
	set vallen=$random(maxvallen)+1
	zwrite subslen,vallen
	set subs=$$^%RANDSTR(subslen)
	set val=$$^%RANDSTR(vallen)

	kill ^x,^y
	set maxi=10000
	write "# Set "_maxi_" nodes to the random value",!
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
