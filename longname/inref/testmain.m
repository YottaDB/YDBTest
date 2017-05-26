;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2004, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testmain;
	new $ZT
	set $ZT="set $ZT="""" g ERROR^testmain"
	SET $ZTRAP="GOTO errcont^errcont"
	set unix=$zversion'["VMS"
	set:unix $zroutines="."
	;set main1="testmain" ;	Intentionally not created here
	set main2="testmain"
	set main3="testmain"
	do enable("test1")
	do ^currentcalleeroutineinstpmovetest
	set fnarr("alpha")=alpha
	set fnarr("wspace")=wspace
	do calllabeltoteststpmove^testmain
	set fnarr("test1","lb2var")=lb2var
	set fnarr("test1","var2")=var2
	;
	do enable("test2")
	do labelcalledbystpmovetest1^currentcalleeroutineinstpmovetest
	set fnarr("digits")=digits
	set fnarr("pi")=pi
	do calllabeltoteststpmove^testmain
	set fnarr("test2",1,"lb2var")=lb2var
	set fnarr("test2",1,"var22")=var22
	;
	for cnt=1:1:8 do
	. set index=cnt
	. do enable("test1")
	. do labelcalledbystpmovetest1^currentcalleeroutineinstpmovetest
	. set fnarr("fun1",cnt)=$$functioncalledbystpmovetest1^currentcalleeroutineinstpmovetest(.index)
	. set indarr("fun1",cnt)=index
	. ;
	. set index=cnt
	. do enable("test2")
	. do labelcalledbystpmovetest1^currentcalleeroutineinstpmovetest
	. set fnarr("fun2",cnt)=$$functioncalledbystpmovetest2^currentcalleeroutineinstpmovetest(index)
	. set indarr("fun2",cnt)=index
	. ;
	do:unix copy zlink "testmain"
	w "Now ZWR of all locals",!
	zwr
	quit
enable(fn)
	k zstr
	if unix  do
	. zsystem "\rm -f currentcalleeroutineinstpmovetest.o"
	. set cp="\cp -f "
	else  do
	. zsystem "delete /nolog currentcalleeroutineinstpmovetest.obj;*"
	. set cp="copy /nolog "
	set zstr="zsystem """_cp_fn_".m currentcalleeroutineinstpmovetest.m"""
	x zstr
	zlink "currentcalleeroutineinstpmovetest"
	quit
calllabeltoteststpmove;
	do labelcalledbystpmovetest2^currentcalleeroutineinstpmovetest
	quit
ERROR
	write "In ZTRAP",$zstatus,!
	zshow "*"
	halt

copy
	new i,file,line
	set file="testmain.o"
	zsystem "cp testmain.o testmain.o.bak"
	open file
	close file:delete
	set file="testmain.m"
	open file:newversion
	use file
	for i=0:1 set line=$text(testmain+i^testmain) quit:("END"=line)  write line,!
	close file
	quit

END
	quit 123
