;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm3907 ; check side-effects on locals as operands to non-Boolean binary operator or functions
	;
	if '$data(act) new act set act="if $increment(cnt) use $principal zshow ""v"""
	new (act),$etrap,$estack
	set $ecode="",$etrap="do ^incretrap",vms=$zversion["VMS";,$zstep="zprint @$zposition zstep into"
	set r=$$arithTest()
	if r'=4,$increment(cnt) xecute act
	set r=$$catTest()
	if r'="value->sub value",$increment(cnt) xecute act
	set %=2,r=$$times(%,$increment(%))
	if r'=6,$increment(cnt) xecute act
	set %=2,r=$$times(.%,$increment(%))
	if r'=9,$increment(cnt) xecute act
	set %=1,r=%*$$double()*$$double()
	if r'=8,$increment(cnt) xecute act
	set r=$$funcTest()
	if r'=$justify(1,4),$increment(cnt) xecute act
	set r=$$relTest()
	if r'=1,$increment(cnt) xecute act
	set r=$$subTest()
	if r'=1,$increment(cnt) xecute act
	write !,$select('$get(cnt):"No",1:cnt)," errors from ",$text(+0),!
	quit
;
arithTest()
	new $estack
	set %=2,%i="%",r=%*$increment(@%i)
	if r'=6,$increment(cnt) xecute act
	set %(1)=2,r=%(1)*$increment(%(1))
	if r'=6,$increment(cnt) xecute act
	set %=2,%i="%",%3=3,r=%*$increment(%,%3)
	if r'=10,$increment(cnt) xecute act
	set %=2,%3=3,%i="%",r=%*$increment(@%i,%3)
	if r'=10,$increment(cnt) xecute act
	set %=2,%3=3,%i3="%3",r=%*$increment(%,@%i3)
	if r'=10,$increment(cnt) xecute act
	set %=2,%3=3,%i="%",%i3="%3",r=%*$increment(@%i,@%i3)
	if r'=10,$increment(cnt) xecute act
	set %=2,%i="%",r=%*$increment(@%i)
	if r'=6,$increment(cnt) xecute act
	set %=2,r=1+(%*$increment(%))
	if r'=7,$increment(cnt) xecute act
	set %=1,r=%#$$four
	if r'=1,$increment(cnt) xecute act
	set %=0_2,r=%*$increment(%)
	if r'=6,$increment(cnt) xecute act
	set %=1,r=%*%*$$four()						; natural temp - no warning
	if r'=4,$increment(cnt) xecute act
	set %=1,r=%*$$four()
	if r'=4,$increment(cnt) xecute act
	set %="01a",r=%*$$fours
	if r'=4,$increment(cnt) xecute act
	set %=1
	quit %*$$four()
catTest()
	new $estack
	set %="value",r=%_"->"_$$catSub()
	if r'="value->sub value",$increment(cnt) xecute act
	set %="value",r=%_"->"_$$catSub()_"->"_$$catSub()
	if r'="value->sub value->sub value",$increment(cnt) xecute act
	set %(1)="value",r=%(1)_"->"_$$catSub()
	if r'="value->sub value",$increment(cnt) xecute act
	set %="value"
	quit %_"->"_$$catSub()
catSub()
	set (%,%(1))="sub value"
	quit %
double()
	set %=%*2
	quit %
e2()
	set %=$extract(%,2)
	quit %
ex(x)
	quit $extract(12,x)
fncode()
	set %=5
	quit "+"
four()
	set %=4
	quit %
fours()
	set ^%="04b"
	quit ^%
funcTest()
	new $estack
	set (%,%1)="0abcdefgh9",r=$ascii(%,$$reverse)
	if r'=$ascii(%1,%),$increment(cnt) xecute act
	set (%(1),%1)="0abcdefgh9",r=$ascii(%(1),$$reverse)
	if r'=$ascii(%1,%(1)),$increment(cnt) xecute act
	set (%,%1)="0abcdefgh9",r=$ascii(%,$$reverse)
	if r'=$zascii(%1,%),$increment(cnt) xecute act
	set (%(1),%1)="0abcdefgh9",r=$ascii(%(1),$$reverse)
	if r'=$zascii(%1,%(1)),$increment(cnt) xecute act
	set (%,%1)="0abcdefgh9",r=$ascii(%,$$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r($$r())))))))))))))))))))))))))))))))))
	if r'=$ascii(%1,%),$increment(cnt) xecute act
	set %=65,r=$char(%,$increment(%),%,$increment(%),%)		; $char() has natural temps, so no warnings
	if r'=$char(65,66,66,67,67),$increment(cnt) xecute act
	set %=65,r=$char(%,$$inc(),%,$$inc(),%)
	if r'=$char(65,66,66,67,67),$increment(cnt) xecute act
	set %=65,r=$char(%,$increment(%),%,$increment(%),%)
	if r'=$zchar(65,66,66,67,67),$increment(cnt) xecute act
	set %=65,r=$char(%,$$inc(),%,$$inc(),%)
	if r'=$zchar(65,66,66,67,67),$increment(cnt) xecute act
	; $data() only takes one argument
	set %="abc",r=$extract(%,$increment(%),$increment(%))
	if r'="ab",$increment(cnt) xecute act
	set %="abc",r=$zsubstr(%,$increment(%),$increment(%))
	if r'="ab",$increment(cnt) xecute act
	set %="abc",r=$zextract(%,$increment(%),$increment(%))
	if r'="ab",$increment(cnt) xecute act
	set %="abcabc",r=$find(%,$$e2,$increment(%,2))
	if r'=$find("abcabc","b",2)
	set %="abcabc",r=$zfind(%,$$e2,$increment(%,2))
	if r'=$find("abcabc","b",2)
	set %=1,r=$fnumber(%,$$fncode,$increment(%))
	if r'="+1.000000",$increment(cnt) xecute act
	set %=1,r=$get(%,$increment(%))
	if r'=1,$increment(cnt) xecute act
	set (%,^%)=1,%i="^%",%ii="@%i",r=$get(@%ii,$increment(^%))
	if (r'=1)!("^%"'=$reference),$increment(cnt) xecute act
	kill %
	set r=$get(%,$increment(%))
	if r'=1,$increment(cnt) xecute act
	set %="^X",str="@%",^X="^X",^Y="^Y",^Z="^Z",r=$get(@str,$$Y)
	if r'="^X",$increment(cnt) xecute act
	set %=1,r=$increment(%,$increment(%))				; $increment() has it's own ordering, so no warnings
	if r'=4,$increment(cnt) xecute act
	set %(1)=1,r=$increment(%(1),$increment(%(1)))
	if r'=4,$increment(cnt) xecute act
	set (i,j,x(1,2))=1,x(2,2)=0,^id(2)=2,r=$incr(i,1&x(j,^id($incr(j))))
	if r'=2,$increment(cnt) xecute act
	set %=1,r=$justify(%,$increment(%),$increment(%))
	if r'=$justify(1,2,3),$increment(cnt) xecute act
	set %=1,r=$justify(%,$$four)
	if r'=$justify(1,4),$increment(cnt) xecute act
	set %=1,r=$justify(%,$increment(%),$increment(%))
	if r'=$justify(1,2,3),$increment(cnt) xecute act
	set %=1,%i="%",r=$justify(%,$increment(@%i))
	if r'=$justify(1,2),$increment(cnt) xecute act
	set %=1,x=1,r=$s(x:$justify(%,$increment(%),$increment(%)),1:"")
	if r'=$justify(1,2,3),$increment(cnt) xecute act
	set %=1,r=$zjustify(%,$increment(%),$increment(%))
	if r'=$zjustify(1,2,3),$increment(cnt) xecute act
	set %=1,r=$zjustify(%,$$four)
	if r'=$zjustify(1,4),$increment(cnt) xecute act
	set %=1,r=$zjustify(%,$increment(%),$increment(%))
	if r'=$zjustify(1,2,3),$increment(cnt) xecute act
	set %=1,%i="%",r=$zjustify(%,$increment(@%i))
	if r'=$zjustify(1,2),$increment(cnt) xecute act
	set %=1,x=1,r=$s(x:$justify(%,$increment(%),$increment(%)),1:"")
	if r'=$zjustify(1,2,3),$increment(cnt) xecute act
	set %="a1b1c",r=$length(%,$increment(%))
	if r'=$length("a1b1c",1),$increment(cnt) xecute act
	set %="a1b1c",r=$zlength(%,$increment(%))
	if r'=$zlength("a1b1c",1),$increment(cnt) xecute act
	set %(1)="",%1=1,r=$name(%(%1),$increment(%1))
	if r'="%(1)",$increment(cnt) xecute act
	set ^%(1)="",%1=1,%i="^%(%1)",%ii="@%i",r=$name(@%ii,$increment(%1))
	if (r'="^%(1)")!("^%(1)"'=$reference),$increment(cnt) xecute act
	set %="^X",str="@%",^X="^X",^Y="^Y",^Z="^Z",r=$name(@str,$$Y)
	if r'="^X",$increment(cnt) xecute act
	; $next() only takes one argument
	set (%,%(1,0),%(1,1))=0,r=$order(%(1,%),$increment(%,-1))
	if r'="",$increment(cnt) xecute act
	set (%,%(0,0),%(0,1))=0,r=$order(%(0,0),$increment(%,-1))
	if r'="",$increment(cnt) xecute act
	set (^%,^%(0,0),^%(0,1))=0,%i="^%",%ii="@%i",r=$order(@%ii,$increment(^%,-1))
	if r'="",$increment(cnt) xecute act
	set %="^X",str="@%",^X="^X",^Y="^Y",^Z="^Z",r=$order(@str,$$Y)
	if r'="^Y",$increment(cnt) xecute act
	kill x for i=-3:1:3 set (x(0,i),x(i),^x(0,i),^x(i))=i
	set i=-1 if 0'=$order(x(i),$$I),$increment(cnt) xecute act
	set i=-1 if 0'=$order(@"x(i)",$$I),$increment(cnt) xecute act
	set i=-1 if 2'=$order(x($$I),i),$increment(cnt) xecute act
	set i=-1 if 2'=$order(@"x($$I)",i),$increment(cnt) xecute act
	set i=-1 if 0'=$order(x(0,i),$$I),$increment(cnt) xecute act
	set i=-1 if 0'=$order(@"x(0,i)",$$I),$increment(cnt) xecute act
	set i=-1 if 2'=$order(x(0,$$I),i),$increment(cnt) xecute act
	set i=-1 if 2'=$order(@"x(0,$$I)",i),$increment(cnt) xecute act
	set i=-1 if 0'=$order(^x(i),$$I),$increment(cnt) xecute act
	set i=-1 if 0'=$order(@"^x(i)",$$I),$increment(cnt) xecute act
	set i=-1 if 2'=$order(^x($$I),i),$increment(cnt) xecute act
	set i=-1 if 2'=$order(@"^x($$I)",i),$increment(cnt) xecute act
	set i=-1 if 0'=$order(^x(0,i),$$I),$increment(cnt) xecute act
	set i=-1 if 0'=$order(@"^x(0,i)",$$I),$increment(cnt) xecute act
	set i=-1 if 2'=$order(^x(0,$$I),i),$increment(cnt) xecute act
	set i=-1 if 2'=$order(@"^x(0,$$I)",i),$increment(cnt) xecute act
	set %="a1b1c",r=$piece(%,$increment(%),$increment(%),$increment(%))
	if r'="b1c",$increment(cnt) xecute act
	set %="a1b1c",r=$zpiece(%,$increment(%),$increment(%),$increment(%))
	if r'="b1c",$increment(cnt) xecute act
	; $query() only takes one argument
	; $qlength() only takes one argument
	set %="a(2,3)",r=$qsubscript(%,$increment(%))
	if r'=2,$increment(cnt) xecute act
	; $random() only takes one argument
	; $reverse() only takes one argument
	set %=0,r=$select(%<$increment(%):1,1:0)
	i r'=1,$increment(cnt) xecute act
	set r=1,r=0&$select($select($view("full_boolean")["GT.M":undefined,1:r):1,1:0)
	i r'=0,$increment(cnt) xecute act
	set r=0,r=1!$select($select($view("full_boolean")["GT.M":undefined,1:r):1,1:0)
	i r'=1,$increment(cnt) xecute act
	set %=$stack,r=$stack(%,$$stackcode),v=$zposition		;protected by coerce to int
	if r'=v,$increment(cnt) xecute act
	; $text() only takes one argument
	if r'=v,$increment(cnt) xecute act
	set %="a1b1c",r=$translate(%,$increment(%),$increment(%))
	if r'="a2b2c",$increment(cnt) xecute act
	set %="a1b1c",r=$ztranslate(%,$increment(%),$increment(%))
	if r'="a2b2c",$increment(cnt) xecute act
	set %="NOISOLATION",r=$view(%,$$region)
	if r'=0,$increment(cnt) xecute act
	; $zahandle() only takes one argument
	;$zbit*
	set:vms r="ABC" set:'vms %="abc",r=$zconvert(%,$$kill("U"))
	if r'="ABC",$increment(cnt) xecute act
	set %="55555",r=$zdate(%,$$kill("DAY-MON-YEAR"))
	if r'="SUN-FEB-1993",$increment(cnt) xecute act
	; $zjobexam() only takes one argument
	; $zmessage() only takes one argument
	set %="test.m",r=$zparse(%,$$kill("name"))
	if r'=$select(vms:"TEST",1:"test"),$increment(cnt) xecute act
	set %="foo",r=$zparse(%,"","bar",$$kill("a.m")),v=$zparse($select(vms:"[]",1:"./")) set:vms v=$extract(v,1,$length(v)-2)
	if $piece(r,v,2)'=$select(vms:"FOO.M;",1:"foo.m"),$increment(cnt) xecute act
	; $zprevious() only takes one argument
	; $zqgblmod() only takes one argument
	if $zver["HP-PA"!vms set r=1
	else  xecute "set %=""select"",r=$ztrigger(%,$$kill(""*""))"	; XECUTE avoids compile error on HP-PA
	if r'=1,$increment(cnt) xecute act
	set %=$s(vms:"GTM$DIST",1:"gtm_dist"),r=$ztrnlnm(%,,,,,$$kill("length")),v=$l($ztrnlnm($s(vms:"GTM$DIST",1:"gtm_dist")))
	if r'=v,$increment(cnt) xecute act
	; $zwidth() only takes one argument
	set %=1
	quit $justify(%,$$four)
I()
	set i=i+2
	quit 1
inc()
	quit $increment(%)
kill(ret)
	kill %
	quit ret
r(x)
	set %=$reverse(%)
	quit %
region()
	set %="REGION"
	quit "^a"
relTest()
	set %=1,r=%[$$four()
	if r'=0,$increment(cnt) xecute act
	set %=1
	quit %<$$four()
reverse(x)
	set (%,%(1))=$reverse(%)
	quit %
stackcode()
	set %=%-1
	quit "PLACE"
subTest()
	new $estack
	kill ^% set (%,^%(1,2))=1,^%(2,2)=2,r=^%(%,$increment(%))
	if r'=1,$increment(cnt) xecute act
	kill ^% set (%(1),^%(1,2))=1,^%(2,2)=2,r=^%(%(1),$increment(%(1)))
	if r'=1,$increment(cnt) xecute act
	set (%,%(1,2))=1,%(2,2)=2,r=%(%,$increment(%))
	if r'=1,$increment(cnt) xecute act
	set (%(1),%(1,2))=1,%(2,2)=2,r=%(%(1),$increment(%(1)))
	if r'=1,$increment(cnt) xecute act
	set (%(1),%(1,2))=1,%(2,2)=2,r=%(1*%(1),$increment(%(1)))	; natural temp - no warning
	if r'=1,$increment(cnt) xecute act
	set (%(1),%(1,2))=1,%(2,2)=2,r=%(%(%(1)),$increment(%(1)))
	if r'=1,$increment(cnt) xecute act
	set (%(1),%(1,2))=1,%(2,2)=2,r=%($$ex(%(1)),$increment(%(1)))	; natural temp - no warning
	if r'=1,$increment(cnt) xecute act
	set %=1,r=$name(^%(%,$increment(%)))
	if r'="^%(1,2)",$increment(cnt) xecute act
	set %(1)=1,r=$name(^%(%(1),$increment(%(1))))
	if r'="^%(1,2)",$increment(cnt) xecute act
	set %=1,r=$name(%(%,$increment(%)))
	if r'="%(1,2)",$increment(cnt) xecute act
	set %(1)=1,r=$name(%(%(1),$increment(%(1))))
	if r'="%(1,2)",$increment(cnt) xecute act
	set (%(1),%(1,2))=1,%(2,2)=2
	quit %(%(1),$increment(%(1)))
times(a,b)
	quit a*b
Y()
	set %="^Y"
	quit 1
