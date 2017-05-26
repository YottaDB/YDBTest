;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; readintr.m
; This tests pipe interrupts
; The called entry corresponds to the type of test, e.g. streamnonutf.  It is passed a parameter of this same type to be used
; in globals such as ^readcnt(type) which will record the number of reads done from the pipe.  The streaming utf writes are
; random in size to exercise the utf streaming read 512 byte buffering.  In each test the string written is compared to
; that read.

streamnonutf(type)
	; tests nonutf streaming mode reads
	set a="abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789"
	do init1(type,.t)
	open t:(comm="./delayecho 131000 1":key=key_" "_iv)::"pipe"
	do init2(type,t)
	for i=1:1:^readcnt do
	. set ^readcnt(type)=i
	. write a,!
	. read y
	. if $za!$zeof set za=$za set zeof=$zeof use $p write "$za= ",za," $zeof= ",zeof,! set ^quit=2 halt
	. if a'=y use $p write "GTM-E-BADINPUT: ",!,"Expected: ",!,a,!,"Read: ",!,y,! set ^quit=1 halt
	do finish(type)
	quit

fixednonutf(type)
	; tests nonutf fixed mode reads
	set a="abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789abcdefghijklmnop0123456789"
	do init1(type,.t)
	open t:(comm="./delayecho 130000 1":fixed:recordsize=130:key=key_" "_iv)::"pipe"
	do processFix(type,t,a)
	quit

streamutf8(type)
	; tests utf8 streaming mode reads.
	do bigutf(.a)
	do init1(type,.t)
	open t:(comm="./delayecho 1200000 1":key=key_" "_iv)::"pipe"
	do processStrUtf(type,t,a)
	quit

fixedutf8(type)
	; tests utf8 fixed mode reads
	do smallutf(.a)
	do init1(type,.t)
	open t:(comm="./delayecho 182000 1":fixed:recordsize=182:key=key_" "_iv)::"pipe"
	do processFix(type,t,a)
	quit

streamutf16(type)
	; tests utf16 streaming mode reads.
	do bigutf(.a)
	do init1(type,.t)
	open t:(comm="./delayecho 1200000 1":ICHSET="UTF-16":OCHSET="UTF-16":key=key_" "_iv)::"pipe"
	do processStrUtf(type,t,a)
	quit

fixedutf16(type)
	; tests utf16 fixed mode reads
	do smallutf(.a)
	do init1(type,.t)
	open t:(comm="./delayecho 182000 1":ICHSET="UTF-16":OCHSET="UTF-16":fixed:recordsize=182:key=key_" "_iv)::"pipe"
	do processFix(type,t,a)
	quit

init1(type,t)
	set ^unavcnt(type)=0
	Set $Zint="Set ^Zreadcnt("""_type_""")=^Zreadcnt("""_type_""")+1"
	set $ztrap="goto cont1"
	set key=$ztrnlnm("gtmcrypt_key")
	set iv=$ztrnlnm("gtmcrypt_iv")
	; save the pid
	set p=type_"_pid"
	open p:newversion
	use p
	write $job,!
	close p
	set t="test"
	quit

processStrUtf(type,t,a)
	do init2(type,t)
	for i=1:1:^readcnt do
	. set ^readcnt(type)=i
	. set b=$Extract(a,1,1+$Random(599))
	. write b,!
	. read y
	. if $za!$zeof set za=$za set zeof=$zeof use $p write "$za= ",za," $zeof= ",zeof,! set ^quit=2 halt
	. if b'=y use $p write "GTM-E-BADINPUT: ",!,"Expected: ",!,b,!,"Read: ",!,y,! set ^quit=1 halt
	do finish(type)
	quit

processFix(type,t,a)
	do init2(type,t)
	for i=1:1:^readcnt do
	. set ^readcnt(type)=i
	. write a
	. read y
	. if $za!$zeof set za=$za set zeof=$zeof use $p write "$za= ",za," $zeof= ",zeof,! set ^quit=2 halt
	. if a'=y use $p write "GTM-E-BADINPUT: ",!,"Expected: ",!,a,!,"Read: ",!,y,! set ^quit=1 halt
	do finish(type)
	quit

init2(type,t)
	use t
	; set the pid for sendintr.m
	set ^doreadpid(type)=$job
	quit

smallutf(a)
	; create 91 utf-8 character string
	set a=$char(300)
	for i=301:1:390 do
	. set a=a_$char(i)
	quit

bigutf(a)
	; create 600 utf-8 character string
	set a=$char(300)
	for i=301:1:899 do
	. set a=a_$char(i)
	quit

finish(type)
	use $p
	write type,": ","Input matches output",!
	set ^quit=1
	quit

cont1
	; dump state
	set z=$za
	set zeof=$zeof
	; use $device to make sure ztrap caused by blocked write to pipe
	set d=$device
	if "1,Resource temporarily unavailable"=d do
	. set ^maxsnooze=^maxsnooze*2 ;slow down interrupts now
	. set ^minsnooze=^minsnooze*2
	. use $p
	. write "pipe full, i= ",i," $za = ",z,!
	. set ^unavcnt(type)=^unavcnt(type)+1
	. if 100=^unavcnt(type) set ^quit=4 halt
	. set i=i-1 ;do it again
	. use t
	else  use $p write "$device= ",d,"$za= ",z," $zeof= ",zeof,! set ^quit=9 halt
	quit
