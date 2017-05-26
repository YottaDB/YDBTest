;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2008, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9I07003009; test that a zhelp error leaves $ecode=""
	write "This test works by invoking zhelp with a valid and invalid topic",!
	write "Expect an error from GT.M help utility",!
	new $etrap
	set $ecode="",$etrap="set ($etrap,$ecode)="""" goto skip"
	set $zgbldir="$gtm_dist/gtmhelp.gld"
	set file="zhelp.out" open file:newversion use file
skip	do ^GTMHELP("functions","foo")
	close file
	write !,$select((""=$ecode)&("set ($etrap,$ecode)="""" goto skip"=$etrap):"PASS",1:"FAIL"),"1 from ",$text(+0)
	write !,"Enter a valid topic to see it works",!
	open file:append use file
	zhelp "comm zhelp"
	close file
	open file:readonly use file
	read x,x
	close file
	write !,$select(("ZHelp"=x)&(""=$ecode)&("set ($etrap,$ecode)="""" goto skip"=$etrap):"PASS",1:"FAIL"),"2 from ",$text(+0)
	quit
