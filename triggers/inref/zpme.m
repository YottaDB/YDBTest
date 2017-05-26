;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This test case is for GTM-8273 where ZPRINTing or $TEXT()ing a trigger without the routine name from the active
; trigger would not work and munge the routine entry such that future attempts to access the trigger's text using
; the full label offset and routine name would not work.
;
; The verifies both single and multi-line triggers for zprint and $text() independently. Additionally this test
; confirms that ZBreak works using relative entryrefs from inside a trigger.
zpme
	; kill pre-existing ^info and setup triggers
	kill ^info
	do text^dollarztrigger("tfile^zpme","zpme.trg")	; move trig defs from comments below to a file
	do file^dollarztrigger("zpme.trg",1)		; define triggers from the just-created file
	; Execute each trigger and then compare the output of ZPrint and $TEXT()
	for gvn="^zpmeONE","^dtmeONE","^zpmeMUL","^dtmeMUL" do
	.	do ^echoline  ; Split the output for each test execution
	.	set tname=gvn_"#"
	.	write "Execute ztrigger @",gvn," and the triggers will exercise ",$select(gvn["zp":"zprint",1:"$text()"),!
	.	ztrigger @gvn
	.	; ZPrint the routine out to a file and then read it in
	.	set zpfn=$extract(gvn,2,$length(gvn))_".zprint"
	.	open zpfn:newversion
	.	write "Compare 'zprint ",tname use zpfn zprint @tname close zpfn use $p
	.	open zpfn:readonly use zpfn for i=1:1  read zpfn(i) quit:$zeof
	.	set zplines=i use $p
	.	write "' 'write $text(",tname,")' line by line ",!
	.	; Now compare it line by line with $TEXT()
	.	for i=1:1:10 quit:0=$length($text(@("+"_i_tname)))  do
	.	.	if zpfn(i)'=$text(@("+"_i_tname)) write "TEST-F-FAIL: ",! zwrite
	.	if zplines'=i write "TEST-F-FAIL: comparing ",zpfn," to $text()",! zwrite  close zpfn
	.	else  close zpfn:delete
	; Check that each trigger passed
	do ^echoline
	set next="^info("""")"
	for  set next=$query(next) quit:next=""  if "PASS"'=@next write "TEST-F-FAIL" zwr ^?.E halt
	; Confirm that ZBreak already works with relative entryrefs, since there is not test for this
	do ^echoline
	ztrigger ^zbONE,^zbMUL
	do ^echoline
	quit

; Compare two strings, this function is merely a proxy for comparing the output of two $TEXT()s
cmp(str1,str2)
	if str1=str2 quit "PASS"
	quit "TEST-F-FAIL: "_$zwrite(str1)_" "_$zwrite(str2)

; The following two functions exist to zprint +l and zprint @$zpos to a file while inside a trigger
; and then compare the two printed lines
open(zpos)
	new zpf
	set zpf=$ztname_".zcmp"_zp
	open zpf:(newversion)
	use zpf
	quit zpf
close(zpf)
	new i,line
	close zpf
	open zpf:readonly
	use zpf
	for i=1:1:2 read line(i)
	if line(1)=line(2) close zpf:delete quit "PASS"
	else  close zpf
	quit "TEST-F-FAIL: +"_l

tfile
	;-*
	;
	;; Single line triggers for $TEXT() and ZPRINT testing
	;+^zpmeONE -name=zpmeONE -commands=ztr -xecute="set l=1,zp=$zpos,f=$$open^zpme() zprint +l zprint @zp set ^info($text(+0),zp,""zprint"")=$$close^zpme(f)"
	;+^dtmeONE -name=dtmeONE -commands=ztr -xecute="set l=1,zp=$zpos,^info($text(+0),zp,""$text"")=$$cmp^zpme($text(+l),$text(@zp))"
	;
	;; Multi line triggers for $TEXT() and ZPRINT testing
	;+^zpmeMUL -name=zpmeMUL -commands=ztr -xecute=<<
	; set l=1,zp=$zpos,f=$$open^zpme() zprint +l zprint @zp set ^info($text(+0),zp,"zprint")=$$close^zpme(f)
	; set l=2,zp=$zpos,f=$$open^zpme() zprint +l zprint @zp set ^info($text(+0),zp,"zprint")=$$close^zpme(f)
	;onlab set l=0,zp=$zpos,f=$$open^zpme() zprint onlab+l zprint @zp set ^info($text(+0),zp,"zprint")=$$close^zpme(f)
	; set l=1,zp=$zpos,f=$$open^zpme() zprint onlab+l zprint @zp set ^info($text(+0),zp,"zprint")=$$close^zpme(f)
	; set l=5,zp=$zpos,f=$$open^zpme() zprint +l zprint @zp set ^info($text(+0),zp,"zprint")=$$close^zpme(f)
	;>>
	;+^dtmeMUL -name=dtmeMUL -commands=ztr -xecute=<<
	; set l=1,zp=$zpos,^info($text(+0),zp,"$text")=$$cmp^zpme($text(+l),$text(@zp))
	; set l=2,zp=$zpos,^info($text(+0),zp,"$text")=$$cmp^zpme($text(+l),$text(@zp))
	;onlab set l=0,zp=$zpos,^info($text(+0),zp,"$text")=$$cmp^zpme($text(onlab+l),$text(@zp))
	; set l=1,zp=$zpos,^info($text(+0),zp,"$text")=$$cmp^zpme($text(onlab+l),$text(@zp))
	; set l=5,zp=$zpos,^info($text(+0),zp,"$text")=$$cmp^zpme($text(+l),$text(@zp))
	;>>
	;
	;; Single and Multi line triggers that confirm ZBreak's existing ability to operate inside a trigger
	;+^zbONE -name=zbONE -commands=ztr -xecute="zbreak +1:""zshow"" ztrigger:$ztlevel<2 ^zbONE"
	;+^zbMUL -name=zbMUL -commands=ztr -xecute=<<
	; zbreak x:"zshow" zbreak +2:"zshow" zbreak x+1:"zshow"
	; write "line 2",!
	;x zwrite $ztname
	; write "line 4",!
	;>>
	quit
