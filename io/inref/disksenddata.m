;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; disksenddata.m
; The called entry corresponds to the type of test, e.g. fixednonutf.  It is passed a parameter of this same type to be used
; in globals such as ^scnt(type) which will record the number of writes done to the disk.  The streaming utf writes are
; random in size to exercise the utf streaming read 512 byte buffering.  For streaming utf writes, the total number of characters
; written to the disk is saved in ^charsend(type).  Each write does a hang .5 every 100 lines of output to guarantee
; some read interrupts

fixednonutf(type)
	; tests nonutf fixed mode reads
	set a="abcdefghijklmnop0123456789abcdefghijklmnop"
	set a2="0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789"
	do init1(type,.ftest)
	open ftest:(fixed:recordsize=130:writeonly:key=key_" "_iv)
	; tell reader file has been opened and use ftest
	do inituse(type,ftest)
	for i=1:1:^readcnt do
	. set ^scnt(type)=i
	. write a
	. if '(i#100) hang .5
	. write a2
	for  quit:$data(^quit)
	quit

streamnonutf(type)
	; tests nonutf streaming mode reads
	set a="abcdefghijklmnop0123456789abcdefghijklmnop"
	set a2="0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789"
	do init1(type,.ftest)
	open ftest:(writeonly:key=key_" "_iv)
	; tell reader file has been opened and use ftest
	do inituse(type,ftest)
	for i=1:1:^readcnt do
	. set ^scnt(type)=i
	. write a
	. if '(i#100) hang .5
	. write a2,!
	for  quit:$data(^quit)
	quit

streamutf8(type)
	; tests utf8 streaming utf8 mode reads
	do bigutf(.a)
	do init1(type,.ftest)
	open ftest:(writeonly:key=key_" "_iv)
	; tell reader file has been opened and use ftest
	do inituse(type,ftest)
	for i=1:1:^readcnt do
	. set ^scnt(type)=i
	. set randomlen1=1+$Random(300)
	. set randomlen2=1+$Random(300)
	. set randomlen=randomlen1+randomlen2
	. set endpntr=300+randomlen2
	. set b1=$extract(a,1,randomlen1)
	. set b2=$extract(a,301,endpntr)
	. write b1
	. if '(i#100) hang .5
	. write b2,!
	. set ^charsend(type)=^charsend(type)+randomlen
	set ^senddone(type)=1
	for  quit:$data(^quit)
	quit

fixedutf8(type)
	; tests fixed utf8 mode reads
	do smallutf(.a,0,300)
	do smallutf(.a,1,400)
	do init1(type,.ftest)
	open ftest:(fixed:recordsize=182:writeonly:key=key_" "_iv)
	; tell reader file has been opened and use ftest
	do inituse(type,ftest)
	for i=1:1:^readcnt do
	. set ^scnt(type)=i
	. set random1=2+$Random(80)
	. write $extract(a(i#2),1,random1)
	. if '(i#100) hang .5
	. write $extract(a(i#2),random1+1,91)
	for  quit:$data(^quit)
	quit

streamutf16(type)
	; tests utf streaming utf16 mode reads
	do bigutf(.a)
	do init1(type,.ftest)
	open ftest:(writeonly:OCHSET="UTF-16":key=key_" "_iv)
	; tell reader file has been opened and use ftest
	do inituse(type,ftest)
	for i=1:1:^readcnt do
	. set ^scnt(type)=i
	. set randomlen1=1+$Random(300)
	. set randomlen2=1+$Random(300)
	. set randomlen=randomlen1+randomlen2
	. set endpntr=300+randomlen2
	. set b1=$extract(a,1,randomlen1)
	. set b2=$extract(a,301,endpntr)
	. write b1
	. if '(i#100) hang .5
	. write b2,!
	. set ^charsend(type)=^charsend(type)+randomlen
	set ^senddone(type)=1
	for  quit:$data(^quit)
	quit

fixedutf16(type)
	; tests fixed utf8 mode reads
	do smallutf(.a,0,300)
	do smallutf(.a,1,400)
	do init1(type,.ftest)
	open ftest:(fixed:recordsize=182:writeonly:OCHSET="UTF-16":key=key_" "_iv)
	; tell reader file has been opened and use ftest
	do inituse(type,ftest)
	for i=1:1:^readcnt do
	. set ^scnt(type)=i
	. set random1=2+$Random(80)
	. write $extract(a(i#2),1,random1)
	. if '(i#100) hang .5
	. write $extract(a(i#2),random1+1,91)
	for  quit:$data(^quit)
	quit

init1(type,t)
	; some common setup code and to communicate the process id of this process
	set ^unavcnt(type)=0
	set $ztrap="goto cont1"
	set key=$ztrnlnm("gtmcrypt_key")
	set iv=$ztrnlnm("gtmcrypt_iv")
	; save the pid
	set p=type_"_senddata_pid"
	open p:newversion
	use p
	write $job,!
	close p
	set t=type_".disk"
	quit

inituse(type,ftest)
	set fname="^"_type_"ready"
	set @fname=1
	use ftest
	quit

smallutf(a,index,start)
	; create 91 utf-8 character string
	set a(index)=$char(start)
	set begin=start+1
	set end=start+90
	for i=begin:1:end do
	. set a(index)=a(index)_$char(i)
	quit

bigutf(a)
	; save total char count sent
	set ^charsend(type)=0
	; create 600 utf-8 character string
	set a=$char(300)
	for i=301:1:899 do
	. set a=a_$char(i)
	quit

cont1
	; ztrap entrance in case of write problem - like a full disk
	zshow "*":zshout
	set z=$za
	set zeof=$zeof
	; use $device to make sure ztrap caused by blocked write to disk
	set d=$device
	use $p write "$device= ",d,"$za= ",z," $zeof= ",zeof,!
	if $data(^quit) write "^quit = ",^quit,!
	zwrite zshout
	set ^quit=9
	halt
	quit
