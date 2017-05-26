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
	;  need test cases that cause the compilation to fail
	;  1. test cases that are valid text, but invalid M like
	;  	-xecute="for quit:x=0 set x=0"; need an extra  space after quit
	;  	-xecute="set """ ; cannot set a quotation mark
	;  	-xecute="set a=1 write a!" ; cannot write a! must be a,!
	;  2. test cases that are valid M but fail compilation
	;  3. have a routine try to zlink itself
	;  4. test case that checks for compilation failures in routines
compile
	set $ETrap="w $c(9),""$ZSTATUS="",$zstatus,! s $ecode="""""
	do install
	do failing
	do succeeding
	do failintrigrtn
	quit

install
	do ^echoline
	write "Invalid M code in the Xecute string",!
	do text^dollarztrigger("tfilefail^compile","compile_fail.trg")
	do file^dollarztrigger("compile_fail.trg",1)
	do all^dollarztrigger

	do ^echoline
	write "Invalid code the will pass compilation",!
	do text^dollarztrigger("tfilebadpass^compile","compile_badpass.trg")
	do file^dollarztrigger("compile_badpass.trg",1)
	do all^dollarztrigger

	do ^echoline
	write "Routines that will and won't pass compilation",!
	do text^dollarztrigger("tfilertnpass^compile","compile_rtnpass.trg")
	do file^dollarztrigger("compile_rtnpass.trg",1)
	do all^dollarztrigger

	do ^echoline
	write "Valid M code in the Xecute string",!
	do text^dollarztrigger("tfilepass^compile","compile_pass.trg")
	do file^dollarztrigger("compile_pass.trg",1)
	do all^dollarztrigger
	do ^echoline
	quit

failing
	do ^echoline
	write "failing cases first",!
	set (^c,^b,^d,^e)="FAIL"
	kill ^c,^b,^d,^e
	set ^c="FAIL"
	set ^b="FAIL"
	set ^d="FAIL"
	set ^e="FAIL"
	set ^z="FAIL"
	kill ^z
	do ^echoline
	quit

succeeding
	do ^echoline
	write "These will suceed",!
	set ^a=99
	do ^echoline
	quit

failintrigrtn
	do ^echoline
	kill ^fired
	write "Testing compilation failures in sub routines",!
	set i=1 set $piece(^r(i),",",i)=i*i
	set i=2 set $piece(^r(i),",",i)=i*i
	set i=3 set $piece(^r(i),",",i)=i*i
	set i=4 set $piece(^r(i),",",i)=i*i
	zwrite ^fired
	zwrite ^r,^s
	do ^echoline
	quit

	; Trigger routines --------------------------------------------
good
	set ztname=$ZTName,$piece(ztname,"#",$length(ztname,"#"))=""  ; nullify region disambigurator
	set x=$increment(^fired(ztname))
	set ^s(subs,1)=$ZTVAlue
	quit

	; Trigger files -----------------------------------------------
tfilefail
	;; ISV error
	;+^isverr -command=S -xecute="set $ZTRIggerop=99"
	;
	;; syntax error
	;+^syntaxerr -command=S -xecute="for quit:x=0 set x=0"
	;
	;; variable errors
	;+^lvnerr -command=S -xecute="set ""=0"
	;+^lvnerr -command=S -xecute="set a=1 write a!"
	;
	;; reference non existing label
	;+^nolabel -command=S -xecute="do DoesNotExist"
	;; bad command
	;+^e -command=S -xecute="TPRestart" -name=badcommand
	quit

tfilebadpass
	;; triggers that are badly written but pass load compilation test
	;+^b -command=S -xecute="xecute ""set $ZTRIggerop=99"""
	;+^c -command=S -xecute="set a=""$ZTRIggerop"" xecute ""set @a=99"""
	;+^d -command=S -xecute="do ^DoesNotExist"
	;+^e -command=S -xecute="TPRestart:(2>$TRestart)" -name=postconditionalbad
	;
	;; the M routine will try to zlink itself
	;+^z -command=K -xecute="do ^selflink"
	quit

tfilertnpass
	;+^r(subs=:) -command=S -xecute="set level=2 do ^badcompile"    -name=dobad
	;+^r(subs=:) -command=S -xecute="set level=1 goto ^badcompile"  -name=gotobad
	;+^r(subs=:) -command=S -xecute="set level=2 do good^compile"  -name=dogood
	;+^r(subs=:) -command=S -xecute="set level=1 goto good^compile" -name=gotogood
	quit

tfilepass
	;+^a -command=S -xecute="xecute ""write $ZTCOde,!"" ztrigger ^a"
	;+^a -command=ZTR -xecute="set b=""$ztco"" xecute ""write @b,!"""
