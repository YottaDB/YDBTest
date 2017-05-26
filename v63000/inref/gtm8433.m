;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zshowv	; verify that large locals go into smaller globals appropriately
	; names used for created locals (3>$length()) and names in routine logic (2<$length()) cannot have overlapping lengths
	new (act)
	if '$data(act) new act set act="if $increment(cnt) use $principal zshow ""*"""
	new $etrap,$estack
	set $ecode="",$etrap="do ^incretrap"
	kill ^zshow
	set max=2				; number chosen for moderate test run time
	set after="zshowv_after.txt",before="zshowv_before.txt"
	set equalsign("=")="=",equalsign("=""")="=",equalsign("""=")="=",equalsign("""=""")="=" ; verify proper handling of quoted =
	for num=1:1:max do
	. kill (act,after,before,debug,equalsign,max,num),^zshow(num)	;ensure a clean start
	. set $zstatus=""		; the lines below set three locals with varying characteristics most importantly length
	. ; 1 character (lower case) name sometimes with a leading percent-sign, a random 1 digit subscript and data<256 in length
	. set name=$select($random(10):"",1:"%")_$$^%RANDSTR(1,,"L"),@name@($random(10))=$$^%RANDSTR($random(256),,"E")
	. ; 2 character (lower case) name with data of random length up to close to 1MiB
	. set name=$$^%RANDSTR(2,,"L"),@name@($random(250))=$$^%RANDSTR((2**($random(11)+9))-(1+$length(name)),,"E")
	. ; 2 character (upper case) name with data of random length up to close to 1MiB
	. set name=$$^%RANDSTR(2,,"U"),@name=$$^%RANDSTR((2**($random(11)+9))-(1+$length(name)),,"E")
	. ; 2 character (upper_lower case) name with control characters of random length up to close to 1MiB
	. set name=$$^%RANDSTR(1,,"U")_$$^%RANDSTR(1,,"L"),@name=$$^%RANDSTR((2**($random(11)+9))-(1+$length(name)),,"C")
	. ; 2 character (whatever case) name with data of all "C" characters
	. set name=$$^%RANDSTR(1,,"L")_$$^%RANDSTR(1,,"U"),@name=$translate($justify("",2**10)," ","C")
	. ; 1 character (upper case) name sometimes with a leading percent-sign, a random 1 digit subscript and data of "P"
	. set name=$select($random(10):"",1:"%")_$$^%RANDSTR(1,,"U"),@name@($random(10))=$$^%RANDSTR($random(256),,"P")
	. set name="*foo="_name,@name	; and an alias - note: non-random names must be longer than 2 characters
	. kill name				; clean up locals so they are consistent
	. open before:(newversion:stream:recordsize=2**20-1:exception="goto badfile")
	. use before
	. zwrite				; record the "original" local variable state in a file
	. close before
	. zshow "v":^zshow(num)			; push the locals into a global
	. kill (act,after,before,debug,equalsign,max,num)	; ditch the test locals then invoke ^%ZSHOWVTOLCL to restore them
	. set name="^zshow("_num_")"			; on the last iteration, try feeding different forms to ^%ZSHOWVTOLCL
	. do  quit:num>max  if num=max for xxx=",""V"")",",1)" set $extract(name,$length(name))=xxx do  quit:num>max
	.. if '$$^%ZSHOWVTOLCL(name) xecute act set num=max+1 quit
	. kill name,xxx				; clean up locals so they are consistent
	. open after:(newversion:stream:recordsize=2**20-1:exception="goto badfile")
	. use after
	. zwrite				; record the "restored" local variable state in another file
	. close after				; the lines below read both files and check they are the same
	. kill (act,after,bateof,before,debug,equalsign,max,num)
	. open before:(readonly:stream:recordsize=2**20-1:exception="goto badfile")
	. open after:(readonly:stream:recordsize=2**20-1:exception="goto badfile")
	. use before:(rewind:exception="goto beof^"_$text(+0)),after:(rewind:exception="goto aeof^"_$text(+0))
	. for  use before read b use after read a if a'=b xecute act
beof	. if $zstatus'["IOEOF" xecute act set num=max quit
	. set ($ecode,$zstatus)="",b="%eof"	; above happens when before hits eof; below check after eof at the same point
	. use after read a xecute act set num=max quit
aeof	. if $zstatus'["IOEOF"!("%eof"'=b) xecute act set num=max quit
	. set ($ecode,$zstatus)=""
	. close after,before
	. quit
badfile	. xecute act set num=max
	. quit
	close after,before
	kill ^foo
	merge ^foo=^zshow(num)			; try an unsubscripted base
	for xxx="","(""V"")","(""V"",1)" set name="^foo"_xxx if '$$^%ZSHOWVTOLCL(name) xecute act
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
	kill ^foo				; produce messages from here down
	zshow "v":%ZSHOWvbase,"v":^zshowvb
	do ^%ZSHOWVTOLCL("^zshowvb")		; another message
	for name="foo","^foo(""V"",2)" do ^%ZSHOWVTOLCL(name)
	kill ^foo
	kill *
	kill
	set x="",$piece(x,"a",2**20-1)=""
	zshow "v":^foo
	kill x
	set ^foo("V",1,$order(^foo("V",1,""),-1)+1)="this should make it not fit properly"
	do ^%ZSHOWVTOLCL("^foo")
	kill ^foo("V",1,$order(^foo("V",1,""),-1))
	zkill ^foo("V",1)
	set ^foo("V",1,1)="sailor"
	do ^%ZSHOWVTOLCL("^foo(""V"")")
	set ^foo("V",1)="hi"
	do ^%ZSHOWVTOLCL("^foo(""V"")")
	quit
