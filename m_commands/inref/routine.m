;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2004, 2013 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; create routines (length 7 8 9 31 32) with multiple labels (length 7 8 9 31 32).
	; the routine names will be stored in routines(rlen), and the labels will be stored
	; in labels(rlen,llen)
	;
routine	; test zlink, zcompile, zedit, zprint
	new inited
	set inited=0
	do init
	if unix do
	. set objformat=".o"
	else  do
	. set objformat=".OBJ"
	do link
	do comp
	if unix do edit
	do prnt
	do testdo
	do testjob
	quit
init	;
	set inited=1
	set maxlen=31	; this is the final setting for longnames
	set tf3456789012345678901234567890f=0
	set tf3456789012345678901234567890t=1
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	do init^lotsvar
	set unix=$zv'["VMS"
	set rx=""
	set jj=$J(" ",9)
	set counter=0	; verification of how many labels were called
	do writefil	; write all files involved
	set separator="##################################################"
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
link	; test zlink
	write separator,!
	write "test zlink",!
	if 'inited do init
	for ri=7,8,9,31,32 do
	. set rout=routines(ri)
	. do ^examine($ZSEARCH(rout_objformat),"","object file should not exist at "_$ZPOSITION)
	. zlink rout
	. write "rout:",rout,!
	. if unix do
	.. do ^examine($ZPARSE($ZSEARCH(rout_objformat),"name"),rout,"object file should exist at "_$ZPOSITION)
	. else  do
	.. do ^examine($ZPARSE($ZSEARCH(rout_objformat),"name"),$$FUNC^%UCASE(rout),"object file should exist at "_$ZPOSITION)
	set rout=routines(10)
	write "rout:",rout,!
	do ^examine($ZSEARCH(rout_objformat),"","object file should not exist at "_$ZPOSITION)
	zlink:tf3456789012345678901234567890f rout
	do ^examine($ZSEARCH(rout_objformat),"","object file should not exist at "_$ZPOSITION)
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
comp	; test zcompile
	write separator,!
	write "test zcompile",!
	if 'inited do init
	for ri=10,11,20,30 do
	. if unix do
	..  set rout=routines(ri)_".m"
	. else  do
	..  set rout=routines(ri)
	. zcompile rout
	. write "rout:",rout,!
	if unix  set zcmd="ls *.o"
	else  set zcmd="directory/nodate *.obj"
	zsystem zcmd
	; move rout.m, and verify that ^rout is still accessible
	set compilefn="compilem.out"
	open compilefn:(newversion)
	use compilefn
	for ri=10,11,20,30 do
	. set rout=routines(ri)
	. if unix do
	.. set zcmd="mv "_rout_".m "_rout_".x"
	. else  do
	.. set zcmd="rename "_rout_".m "_rout_".x"
	. zsystem zcmd
	. for li=7,8,9,10,11,20,30,31 do
	.. set labname=labels(ri,li)
	.. set labref=labname_"^"_rout
	.. if args(ri,li) set labref=labref_"(1)"
	.. do @labref
	close compilefn
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
edit	; test zedit
	; we do not test ZEDIT in VMS, since it will be TPU.
	write separator,!
	write "test zedit",!
	if 'inited do init
	set routinename="rout"
	; the EDITOR should have been set to zed of this test
	for ri=7,8,9,31 do
	. set rout=routines(ri)_".m"
	. zedit @routinename
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prnt	; test zprint ranges
	; This command is tested in the ZBREAK test (in labtest.m) and zbreak test (zbtest.m)
	write separator,!
	write "test zprint ranges",!
	if 'inited do init
	new ref
	for ri=7,8,9,31 do
	. set rout=routines(ri)
	. for li=7,8,10,20,30,31 do
	.. set lab=labels(ri,li)
	.. set ref=lab_"^"_rout_":"_lab_"+5"
	.. write separator,!
	.. write "will ZPRINT @ref,ref=",ref,!
	.. zprint @ref
	.. set ref=lab_"+-2^"_rout_":"_lab
	.. write separator,!
	.. write "will ZPRINT @ref,ref=",ref,!
	.. zprint @ref
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testdo	; test do command with postconditional and indirection
	; and the created routines will test goto and zgoto
	write separator,!
	write "test command do, goto and zgoto",!
	if 'inited do init
	new checkpostconditionaltrue,checkpostconditionalfalse,a
	set checkpostconditionaltrue=1	; [XXX] remove the t at the beginning
	set checkpostconditionalfalse=0
	set a=1
	set testgoto=1
	 set rout=routines(8)
	 set rout(a)=routines(31)
	 write separator,!
	 write "Post Conditional for ",rout," is: ",checkpostconditionaltrue,!
	 set indirectgotolab=labels(20,31)_"^"_routines(20)
	 do ^@rout:checkpostconditionaltrue
	 write separator,!
	 write "Post Conditional for ",rout," is: ",checkpostconditionalfalse,!
	 do ^@rout:checkpostconditionalfalse
	 set indirectgotolab=labels(31,31)_"^"_routines(31)
	 write separator,!
	 write "Post Conditional for ",rout(a)," is: ",checkpostconditionaltrue,!
	 do ^@rout(a):checkpostconditionaltrue
	 write separator,!
	 write "Post Conditional for ",rout(a)," is: ",checkpostconditionalfalse,!
	 do ^@rout(a):checkpostconditionalfalse
	 ; ---------------------------------
	 write separator,!
	 kill indirectgotolab
	 set indirectzgotolab=labels(30,31)
	 write "(1) will try to zgoto to (label only):",indirectzgotolab,!
	 set indirectlab=labels(30,8),rout=routines(30)
	 do @indirectlab^@(rout)("test_parameter")
	 set indirectzgotolab=labels(31,11)_"^"_routines(31)
	 ; enable the following as soon as the issues with ZGOTO are resolved:
	 ; [XXX] TR???:
	 ; C9E11-002669 ZGOTO fails with indirect entry references
	 ;write "(2) will try to zgoto to (label^routine):",indirectzgotolab,!
	 ;set indirectlab=labels(31,30),rout(a)=routines(31)
	 ;do @indirectlab^@rout(a)("test_parameter")
	 ;----------------------------------
	 write separator,!
	 write "some simple do's...",!
	 new indirectgotolabtmp,indirectzgotolab,indirectgotolab
	 kill indirectzgotolab
	 kill testgoto
	 set indirectlab=labels(20,31),rout=routines(20)
	 do @indirectlab^@rout
	 set indirectlab=labels(31,31),rout=routines(31)
	 do @indirectlab^@rout(a)
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testgoto ; test goto and zgoto
	; performed along with the DO testing
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testjob	; test a label/routine of length 31 can be jobbed off
	write separator,!
	write "Test that a label/routine name of length 31 can be jobbed off",!
	if 'inited do init
	for ri=7,8,9,10,11,20,30,31 do
	. write "----------------------------------------",!
	. set rout=routines(ri)
	. set routname="^"_rout
	. for lab=labels(ri,30),labels(ri,31) do
	.. set lablen=$Length(lab)
	.. write "will job: Job:(ri#2) @routname, routname=",routname,!
	.. if unix Job:(ri#2) @routname
	.. else  set routvms="Job:(ri#2) "_routname_":(startup=""startup.com"":output="""_rout_"only.mjo"":error="""_rout_"only.mje"":log="""_rout_"only.mlog"")" xecute routvms
	.. set job1=$zjob
	.. if '(lablen#2) set entryref=lab_"^"_rout_"(""test_job"")"
	.. if (lablen#2) set entryref=lab_"^"_rout
	.. set jobcomu="Job "_entryref_":(output="""_lab_".mjo"":error="""_lab_".mje"")"
	.. set jobcomv="Job "_entryref_":(startup=""startup.com"":output="""_lab_".mjo"":error="""_lab_".mje"":log="""_lab_".mlog"")"
	.. if unix set str=jobcomu
	.. else  set str=jobcomv
	.. write "will execute: ",str,!
	.. xecute str
	.. set job2=$zjob
	.. ; wait for the both the jobs to complete
	.. for i=1:1 quit:$$^isprcalv(job1)=0  hang 1
	.. for i=1:1 quit:$$^isprcalv(job2)=0  hang 1
	write "checking errors from jobs...",!
	if unix do
	. set zcmd="grep ""YDB-E-"" *.mje"
	. zsystem zcmd
	else  do
	. if (""'=$zsearch("*.mje")) write "JOB-E-ERROR check *.mje files",!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writefil ;
	for ri=7,8,9,10,11,20,30,31,32 do onevar^lotsvar(ri,1) set rx=strnosub set routines(ri)=rx do writerout
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writerout ;
	; creates one routine
	set rxfn=rx_".m"
	set undl=$FIND(rx,"_")
	if undl set $EXTRACT(rx,undl-1,undl-1)="%" ; from now on, we want % instead of _
	set rl=$LENGTH(rx)
	open rxfn:(NEWVERSION)
	use rxfn
	write rx,$J(" ",maxlen+2-rl),"WRITE $TEXT(@$ZPOS),!",!
	write jj,"WRITE ""routine name is ",rl," characters"",!",!
	write jj,"WRITE ""In this routine, we will have labels with varying length upto ",maxlen," characters"",!",!
	write jj,"SET zpos=$ZPOSITION",!
	write jj,"WRITE ""$ZPOSITION:"",zpos,!",!
	write jj,"IF ($DATA(testgoto)=1)&($DATA(indirectgotolab)=1) do",!
	write jj,". WRITE ""will goto to "",indirectgotolab,!",!
	write jj,". SET indirectgotolabtmp=indirectgotolab",!
	write jj,". KILL indirectgotolab",!
	write jj,". GOTO @indirectgotolabtmp",!
	write jj,"WRITE ""----------------------------------------------------------------------"",!",!
	write jj,"SET ^DONE(""",rx,""",""",rx,""")=1",!
	write jj,"QUIT",!
	; write different types of labels in each routine
	set labname=""
	for ll=7,8,9,10,11,20,30,31  do
	. do onevar^lotsvar(ll,1)	; labels of the form xxx (xxx len: [1,maxlen-1])
	. set labname=strnosub
	. if '((""=strnosub)&("driver"=rx)) do writelab
	; set a label with length 32 characters
	set ll=32
	set labname="z"_labname
	;set labels(ri,ll)=labname
	do writelab
	close rxfn
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writelab ;
	; depending on the value of act, will write all output related to the
	; label/routine defined by labname/rx.
	; add parameter pa for each label
	;writes one label in the current routine
	use rxfn
	set labels(ri,ll)=labname
	set args(ri,ll)=1
	set lablen=$LENGTH(labname)
	if '(lablen#2) do
	. set args(ri,ll)=1
	. write labname,"(pa)",$J(" ",maxlen+2-lablen),"WRITE $TEXT(@$ZPOS),!",!
	. write jj,"WRITE ""The parameter passed is: "",pa,!",!
	else  do
	. set args(ri,ll)=0
	. write labname,$J(" ",maxlen+2-lablen),"WRITE $TEXT(@$ZPOS),!",!
	write jj,"WRITE ""labelname is supposed to be ",lablen," characters"",!",!
	write jj,"WRITE ""routinename is supposed to be ",rl," characters"",!",!
	write jj,"SET zpos=$ZPOSITION",!
	write jj,"WRITE ""$ZPOSITION:"",zpos,!",!
	write jj,"SET plussign=$FIND(zpos,""+"")-1",!
	write jj,"SET uparrow=$FIND(zpos,""^"",plussign)-1",!
	write jj,"SET labname=$EXTRACT(zpos,1,plussign-1)",!
	write jj,"SET routname=$EXTRACT(zpos,uparrow+1,$LENGTH(zpos))",!
	write jj,"WRITE ""counter points to ",counter+1," calls"",!",!
	write jj,"IF ($DATA(testgoto)=1)&($DATA(indirectzgotolab)=1) do",!
	write jj,". write ""will zgoto to "",indirectzgotolab,!",!
	write jj,". set indirectzgotolabtmp=indirectzgotolab",!
	write jj,". kill indirectzgotolab",!
	write jj,". zgoto $zlevel:@indirectzgotolabtmp",!
	set counter=counter+1
	write jj,"WRITE ""----------------------------------------------------------------------"",!",!
	write jj,"SET ^DONE(""",labname,""",""",rx,""")=1",!
	write jj,"QUIT",!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wrtcsh	;
	; writes the csh driver driver.csh
	; [XXX] VMS driver driver.com needs to be written as well.
	; [XXX] It is going to be very similar to the driver.csh
	;use drvcfn
	write "mumps -direct << EOF",!
	write "SET ^LABELREF=""",labelref,"""",!
	write "EOF",!
	write "mumps -run ",labname,"^",rx,!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
append(f1,f2)	; append f2 to f1
	open f2:(READONLY:REWIND)
	for i=1:1 use f2 read line quit:$ZEOF  do
	. use f1
	. write line,!
	quit
