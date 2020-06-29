;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; testing the ztrigger function
	; not to be confused with $ztrigger!
	;
	; Installation
	; - ZTR installs like a Kill
	; - - do with delim/piece
	; - need to test trigger symmetry/matching with ZT
	;
	; Invocation limitations
	; - 31 subscripts
	; - max key size
	; - matching tests (similar to what we already have in testxecute)
	; - matching ZTRs with GVN > 31 chars long
	;
	; Inside the trigger
	; - NULL ISV
	; - does setting $ztvalue bring the node into existence?
	; - - $ztvalue, $ztoldvalue, $ztdata?, $ztupdate
	; - Non-null ISVs
	; - - $ztriggerop, $ztslate/$ztwormhole (optional)
	; - - $ztcode, $reference, $test, $ztlevel, $tlevel, $zlevel
	; - Optional LVNs from trigger spec
	; - Exceed max trigger nesting
	; - trollback/tcommit/trestart inside a ztrigger'ed trigger TODO
ztriggercmd
	set $etrap="use $p write $zstatus,! set $ecode="""""
	do install^ztriggercmd
	do match^ztriggercmd
	do exec^ztriggercmd
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
exec
	do ^echoline
	write "Test non-existent triggers",!
	ztrigger ^idontexist
	ztrigger ^idontexistwithsubs(1,"2")

	do ^echoline
	write "Test non-existent triggers with existing nodes",!
	set ^idontexist=1
	set ^idontexistwithsubs(1,"2")=2
	ztrigger ^idontexist
	ztrigger ^idontexistwithsubs(1,"2")

	do ^echoline
	write "Test existent triggers with existing nodes",!
	set ^tr("exist")="Jonny|5|is|alive|!"
	ztrigger ^tr("exist")

	do ^echoline
	write "Make sure that a trigger does not respond to K/ZK, just ZTR",!
	kill ^zt("exec")
	zkill ^zt("exec")
	ztrigger ^zt("exec")

	do ^echoline
	write "Inspect ISVs while you're at it",!
	ztrigger ^zt("inspect")

	do ^echoline
	write "Test local variables inside the trigger",!
	ztrigger ^zt("one","two","three","four","five","six")
	ztrigger ^zt("one","two","three","four","five","six",7)
	ztrigger ^zt("one","two","three","four","five","six",7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)

	do nest
	do maxtrignest
	do maxtrignest2
	quit

nest
	if '$data(^install) do installbyitem
	do ^echoline
	kill ^fired
	write "Nest ztrigger within a trigger",!
	ztrigger ^ztriggerloop(1)
	zwr ^fired kill ^fired
	ztrigger ^ztriggerloop(127)
	zwr ^fired kill ^fired
	write "repeat, but alternate between ztrigger and updating the GVN",!
	ztrigger ^ztriggerloop2(2)
	zwr ^fired kill ^fired,^ztriggerloop2
	ztrigger ^ztriggerloop2(127)
	zwr ^fired kill ^fired,^ztriggerloop2
	quit

maxtrignest
	if '$data(^install) do installbyitem
	do ^echoline
	write "$gtm_exe/mumps -run maxtrignest^ztriggercmd",!
	write "Test for MAXTRIGNEST with ztrigger",!
	ztrigger ^ztriggerloop(128)
	zwr ^fired kill ^fired
	write $piece($ztslate,"|",1),!
	write $piece($ztslate,"|",$length($ztslate,"|")),!
	write !,"Repeat, but alternate between ztrigger and updating the GVN",!
	ztrigger ^ztriggerloop2(128)
	zwr ^fired kill ^fired,^ztriggerloop2
	write $piece($ztslate,"|",1),!
	write $piece($ztslate,"|",$length($ztslate,"|")),!
	quit

maxtrignest2
	if '$data(^install) do installbyitem
	do ^echoline
	write "$gtm_exe/mumps -run maxtrignest2^ztriggercmd",!
	write "Test for MAXTRIGNEST with ztrigger",!
	ztrigger ^ztriggerloop(128)
	zwr ^fired kill ^fired
	write $piece($ztslate,"|",1),!
	write $piece($ztslate,"|",$length($ztslate,"|")),!
	write !,"Repeat, but alternate between ztrigger and updating the GVN",!
	ztrigger ^ztriggerloop2(128)
	write $piece($ztslate,"|",1),!
	write $piece($ztslate,"|",$length($ztslate,"|")),!
	zwr ^fired kill ^fired,^ztriggerloop2
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
match
	do match31subs
	do match31plusgvn
	do matchoflow
	quit

match31subs
	if '$data(^install) do installbyitem
	new i,subs
	kill ^fired
	do ^echoline
	write "$gtm_exe/mumps -run match31subs^ztriggercmd",!
	write "Match 31 subs",!
	for i=1:1:31 set $piece(subs,",",i)=i
	xecute "ztrigger ^zt("_subs_")"
	zwr ^fired kill ^fired

	do ^echoline
	for i=1:1:31 set $piece(subs,",",i)=i
	write "Match 31+ subs",!
	xecute "ztrigger ^zt("_subs_",32)"
	zwr ^fired kill ^fired
	quit

match31plusgvn
	if '$data(^install) do installbyitem
	do ^echoline
	write "$gtm_exe/mumps -run match31plusgvn^ztriggercmd",!
	write "Match GVNs longer than 31 chars",!

	write "Expect three triggers to fire - superlong[1-3]",!
	ztrigger ^ztwhoseislongerthan31subscripts
	zwr ^fired kill ^fired

	write "Again, expect three triggers to fire - superlong[1-3]",!
	ztrigger ^ztwhoseislongerthan31subscripts3
	zwr ^fired kill ^fired

	write "Expect three triggers to fire, with subs - superlong1[1-3]",!
	ztrigger ^ztwhoseislongerthan31subscripts(1)
	zwr ^fired kill ^fired

	write "Again, expect three triggers to fire, with subs - superlong1[1-3]",!
	ztrigger ^ztwhoseislongerthan31subscripts3(1)
	zwr ^fired kill ^fired

	write "Expect one trigger to fire for the next two ztrigger cmds",!
	ztrigger ^ztwhoseislongerthan31subscripts3(3)
	zwr ^fired kill ^fired
	ztrigger ^ztwhoseislongerthan31subscripts2(2)
	zwr ^fired kill ^fired
	quit

matchoflow
	new $ztrap
	if '$data(^install) do installbyitem
	kill ^stopoflow
	set oflow="oflowkey"
	do ^echoline
	write "$gtm_exe/mumps -run matchoflow^ztriggercmd",!
	set $ztrap="set ^stopoflow=1 goto ^incrtrap"
	for i=100:1:255 quit:$data(^stopoflow)  do
	.	set aaa=$translate($justify("",i-$length(oflow))," ","a")
	.	set ^zt(oflow,aaa)=i
	set $extract(aaa,$length(aaa),$length(aaa))=""
	set $ztrap=""
	write "Over flow the subscripts in the ztrigger command",!
	ztrigger ^zt(oflow,aaa)
	ztrigger ^zt(oflow,"b"_aaa)
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
install
	; create the trigger files
	do text^dollarztrigger("ztriggercmdtfile^ztriggercmd","ztriggercmd.trg")
	do text^dollarztrigger("ztriggercmdtfilefail^ztriggercmd","ztriggercmdfail.trg")
installvalid
	do ^echoline
	write !,"Test all the valid uses of ZTRrigger in a trigger specification",!
	do file^dollarztrigger("ztriggercmd.trg",1)
	do check^dollarztrigger("ztriggercmd.trg.trigout")
	write !
	do ^echoline
installfailing
	write !,"Test all the invalid uses of ZTRrigger in a trigger specification",!
	do file^dollarztrigger("ztriggercmdfail.trg",0)
	do check^dollarztrigger("ztriggercmdfail.trg.trigout")
	write !
	do ^echoline
installbyitem
	write !,"Reload the valid uses of ZTRrigger in a trigger specification",!
	do item^dollarztrigger("ztriggercmdtfile^ztriggercmd","ztriggercmd.trg.trigout2")
	do check^dollarztrigger("ztriggercmd.trg.trigout2")
	write !
	set ^install=1
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; use for nesting ztrigger and MAXTRIGNEST
ztriggerloop(lvn)
	do triginfo^ztriggercmd(3)
	if $ztlevel'<lvn quit
	if $ztlevel#2=1 set ^ztriggerloop2(lvn)=lvn
	if $ztlevel#2=0 ztrigger ^ztriggerloop2(lvn)
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
triginfo(level)
	new stack,info,x,name,cnt
	if '$data(level) set level=2
	zshow "s":stack
	set name=stack("S",level)
	do:$length(name,"#")>1
	.	set $piece(name,"#",$length(name,"#"))=""  ; nullify region disambigurator
	set cnt=$increment(^fired(name))
	set $piece(info,"_",$increment(x))=$ztlevel
	set $piece(info,"_",$increment(x))=$ztriggerop
	set $piece(info,"_",$increment(x))=name
	set $piece(info,"_",$increment(x))=cnt
	set $piece(info,"_",$increment(x))=$reference
	set $piece(info,"_",$increment(x))=$ztvalue
	set $piece(info,"_",$increment(x))=$trestart
	set x=$ztslate  set $piece(x,"|",$ztlevel)=info set $ztslate=x
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ztriggercmdtfilefail
	;;Failing INSTALLATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;+^zt("ZTR fail") -command=ZTR 	 -xecute="do l^mrtn()" -piece=1 -delim="|" -name=FAIL1
	;+^zt("ZTR fail") -command=ZTR 	 -xecute="do l^mrtn()" -piece=1            -name=FAIL2
	quit


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ztriggercmdtfile
	;;INSTALLATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;;test ZTK vs ZTR
	;+^zt("ZTR","ZTK")	-command=ZTK	-xecute="do triginfo^ztriggercmd()" -name=ztrztk
	;+^zt("ZTR","ZTK")	-command=ZTR	-xecute="do triginfo^ztriggercmd()" -name=ztrztk
	;
	;;test K,ZK vs ZTR
	;+^zt("ZTR";"ZK";"K")	-command=ZTR,ZK,K -xecute="do triginfo^ztriggercmd()" -name=ztrkzk
	;+^zt("ZTR";"ZK";"K")	-command=ZK,ZTR,K -xecute="do triginfo^ztriggercmd()" -name=ztrkzkrenamed
	;
	;;test matching ZTR against full name
	;+^zt("ZTR";"ZTRIGGER")	-command=ZTR,ZTKill   -xecute="do triginfo^ztriggercmd()" -name=ztriggerZTKill
	;+^zt("ZTR";"ZTRIGGER")	-command=ZTK,ZTRigger -xecute="do triginfo^ztriggercmd()" -name=ztriggerZTK
	;+^zt("ZTR";"ZTRIGGER")	-command=ZTK,ZTR      -xecute="do triginfo^ztriggercmd()" -name=ztriggerZTR
	;+^zt("ZTR";"ZTRIGGER")	-command=ZTK,ZTRigger -xecute="do triginfo^ztriggercmd()" -name=ztriggerztr
	;
	;;test install with SET
	;+^zt("ZTR";"SET") 	-command=Set 	 -xecute="do triginfo^ztriggercmd()" -piece=1 -delim="|"
	;+^zt("ZTR";"SET") 	-command=Ztr 	 -xecute="do triginfo^ztriggercmd()"
	;
	;;MATCHING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;;test 31 subs AND no ZT
	;;write "+^zt(" for i=1:1:31 write ":" write $select(i=31:")",1:",")
	;+^zt(:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) -command=S,K -xecute="do triginfo^ztriggercmd() set x=1" -name=nofiresub31
	;+^zt(:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) -command=S,K,ZTR -xecute="do triginfo^ztriggercmd() set x=2" -name=firesub31
	;
	;;exceed max key size
	;+^zt("oflowkey",:) -command=ZTR -xecute="do triginfo^ztriggercmd()" -name=oflowkey
	;
	;;triggers whose GVNs are > 31 chars long
	;+^ztwhoseislongerthan31subscripts1 -command=ZTR -xecute="do triginfo^ztriggercmd() set x=1" -name=superlong1
	;+^ztwhoseislongerthan31subscripts2 -command=ZTR -xecute="do triginfo^ztriggercmd() set x=2" -name=superlong2
	;+^ztwhoseislongerthan31subscripts3 -command=ZTR -xecute="do triginfo^ztriggercmd() set x=3" -name=superlong3
	;
	;;triggers whose GVNs are > 31 chars long, where subscripts match and differ
	;+^ztwhoseislongerthan31subscripts1(1) -command=ZTR -xecute="do triginfo^ztriggercmd() set x=11" -name=superlong11
	;+^ztwhoseislongerthan31subscripts2(1) -command=ZTR -xecute="do triginfo^ztriggercmd() set x=21" -name=superlong21
	;+^ztwhoseislongerthan31subscripts3(1) -command=ZTR -xecute="do triginfo^ztriggercmd() set x=31" -name=superlong31
	;+^ztwhoseislongerthan31subscripts2(2) -command=ZTR -xecute="do triginfo^ztriggercmd() set x=22" -name=superlong22
	;+^ztwhoseislongerthan31subscripts3(3) -command=ZTR -xecute="do triginfo^ztriggercmd() set x=33" -name=superlong33
	;
	;
	;;EXECUTION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;+^zt("exec")    -command=S,K,ZK,ZTR     -xecute="do ^twork"	             -name=twork
	;+^zt("exec")    -command=S,K,ZK,ZTR     -xecute="do triginfo^ztriggercmd()" -name=exec
	;+^zt("inspect") -command=ZTR            -xecute="do ^inspectISV"            -name=inspectISV
	;
	;;testing LVNs in ztrigger'ed M routines
	;;write "+^zt(" for i=1:1:31 write "lvn"_i_"=:" write $select(i=31:")",1:",")
	;+^zt(lvn1=:,lvn2=:,lvn3=:,lvn4=:,lvn5=:,lvn6=:,lvn7=:,lvn8=:,lvn9=:,lvn10=:,lvn11=:,lvn12=:,lvn13=:,lvn14=:,lvn15=:,lvn16=:,lvn17=:,lvn18=:,lvn19=:,lvn20=:,lvn21=:,lvn22=:,lvn23=:,lvn24=:,lvn25=:,lvn26=:,lvn27=:,lvn28=:,lvn29=:,lvn30=:,lvn31=:) -command=ZTR -xecute="do ^lvncheck(31) do triginfo^ztriggercmd()" -name=lvntest
	;+^zt(lvn1=:,lvn2=:,lvn3=:,lvn4=:,lvn5=:,lvn6=:) -command=ZTR -xecute="do triginfo^ztriggercmd() do ^lvncheck(6)" -name=shortlvntest
	;
	;;what happens when the ztrigger node exists
	;+^tr("exist") -command=ZTR -xecute="do ^twork"	 -name=tworkexist
	;
	;;testing for MAXTRIGNEST
	;+^ztriggerloop(lvn=1:129) -command=ZTR -xecute="do triginfo^ztriggercmd() if $ztlevel<lvn ztrigger ^ztriggerloop(lvn)" -name=ztriggerloop
	;+^ztriggerloop2(lvn=1:129) -command=S,ZTR -xecute="do ztriggerloop^ztriggercmd(lvn)" -name=ztriggerloop2
	;
	;;what happens when ZTR and DELIM is specified
	;+^zt("ZTR fail") -command=ZTR 	 -xecute="do l^mrtn()" -delim="|"          -name=ZTRDELIM
	quit

setup
	; create the GDE file
	do text^dollarztrigger("gdefile^ztriggercmd","ztriggercmd.gde")
	write "setenv test_specific_gde ",$ztrnlnm("PWD"),"/ztriggercmd.gde",!
	write "setenv gtm_trigger_etrap 'use $p set $ecode="""" write $zs,\!'",!
	write "unsetenv gtm_gvdupsetnoop",!
	quit

gdefile
	;change -segment DEFAULT -file_name=mumps.dat
	;change -segment DEFAULT -block_size=2048
	;change -region DEFAULT -record_size=1024
	;change -region DEFAULT -key_size=255
	quit
