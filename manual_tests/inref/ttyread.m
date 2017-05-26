;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2005, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ttyread	;
; *** READ THE INSTRUCTIONS IN D9F05002548.txt ***
insert	;
	set $ETRAP="zwrite $zstatus halt"
	set pass=1,ZPOS=$zposition
	do writestar
	write "Use <ctrl-?> for del because of Tru64 and AIX",!
	write "Input fgf<ctrl-U>asdfgf<ret> for X",!,"Input<up> for Y and",!,"Input bcdf<del char><ctrl-A>a<ctrl-E>e for Z",!
	do writestar
	do nopasthru("asdfgf","a","abcde","read1")
	do writestar
	write "Input aple<left><left>p<ctrl-F><ctrl-F>s for X",!,"Input qwertyu<ctrl-B><ctrl-B><ctrl-K>y<ret> for Y and",!,"Input b<up> for Z",!
	do nopasthru("apples","qwerty","qw","read2")
	do writestar
	write "Input :",!,"inseft<ctrl-B><ctrl-B>r<ret> for X",!,"alv<ctrl-A>m<right><right>ern<ret> for Y",!,"oerstrike<ctrl-A><right><ins>v<ins><ret> for Z:",!
	do nopasthru("inserft","malernv","ovrstrike","read3")
	do writestar
	do writestar("  NOTE  ")
	write "If the PC <backspace> key is mapped to send the <del> character use it for the below test.(only if it is not mapped use any other key)",!
	write "Input for X: testing<ctrl-A><ctrl-E><5 or more ctrl-F><ret>",!
	write "Input for Y: testing<ctrl-A><3 right> and keep pressing <backspace> even after it stops shrinking the input buffer. Now press <ret>",!
	write "Input for Z: <up><ret>",!,!
	do nopasthru("testing","ting","ting","read3")
	do writestar
	do readbsdel
	write "Input : inseft<ctrl-B><ctrl-B>r<ret>",!
	do pasthru("inseft"_$C(2,2)_"r","readpas")
	if 'pass do repeat
	quit

noinsert	;
	set $ETRAP="zwrite $zstatus halt"
	set pass=1,ZPOS=$zposition
	do writestar
	write "Input :",!,"inseft<ctrl-B><ctrl-B>r<ret> for X",!,"alv<ctrl-A>m<right><right>ern<ret> for Y",!,"oerstrike<ctrl-A><right><ins>v<ins><ret> for Z:",!
	do writestar
	do nopasthru("insert","mlvern","overstrike","read3")
	do writestar
	write "Input : inseft<ctrl-B><ctrl-B>r<ret>",!
	do pasthru("inseft"_$C(2,2)_"r","readpas")
	do writestar
	write "Input for X: a",!,"Input for Y: <up><ret>",!,"Input for Z: works",!
	do nopasthru("97","a","works","readstar")
	if 'pass do repeat
	quit

noedit	;
	set $ETRAP="zwrite $zstatus halt"
	set pass=1,ZPOS=$zposition
	do writestar
	read "Input 1234<left> :",x,y#2,!
	do check("1234",x,.pass)
	do check("[D",y,.pass)
	if 'pass do repeat
	quit

noecho	;
	set $ETRAP="zwrite $zstatus halt"
	set pass=1,ZPOS=$zposition
	do writestar
	write "Input the following for the next read",!,"mystr<Ctrl-B>e<Ctrl-E>y<ret>    [NOTE: input characters will not be visible]",!
	do pasthru("mystr"_$C(2)_"e"_$C(5)_"y","readnoecho")
	use $P:(echo:nopasthru)
	read "Input before<ret> :",x,!
	do writestar
	write "Input after<ret> for Y    [NOTE: input characters will not be visible]",!,"Input <up><ret> for Z",!,star,!
	use $P:NOECHO read "Input for Y :",y,! use $P:ECHO read "Input for Z :",z,!
	do check("before",x,.pass)
	do check("after",y,.pass)
	do check("before",z,.pass)
	if 'pass do repeat
	quit


stty	;
	set $ETRAP="zwrite $zstatus halt"
	set pass=1,ZPOS=$zposition
	do writestar
	read x
	do check("a1234567890123c567b",x,.pass)
	if 'pass do repeat
	quit

ctrp	;
	set pass=1,ZPOS=$zposition
	write "This is to test ctrap",!
	read "Input testing<ret> : ",x,!
	use $P:(EXCEPTION="do good":CTRAP=$C(2,5,11):TERM=$C(1,2,5,6,11,13,18,21,27))
	do writestar
	write "Input asdfgf and any of the EDITING characters.",!
	write "Any of ^B, ^E and ^K should give a message and return to read mode",!
	write "Continue giving more Editing Chars. Press <ctrl-R> when done.",!
	do writestar
	read "Input asdfgf<ctrl-A><Ctrl-F><right><Ctrl-B>",!,x,!
	write "Are you sure the message displayed if and only if the input was ^B, ^E and ^K",!
	quit

nowrap	;
	set $ETRAP="zwrite $zstatus halt"
	set pass=1,ZPOS=$zposition
	use $P:(ESCAPE:LENGTH=0:WIDTH=80:NOWRAP)
	zshow "D"
	do writestar
	write "Input nowrap<ret> for the below read",!
	do writestar
	for i=1:1:109 w "a"
	read ":",a,!
	zwrite a
	do check("nowrap",a,.pass)
	quit

good	; Exception handle
	write !,"you typed one of the EDITING Control characters ^B, ^E, ^K",!
	quit

escape	;
	set $ETRAP="zwrite $zstatus halt"
	set pass=1,ZPOS=$zposition
	do writestar
	use $P:escape
	write "use $P:escape",!
	write "Input asdfg<F9> [No <ret> will be required]",!
	read x,!
	set zb=$zb
	do check("asdfg",x,.pass)
	do check($C(27)_"[20~",zb,.pass)

	use $P:(noescape:term=$c(13))
	write "use $P:(noescape:term=$c(13))",!
	write "Input asdfg<F9><ret>",!
	read x,!
	set zb=$zb
	do check("asdfg"_$C(27)_"[20~",x,.pass)
	do check($C(13),zb,.pass)
	if 'pass do repeat
	quit

pasthru(a,tocall)	;
	write "PASTHRU",!
	use $P:(PASTHRU)
	do @tocall^ttyread(a)
	quit

nopasthru(a,b,c,tocall)	;
	write "NOPASTHRU",!
	use $P:(NOPASTHRU)
	do @tocall^ttyread(a,b,c)
	quit

read1(a,b,c)	;
	read "Input for X: ",x,!,"Single char input Y: ",y#1,!,"Five Char input Z: ",z#5,!
	do check(a,x,.pass)
	do check(b,y,.pass)
	do check(c,z,.pass)
	quit

read2(a,b,c)	;
	read "Input for X: ",x#6,!,"Input for Y : ",y,!,"Input for Z : ",z#2,!
	do check(a,x,.pass)
	do check(b,y,.pass)
	do check(c,z,.pass)
	quit

read3(a,b,c)	;
	read "Input for X: ",x,"Input for Y : ",y,"Input for Z : ",z,!
	do check(a,x,.pass)
	do check(b,y,.pass)
	do check(c,z,.pass)
	quit

readpas(a)	;
	read x,!
	do check(a,x,.pass)
	quit

readstar(a,b,c)	;
	read "Input for X: ",*x,"Input for Y: ",y,"Input for Z: ",z#5,!
	do check(a,x,.pass)
	do check(b,y,.pass)
	do check(c,z,.pass)
	quit

readnoecho(a)	;
	use $P:noecho
	read x,!
	do check(a,x,.pass)
	quit

readbsdel	;
	use $P:(NOPASTHRU)
	write "This section is to test the <del> character and the <backspace> character",!
	do writestar("NOTE")
	write "When the test requests for a <del> , input a delete *character*.",!
	write "---- Check your settings to find the key mapping to send delete character. (ascii 127).",!
	write "---- Your PC <backspace> key MAY BE mapped to send a delete character ",!
	write "When the test requests for a <backspace>, input a Backspace *character*.",!
	write "---- Check your settings to find the key mapping to send backspace character. (ascii 8).",!
	write "---- If <Backspace> key is mapped to send del char, then <CTRL BS> may send a backspace character",!
	write "---- <CTRL H> can also be used to send <backspace> character",!
	do writestar
	do writestar
	read "Input the following: backspace<ctrl A><3 ctrl F><del><ret>",!,bs,!
	read "Input the following: backspace<ctrl A><3 ctrl F><ctrl H><ret>",!,del,!
	do check("bakspace",bs,.pass)
	do check("bac"_$C(8)_"kspace",del,.pass)
	quit

atest	;
	write "PASS This is routine ATEST",!
	halt

btest	;
	write "TEST-F-FAIL: This is routine BTEST",!
	halt

abtest	;
	write "TEST-F-FAIL: This is routine ABTEST",!
	halt

test	;
	write "TEST-F-FAIL : This is routine TEST",!
	halt

check(val,input,stat)	;
	if (val=input) write "PASS",!
	else  do
	. write "TEST-F-FAIL : Expected: "
	. zwrite val
	. write "But got :"
	. zwrite input
	. set stat=0
	quit

writestar(msg);
	set star="************************************************"
	if $data(msg) write star,msg,star,!
	write star,!
	quit

repeat
	new dist,editing,lbl,rtn,STTY,term,terminfo
	set dist=$ztrnlnm("gtm_dist")
	set editing=$ztrnlnm("gtm_principal_editing")
	set term=$ztrnlnm("TERM")
	set terminfo=$ztrnlnm("TERMINFO")
	set stty=$ztrnlnm("STTY")
	set lbl=$piece(ZPOS,"+",1),rtn=$piece(ZPOS,"^",2)
	if $length(stty) use $p:width=80 do writestar("FORCING COLUMN LIMIT to 80")
	do writestar("REPEAT the following")
	write "( setenv TERM """,term,$char(34,59,32,92),!
	write:$length(stty) stty," ",$select(lbl="stty":15,1:80),$char(59,32,92),!
	write:$length(terminfo) "setenv TERMINFO """,terminfo,$char(34,59,32,92),!
	write:$length(editing) "setenv gtm_principal_editing """,editing,$char(34,59,32,92),!
	write:'$length(editing) "unsetenv gtm_principal_editing; \"
	write "env gtm_dist=",dist," gtmroutines=""",$zro,$char(34,32),dist,"/mumps -run ",lbl,"^",rtn," )",!,!
	quit
