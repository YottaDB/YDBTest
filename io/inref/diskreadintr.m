;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; diskreadintr.m
; This tests disk interrupts
; The called entry corresponds to the type of test, e.g. streamnonutf.  It is passed a parameter of this same type to be used
; in globals such as ^readcnt(type) which will record the number of reads done from the disk.  Since the streaming utf writes are
; random in size, total number of chars read are saved in ^charread(type) and compared to the total number sent in ^charsend(type).
; The nonutf reads and fixed utf reads do a string compare with each line read.

streamnonutf(type)
	; tests nonutf streaming mode reads
	set a="abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789"
	do init1(type,.t)
	open t:(readonly:follow:key=key_" "_iv)
	do processStr(type,t,a)
	quit

fixednonutf(type)
	; tests nonutf fixed mode reads
	set a="abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789"
	do init1(type,.t)
	open t:(fixed:recordsize=130:readonly:follow:key=key_" "_iv)
	do processStr(type,t,a)
	quit

streamutf8(type)
	; tests utf8 streaming mode reads.
	do init1(type,.t)
	open t:(readonly:follow:key=key_" "_iv)
	do processLen(type,t)
	quit

fixedutf8(type)
	; tests utf8 fixed mode reads
	do smallutf(.a,0,300)
	do smallutf(.a,1,400)
	do init1(type,.t)
	open t:(readonly:fixed:recordsize=182:follow:key=key_" "_iv)
	do processStr2(type,t,.a)
	quit

streamutf16(type)
	; tests utf16 streaming mode reads.
	do init1(type,.t)
	open t:(readonly:ICHSET="UTF-16":follow:key=key_" "_iv)
	do processLen(type,t)
	quit

fixedutf16(type)
	; tests utf16 fixed mode reads
	do smallutf(.a,0,300)
	do smallutf(.a,1,400)
	do init1(type,.t)
	open t:(readonly:fixed:recordsize=182:ICHSET="UTF-16":follow:key=key_" "_iv)
	do processStr2(type,t,.a)
	quit

init1(type,t)
	; some common setup code and to communicate the process id of this process
	Set $Zint="Set ^Zreadcnt("""_type_""")=^Zreadcnt("""_type_""")+1"
	set key=$ztrnlnm("gtmcrypt_key")
	set iv=$ztrnlnm("gtmcrypt_iv")
	; save the pid
	set p=type_"_pid"
	open p:newversion
	use p
	write $job,!
	close p
	set t=type_".disk"
	set fname="^"_type_"ready"
	for  do  quit:$data(@fname)
	quit

processStr(type,t,a)
	; read and compare each line read with the expected input
	do init2(type,t)
	for i=1:1:^readcnt do
	. set ^readcnt(type)=i
	. if (i#2) read y
	. if '(i#2) read y:30
	. if $za!$zeof set za=$za set zeof=$zeof use $p write "$za= ",za," $zeof= ",zeof,! set ^quit=2 halt
	. if a'=y use $p write "YDB-E-BADINPUT: ",!,"Expected: ",!,a,!,"Read: ",!,y,! set ^quit=3 halt
	use $p
	write type,": ","Input matches output",!
	set ^quit=1
	quit

processStr2(type,t,a)
	; read and compare each line read with the expected input
	; the input alternates between to lines in a(i#2)
	do init2(type,t)
	for i=1:1:^readcnt do
	. set ^readcnt(type)=i
	. read y
	. if $za!$zeof set za=$za set zeof=$zeof use $p write "$za= ",za," $zeof= ",zeof,! set ^quit=2 halt
	. if a(i#2)'=y use $p write "YDB-E-BADINPUT: ",!,"Expected: ",!,a(i#2),!,"Read: ",!,y,! set ^quit=3 halt
	use $p
	write type,": ","Input matches output",!
	set ^quit=1
	quit

processLen(type,t)
	; save total char count read for all data read from the disk and compare with the number sent
	set ^charread(type)=0
	do init2(type,t)
	for i=1:1:^readcnt do
	. set ^readcnt(type)=i
	. read y
	. set ^charread(type)=^charread(type)+$Length(y)
	. if $za!$zeof set za=$za set zeof=$zeof use $p write "$za= ",za," $zeof= ",zeof,! set ^quit=2 halt
	use $p
	for i=1:1:30 do  hang 1 quit:$data(^senddone(type))
	if '$data(^senddone(type)) write "^senddone("_type_") not set after 30 seconds.",!
	if ^charread(type)=^charsend(type) write type,": ","Input matches output",!
	set ^quit=1
	quit

init2(type,t)
	; set the pid for sendintr.m
	use t
	set ^doreadpid(type)=$job
	quit

smallutf(a,index,start)
	; create 91 utf-8 character string
	set a(index)=$char(start)
	set begin=start+1
	set end=start+90
	for i=begin:1:end do
	. set a(index)=a(index)_$char(i)
	quit
