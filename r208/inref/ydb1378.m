;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
ydb1378	; ZYENCODE to a global variable whose key, with the added chunk number subscript, is longer than the maximum key size
	; (64 bytes for the region of this test). Each stage runs in its own process on its own database.
	quit
stage1	; ZYENCODE ^gvn=lvn, with a destination key that is too long once the chunk number is added (from fuzz testing)
	set m(1)=31
	do check("zyencode ^j(1,3,4,5,6,7,82,38,9,0,1,2,3,4,5,6,7,8,9,0,1)=m","GVSUBOFLOW")
	quit
stage2	; ZYENCODE ^gvn=^gvn, with the same destination key
	set ^m(1)=31
	do check("zyencode ^j(1,3,4,5,6,7,82,38,9,0,1,2,3,4,5,6,7,8,9,0,1)=^m","GVSUBOFLOW")
	quit
stage3	; ZYENCODE of a JSON string of 371 chunks, where only the keys of the later chunks are too long. The key of the last
	; chunk, ^j(s,371), is 65 bytes, one byte more than the maximum key size.
	new i
	for i=1:1:3000 set ^m(i)=$justify(i,20)
	set s=$translate($justify("",56)," ","a")
	do check("zyencode ^j(s)=^m","GVSUBOFLOW")
	if zs["(65) is greater than maximum (64)" write "PASS : GVSUBOFLOW reports a key of 65 bytes, maximum 64",!
	else  write "FAIL : $zstatus is ",zs,!
	if zs[",371)" write "PASS : GVSUBOFLOW reports the key of the last chunk (371)",!
	else  write "FAIL : $zstatus is ",zs,!
	quit
stage4	; ZYENCODE with the destination of stage 3 and a JSON string of 1 chunk. The key of that chunk, ^j(s,1), is 64 bytes,
	; exactly the maximum key size.
	set m(1)=31
	set s=$translate($justify("",56)," ","a")
	do keylen($name(^j(s,1)),"^j(s,1)",64)
	do check("zyencode ^j(s)=m","")
	if "{""1"": 31}"=$get(^j(s,1)) write "PASS : ^j(s,1) has the JSON string",!
	else  write "FAIL : ^j(s,1) is ",$get(^j(s,1)),!
	quit
stage5	; ZYENCODE ^gvn=lvn as in stage 1, with a subscripted source
	set m(1)=31
	do check("zyencode ^j(1,3,4,5,6,7,82,38,9,0,1,2,3,4,5,6,7,8,9,0,1)=m(1)","GVSUBOFLOW")
	quit
stage6	; ZYENCODE ^gvn=^gvn as in stage 2, with a subscripted source
	set ^m(1)=31
	do check("zyencode ^j(1,3,4,5,6,7,82,38,9,0,1,2,3,4,5,6,7,8,9,0,1)=^m(1)","GVSUBOFLOW")
	quit
stage7	; ZYENCODE ^gvn=^gvn as in stage 4, so the key of the one chunk, ^j(s,1), is exactly the maximum key size
	set ^m(1)=31
	set s=$translate($justify("",56)," ","a")
	do keylen($name(^j(s,1)),"^j(s,1)",64)
	do check("zyencode ^j(s)=^m","")
	if "{""1"": 31}"=$get(^j(s,1)) write "PASS : ^j(s,1) has the JSON string",!
	else  write "FAIL : ^j(s,1) is ",$get(^j(s,1)),!
	quit
keylen(gvn,name,exp)	; check that the key of gvn (shown as name) is exp bytes, as GVSUBOFLOW counts it
	new len
	set len=$zlength($view("YGVN2GDS",gvn))	; $zlength() because the key is bytes, not characters
	if exp=len write "PASS : the key of ",name," is ",exp," bytes",!
	else  write "FAIL : the key of ",name," is ",len," bytes, expected ",exp,!
	quit
check(cmd,experr)	; run cmd, and check the error it issues (if any) and whether ^j has any node
	; Leaves $zstatus of the error (if any) in zs, for the caller
	new err
	do try(cmd)
	if experr=err write "PASS : ",$select(""=err:"no error",1:err)," as expected",!
	else  write "FAIL : got [",err,"] but expected [",experr,"]",!
	if ""'=experr do
	. if 0=$data(^j) write "PASS : $data(^j)=0 (nothing was stored)",!
	. else  write "FAIL : $data(^j)=",$data(^j),", expected 0",! zwrite ^j
	quit
try(cmd)	; XECUTE cmd, and set err to the mnemonic of the error it issues (if any) and zs to its $zstatus
	new $etrap
	set err="",zs="",$etrap="set zs=$zstatus,err=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit"
	xecute cmd
	quit
