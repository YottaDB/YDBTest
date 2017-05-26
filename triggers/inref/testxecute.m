;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Testing the execution of triggers
	; * Intrinsic variables outside of triggers --> moved to isvcheck.csh
	; * Trigger execution for each command
	; * Trigger subscript pattern matching
	; * Intrinsic variables inside of triggers
	; * Trigger piece + delim matching
	; * Trigger order must be random (see triggers/u_inref/triggerorder.csh)
	; Trigger name collision handling (see trignameuniq tests, manually_start and triggers)
	;
testxecute
	do ^echoline
	do simplematch
	do subsmatch
	quit

	;-------------------------------------------------------------
	;  2. Matching simple triggers
	;  ZTOLdval, ZTDAta testing
simplematch
	do ^echoline
	write "Matching simple triggers",!
	;set ^tdata so that we have interesting ZTOLdvalue and ZTDAta
	set ^tdata="1|2|3|4|5|6|7|8|9|0"

	; load trigger file
	do text^dollarztrigger("tfilesimple^testxecute","testxecute_simple.trg")
	do file^dollarztrigger("testxecute_simple.trg",1)

	; Naked Kill
	kill ^tdata

	; SET
	write "Should fire","SET",!
	set ^a="99|red|balloons"
	set a="99|blue|balloons"
	set a("99","red","balloons")="some red data"
	set a("99","blue","balloons")="some blue data"
	set a("42","AG","silver")="some chemistry data"
	set x=$increment(^a)
	merge ^a=a

	set x=$increment(^c)
	set x=$increment(^c)

	; KILL, ZKILL
	set ^b="I am a global"
	set ^b("subscript")="I am a subscript"
	set ^b("subscript",1)="I am a subscript, node 1"
	set ^b("subscript",2)="I am a subscript, node 2"
	write "Should fire twice","ZKILL",!
	zkill ^b("subscript")
	zkill ^b("subscript"),^b("subscript",2)
	set ^b("subscript")="I am a subscript"
	set ^b("subscript",2)="I am a subscript, node 2"
	write "Should fire twice","ZWITHDRAW",!
	zwithdraw ^b("subscript"),^b("subscript"),^b("subscript",2)
	write "Should fire","KILL",!
	kill ^b
	kill ^b  ; No triggers should fire for this KILL

	; ZTKILL
	zkill ^a("99","blue","balloons")
	kill ^a

	do ^echoline
	quit

tfilesimple
	;-*
	;; testing the firing of each command
	;+^a -command=S -xecute="do ^twork" -name=myS
	;+^b -command=K -xecute="do ^twork" -name=myK
	;+^b(:) -command=ZK -xecute="do ^twork" -name=myZK
	;+^b(:,:) -command=ZW -xecute="do ^twork" -name=myZW
	;+^a -command=ZTK -xecute="write ""Oh no!""" -name=myZTK
	;+^a(99,:,:) -command=ZK -xecute="write ""I'm melting"",!" -name=myZTKnodes
	;+^a(99,:,:) -command=S -xecute="write ""I'm merging!"",!" -name=mySmerge
	;+^c -command=S -xecute="do ^twork set x=$increment(^d)" -name=incrementtest
	;+^d -command=K -xecute="do ^twork set ^c=$increment(^c)-^d" -name=decrementtest
	;+^tdata -command=S,K -xecute="do ^twork" -name=nakedkill
	quit

	;-------------------------------------------------------------
	; 3. Subscript matching
	; - pattern
	; - one subscript
	; - range
	; - ZTDAta testing
subsmatch
	do ^echoline
	write "Subscript matching",!
	; load trigger file
	do text^dollarztrigger("tfilesubs^testxecute","testxecute_subs.trg")
	do file^dollarztrigger("testxecute_subs.trg",1)

	write "singles",!
	set ^singles(100)="one two three four"
	set ^("ape")="one two three four"
	set ^singles("~ tilde")="punctuated reality"
	set ^singles("FAST")="a b c d"
	set ^("m")="MUMPS!"
	set ^singles("martin")="MUMPS!"
	set ^singles("ursulla")="GT.M!"
	kill ^singles(1)
	zwrite ^fired kill ^fired

	write "ranges",!
	for i=1:1:20  set ^range(i)=i*2
	write "Will fire K even+prime trigger",!
	for i=4:4:20  kill ^range(i)
	write "Will fire ZK twentybelow trigger",!
	for i=2:4:20  zkill ^range(i)
	set (^range(21),^range(50),^range(1001))="all above twenty"
	kill ^range
	zwrite ^fired kill ^fired

	write "patterns",!
	set ^A("J","JackO","ThisIsAnAnimal")="test first pattern match",^A("J","Jackal","This should not fire")="Should not fire"
	set ^A("t","it","ornithopter")="test first pattern match again"
	zkill ^A("t","it","ornithopter"),^A("J","JackO","ThisIsAnAnimal")
	kill ^A("J","Jackal","This should not fire")
	set ^C($char(7))="You can ring my bell"
	set ^C($char(32))="Space cadets shouldn't fire this trigger"
	kill ^C($char(7))
	set ^E($char(126),$char(1,2,3,4,5,6,7,32,96))="I accept any inputs"
	set ^E($char(126),$char(1,2,3,4,5,6,7,32,96),6666)="I accept any inputs, but my extra subscript doesn't match any trigger"
	kill ^E
	set ^U("Z","UPPERCASE")="should match the UPPERCASE trigger",^U("l","lowercase")="should not match the UPPERCASE trigger"
	set ^L("A","UPPERCASE")="should not match the lowercase trigger",^L("a","lowercase")="should match the lowercase trigger"
	set (^N(1),^N(9999999),^N("101010101"),^N("NaN"))="testing number matching, should fire for only ^N(1)"
	kill ^N
	set ^P(",")="comma trigger"
	set ^P(",",1)="no comma trigger"
	set ^P("a")="no trigger"
	set ^P("a",1)="no trigger"
	kill ^P("~")
	kill ^P("a")
	kill ^P(",")
	set ^zeta($char(65,90,97,122,49,48,46,63))="should fire a trigger",^zeta($char(65,90,97,122,49,48,46,56))="should not fire a trigger"
	kill ^zeta($char(65,90,97,122,49,48,46,63)),^zeta($char(65,90,97,122,49,48,46,56))
	zwrite ^fired kill ^fired

	write "compound",!
	set ^a("000-00-0000","Zombie",1)="good luck with that SSN"
	set ^a("987-65-4321","Herb",1)="Herb's first child"
	set ^a("987-65-4321","Herb",2)="Herb's second child doesn't trigger"
	set ^a("98A-65-4321","Herb",1)="Herb doesn't have a hexdecimanl SSN"
	set ^a("987-65-4320","zorg",1)="zorg's last child"
	set ^a("987-42-4320","fRODO",1)="Baggins"

	set ^b("333-22-4444","Mumpsman",1)="some data does fire"
	set ^b("333-22-4444","Mumps man",1)="some data doesn't fire"
	set ^b("22-7777777","MUMPSMan",1)="some data does fire"
	set ^b("22-7777777","MUMPS Man",1)="some data doesn't fire"
	zwrite ^fired kill ^fired
	do ^echoline
	quit

rtn
	if $ztslate="" set $ztslate=1
	if $ztslate=1 do
	.	do operation^twork
	.	do traps^twork
	.	do common^twork
	.	do levels^twork
	.	do extdata^twork
	set $ztslate=1+$ztslate
	set ztname=$ZTName,$piece(ztname,"#",$length(ztname,"#"))=""  ; nullify region disambigurator
	set x=$increment(^fired(ztname))
	set x=$increment(^fired)
	quit

tfilesubs
	;-*
	;; match each type
	;; single subscripts
	;+^singles(:) -command=ZTK -xecute="do rtn^testxecute"
	;+^singles(100) -command=S,K -xecute="do rtn^testxecute"
	;+^singles("a":$char(123)) -command=S,K -xecute="do rtn^testxecute"
	;+^singles(?.A) -command=S,K -xecute="do rtn^testxecute"
	;+^singles(?.L) -command=S,K -xecute="do rtn^testxecute"
	;+^singles(?1"m";?1"u";?1"p";?1"s") -command=S,K -xecute="do rtn^testxecute"
	;+^singles("martin";"ursulla";"mitch";"peter";"sally") -command=S -xecute="do rtn^testxecute"
	;
	;; ranges
	;+^range(1;2;3;5;7;11;13;17;19) -command=S,K -xecute="do rtn^testxecute" -name=prime
	;+^range(2;4;6;8;10;12;14;16;18) -command=S,K -xecute="do rtn^testxecute" -name=even
	;+^range(21:) -command=S,K -xecute="do rtn^testxecute" -name=harer
	;+^range(1:10;11:19) -command=S,ZK -xecute="do rtn^testxecute" -name=twentybelow
	;+^range -command=K -xecute="do rtn^testxecute if $ZTDAta>1 set p="""" for  set p=$order(^range(p)) quit:p=""""  zkill ^range(p)" -name=killat
	;
	;; patterns
	;+^A(?1A,?2.5A,?10.A) -command=S,ZK -xecute="do rtn^testxecute"
	;+^C(?1C) -command=S,K -xecute="do rtn^testxecute"
	;+^E(?1E,?.E) -command=S,ZTK -xecute="do rtn^testxecute"
	;+^U(?1U,?.U) -command=S,ZK -xecute="do rtn^testxecute"
	;+^L(?1L) -command=S,K -xecute="do rtn^testxecute"
	;+^N(?1N) -command=S,ZTK -xecute="do rtn^testxecute"
	;+^P(?1P) -command=S,K -xecute="do rtn^testxecute"
	;+^zeta(?1A1U1L1E1N1P1"?") -command=S,ZK -xecute="do rtn^testxecute"
	;;^U(?1U) -command=S,ZK -xecute="do rtn^testxecute"
	;
	;; compound
	;+^a(?3N1"-"2N1"-"4N,"A":"Z",1) -command=S -xecute="do rtn^testxecute"
	;+^a(?3N1"-"2N1"-"4N,"a":"{",1) -command=S -xecute="do rtn^testxecute"
	;+^a(?2N1"-"7N,"A":"Z",:) -command=S -xecute="do rtn^testxecute"
	;+^a(?2N1"-"7N,"A":"{",:) -command=S -xecute="do rtn^testxecute"
	;+^a(?2N1"-"7N,"a":"z",:) -command=S -xecute="do rtn^testxecute"
	;+^a(?2N1"-"7N,"a":"{",:) -command=S -xecute="do rtn^testxecute"
	;+^b(?1(2N1"-"7N,3N1"-"2N1"-"4N),?1U.L;?1U.A,1) -command=S,K -xecute="do rtn^testxecute"
	;+^b(?1(2N1"-"7N,3N1"-"2N1"-"4N),?1L.A,1) -command=S,K -xecute="do rtn^testxecute"
	quit

