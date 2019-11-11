;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
randomtriggers ;
	new str,i,numtrigs,optpicked
	do init
	set numtrigs=(2**$random(11))
	for i=1:1:numtrigs do
	. ; +^a -commands=S,K,ZK -pieces=1:20 -delim=";" -xecute="do ^twork" -options=noi
	. set str=""
	. set str=str_$$pickoper		; +
	. set str=str_$$pickgbl			; ^a
	. set str=str_" -commands="_$$pickcmd	; -commands=S,K,ZK -pieces=1:20 -delim=";"
	. set str=str_" -xecute="_$$pickxecute	; -xecute="do ^twork"
	. set str=str_$$pickoptions		; -options=noi
	. write str,!
	quit

init	;
	new i,j,jmax
	set jmax=$random(10)
	for i=0:1:jmax set oper(i)="+"
	set oper($incr(i))="-"
	set choices("oper")=i+1
	;
	; since we have a 4 region database, choose globals that map to different and same regions
	; select upto a max of 6 globals ^a,^b,^c,^d,^e,^f which map respectively to AREG,BREG,CREG,DREG,DEFAULT,DEFAULT
	set jmax=$random(6)
	for i=0:1:jmax set gbl(i)="^"_$c(97+i)
	set choices("gbl")=i+1
	;
	set i=-1
	set cmd($incr(i))="S"
	set cmd($incr(i))="K"
	set cmd($incr(i))="ZK"
	set cmd($incr(i))="ZTR"
	set choices("cmd")=i+1
	;
	set i=-1
	set delim($incr(i))=" -delim="";"""
	set delim($incr(i))=" -delim="":"""
	set choices("delim")=i+1
	;
	set i=-1
	set piece($incr(i))=""
	set piece($incr(i))=" -pieces=1:20"
	set piece($incr(i))=" -pieces=2:20"
	set choices("piece")=i+1
	;
	set i=-1
	set xecute($incr(i))="do ^twork(66)"
	set xecute($incr(i))="do ^twork(121266)"
	set xecute($incr(i))="do ^twork(121269)"
	set xecute($incr(i))="do ^twork(34303)"
	set xecute($incr(i))="do ^twork(34306)"
	set xecute($incr(i))="do ^twork(403111)"
	set xecute($incr(i))="do ^twork(403161)"
	set choices("xecute")=i+1
	;
	set i=-1
	set options($incr(i))=""
	set options($incr(i))=" -options=C"
	set options($incr(i))=" -options=NOC"
	set options($incr(i))=" -options=I"
	set options($incr(i))=" -options=I,C"
	set options($incr(i))=" -options=I,NOC"
	set options($incr(i))=" -options=NOI"
	set options($incr(i))=" -options=NOI,C"
	set options($incr(i))=" -options=NOI,NOC"
	set choices("options")=i+1
	;
	quit

pickoper();
	quit oper($random(choices("oper")))

pickgbl()	;
	quit gbl($random(choices("gbl")))

pickcmd()	;
	new i,n,str,str1
	set n=choices("cmd"),str="",str1=""
	for  do  quit:str'=""
	. for i=0:1:n-1  do
	. . if $random(2) do
	. . . if cmd(i)="S" set str1=$$pickpiecedelim
	. . . if str="" set str=str_cmd(i)
	. . . else      set str=str_","_cmd(i)
	if str1'="" quit str_str1
	quit str

pickpiecedelim();
	new str1,str2,str
	set str1=piece($random(choices("piece")))
	quit:str1="" str1
	set str2=delim($random(choices("delim")))
	quit str1_str2

pickxecute()	;
	quit """"_xecute($random(choices("xecute")))_""""

pickoptions()	;
	if ('$data(optpicked)) set optpicked=$random(choices("options"))
	quit options(optpicked)

gentrigload	;
	; Generate what MUPIP TRIGGER should have output
	;
	new trigin,trigout,selectout,i,j,killindex,setindex,hasht,killmod,setmod,killexists,setexists,trigs,trigfile
	new tmp,cmds,gvn,line,delim,pieces,options,setspecified,killspecified,common,uniq1,uniq2,cycle,linein
	set trigin=$piece($zcmdline," ",1)
	set trigout=$piece($zcmdline," ",2)
	set selectout=$piece($zcmdline," ",3)
	;
	;;;;;;;;;; READ trigger input file ;;;;;;;;;;;;;;;;;;
	;
	;   ---------------------------------------
	;   trigin has lines of the following form
	;   ---------------------------------------
	;   +^f -commands=S,K,ZK -pieces=2:20 -delim=";" -xecute="do ^twork(34306)" -options=I,NOC
	;   +^a -commands=S,ZTR -pieces=1:20 -delim=":" -xecute="do ^twork(403111)" -options=NOI
	;   +^c -commands=S,ZK -xecute="do ^twork(66)" -options=NOI
	;   -^f -commands=K -xecute="do ^twork(121266)" -options=NOI,NOC
	;   ---------------------------------------
	;
	;;;;;;;;;; GENERATE trigger output file ;;;;;;;;;;;;;;;;;;
	;
	;   ----------------------------------------
	;   trigout has lines of the following form
	;   ----------------------------------------
	;   File xy.trg, Line 1: Added Non-SET trigger on ^e named e#1
	;   File xy.trg, Line 2: Added SET trigger on ^d named d#1
	;   File xy.trg, Line 8: Added SET and/or Non-SET trigger on ^a named a#1
	;   File xy.trg, Line 9: SET trigger on ^c does not exist - no action taken
	;   File xy.trg, Line 19: Modified SET and/or Non-SET trigger on ^d named d#2
	;   File xy.trg, Line 284: Deleted SET and/or Non-SET trigger on ^f named f#3
	;   .
	;   .
	;   =========================================
	;   42 triggers added
	;   1 triggers deleted
	;   34 triggers modified
	;   75 trigger file entries did update database trigger content
	;   25 trigger file entries did not update database trigger content
	;   =========================================
	;
	set trigs("added")=0,trigs("deleted")=0,trigs("modified")=0
	set trigfile("upddb")=0,trigfile("noupddb")=0
	do readfile(trigin,.linein)
	set numin=$order(linein(""),-1)
	open trigout:(newversion)
	use trigout
	for i=1:1:numin do
	. set pnum=0
	. set line=linein(i)
	. set gvn=$piece(line," ",$incr(pnum)),add=($extract(gvn,1)="+"),gvn=$extract(gvn,3,99)
	. kill cmds set cmds=$piece(line," ",$incr(pnum)),cmds=$piece(cmds,"-commands=",2)
	. for j=1:1:$length(cmds,",") set cmds($piece(cmds,",",j))=""
	. ; check if next piece is "-pieces=". If so consume this and the following "-delim=".
	. if ("-pieces"=$piece($piece(line," ",pnum+1),"=",1)) do
	. . ; get pieces and delim fields too
	. . set pieces=$piece(line," ",$incr(pnum))
	. . set delim=$piece(line," ",$incr(pnum))
	. else  set pieces="",delim=""
	. set xecute=$piece(line," ",$incr(pnum),$incr(pnum))
	. kill options set options=$piece(line," ",$incr(pnum)),options=$piece(options,"-options=",2)
	. if options'="" for j=1:1:$length(options,",") set options($piece(options,",",j))=""
	. ;
	. zkill cmds,options
	. set setspecified=$data(cmds("S"))  kill cmds("S")
	. set killspecified=$data(cmds)
	. set setmod=0,killmod=0
	. if (add) do
	. . ; trigger addition
	. . ; one or more of cmd=S,K,ZK,ZTK,ZTR was specified to be added
	. . if $data(hasht(gvn,xecute)) do
	. . . ; trigger already exists (KILL and/or SET). merge with it and create new triggers if needed.
	. . . set killindex=+$order(hasht(gvn,xecute,"")),killexists=1
	. . . if setspecified do
	. . . . ; check if SET trigger is same or not
	. . . . set setindex=+$get(hasht(gvn,xecute,delim,pieces)) set setexists=(0'=setindex)
	. . . . if 'setexists if ('$data(hasht(gvn,xecute,killindex,"delim"))) set setindex=killindex
	. . . . if (0=setindex) set setindex=$incr(hasht(gvn,"#SEQNUM")) if $incr(hasht(gvn,"#TNCOUNT"))
	. . . . if (0=setexists) set hasht(gvn,xecute,delim,pieces)=setindex
	. . . . kill tmp merge tmp=hasht(gvn,xecute,killindex,"cmds")
	. . . . do computediff(.tmp,.cmds,.common,.uniq1,.uniq2)
	. . . . set killmod=(0'=$data(uniq2))
	. . . . if (0=killmod)&(setindex=killindex) do
	. . . . . kill tmp merge tmp=hasht(gvn,xecute,killindex,"options")
	. . . . . do computediff(.tmp,.options,.common,.uniq1,.uniq2)
	. . . . . set killmod=(0'=$data(uniq2))!(0'=$data(uniq1))
	. . . . set:(killindex=setindex) setmod=killmod
	. . . . set:(0=setmod) setmod=('setexists)
	. . . . merge hasht(gvn,xecute,killindex,"cmds")=cmds
	. . . . if (setexists&(0=setmod)) do
	. . . . . kill tmp merge tmp=hasht(gvn,xecute,setindex,"options")
	. . . . . do computediff(.tmp,.options,.common,.uniq1,.uniq2)
	. . . . . set setmod=(0'=$data(uniq2))!(0'=$data(uniq1))
	. . . . kill hasht(gvn,xecute,setindex,"options")
	. . . . merge hasht(gvn,xecute,setindex,"options")=options
	. . . . set hasht(gvn,xecute,setindex,"cmds","S")=""
	. . . . set hasht(gvn,xecute,setindex,"delim")=delim
	. . . . set hasht(gvn,xecute,setindex,"pieces")=pieces
	. . . . if (killindex'=setindex) do
	. . . . . ; SET and KILL triggers are different
	. . . . . if (killmod) do
	. . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . write "Modified Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,!  if $incr(trigs("modified"))
	. . . . . else  if (killspecified) do
	. . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . write "Non-SET trigger on ^",gvn," already present in trigger named ",gvn,"#",killindex," - no action taken",!
	. . . . . write "File ",trigin,", Line ",i,": "
	. . . . . if ('setexists)   write "Added SET trigger on ^",gvn," named ",gvn,"#",setindex,!  if $incr(trigs("added"))
	. . . . . else  if (setmod) write "Modified SET trigger on ^",gvn," named ",gvn,"#",setindex,!  if $incr(trigs("modified"))
	. . . . . else  write "SET trigger on ^",gvn," already present in trigger named ",gvn,"#",setindex," - no action taken",!
	. . . . else  do
	. . . . . ; SET and KILL triggers are identical
	. . . . . write "File ",trigin,", Line ",i,": "
	. . . . . if ('killspecified) do
	. . . . . . if setmod write "Modified SET trigger on ^",gvn," named ",gvn,"#",setindex,!  if $incr(trigs("modified"))
	. . . . . . else  write "SET trigger on ^",gvn," already present in trigger named ",gvn,"#",setindex," - no action taken",!
	. . . . . else  do
	. . . . . . new str
	. . . . . . set str=$select((setspecified&killspecified):"SET and/or Non-SET",setspecified:"SET",1:"Non-SET")
	. . . . . . if (setmod!killmod) do
	. . . . . . . write "Modified ",str," trigger on ^",gvn," named ",gvn,"#",setindex,!
	. . . . . . . if $incr(trigs("modified"))
	. . . . . . else  write str," trigger on ^",gvn," already present in trigger named ",gvn,"#",setindex," - no action taken",!
	. . . else  do
	. . . . ; only need to touch KILL trigger
	. . . . kill tmp merge tmp=hasht(gvn,xecute,killindex,"cmds")
	. . . . do computediff(.tmp,.cmds,.common,.uniq1,.uniq2)
	. . . . set killmod=(0'=$data(uniq2))
	. . . . if (0=killmod) do
	. . . . . kill tmp merge tmp=hasht(gvn,xecute,killindex,"options")
	. . . . . do computediff(.tmp,.options,.common,.uniq1,.uniq2)
	. . . . . set killmod=(0'=$data(uniq2))!(0'=$data(uniq1))
	. . . . kill hasht(gvn,xecute,killindex,"options")
	. . . . merge hasht(gvn,xecute,killindex,"options")=options
	. . . . merge hasht(gvn,xecute,killindex,"cmds")=cmds
	. . . . write "File ",trigin,", Line ",i,": "
	. . . . if (killmod) write "Modified Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,!  if $incr(trigs("modified"))
	. . . . else  write "Non-SET trigger on ^",gvn," already present in trigger named ",gvn,"#",killindex," - no action taken",!
	. . else  do
	. . . ; trigger does not exist (KILL and/or SET). create one.
	. . . if $incr(hasht(gvn,"#TNCOUNT"))
	. . . set killindex=$incr(hasht(gvn,"#SEQNUM")),setindex=killindex
	. . . set hasht(gvn,"#SEQNUM")=killindex	; mirrors ^#t("#TNAME",<gvn>,"#SEQNUM")
	. . . set hasht(gvn,"#TNCOUNT")=killindex	; mirrors ^#t("#TNAME",<gvn>,"#TNCOUNT")
	. . . merge hasht(gvn,xecute,killindex,"options")=options
	. . . merge hasht(gvn,xecute,killindex,"cmds")=cmds
	. . . if setspecified set hasht(gvn,xecute,killindex,"cmds","S")=""
	. . . write "File ",trigin,", Line ",i,": "
	. . . if setspecified do
	. . . . set hasht(gvn,xecute,delim,pieces)=setindex
	. . . . set hasht(gvn,xecute,killindex,"delim")=delim
	. . . . set hasht(gvn,xecute,killindex,"pieces")=pieces
	. . . . if (killspecified) write "Added SET and/or Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,! do
	. . . . . set setmod=1,killmod=1
	. . . . else               write "Added SET trigger on ^",gvn," named ",gvn,"#",killindex,! set setmod=1
	. . . else  do
	. . . . write "Added Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,! set killmod=1
	. . . if $incr(trigs("added"))
	. else  do
	. . ; trigger deletion
	. . if $data(hasht(gvn,xecute)) do
	. . . ; trigger already exists (KILL and/or SET). delete as appropriate.
	. . . set killindex=+$order(hasht(gvn,xecute,"")),killexists=1
	. . . if setspecified do
	. . . . ; check if SET trigger is same or not
	. . . . set setindex=+$get(hasht(gvn,xecute,delim,pieces)) set setexists=(0'=setindex)
	. . . . if 'setexists if ('$data(hasht(gvn,xecute,killindex,"delim"))) set setindex=killindex
	. . . . if (killindex'=setindex) do
	. . . . . ; SET and KILL triggers are different
	. . . . . if ('setexists) do
	. . . . . . ; only need to touch KILL trigger
	. . . . . . kill tmp merge tmp=hasht(gvn,xecute,killindex,"cmds")
	. . . . . . do computediff(.tmp,.cmds,.common,.uniq1,.uniq2)
	. . . . . . set killmod=(0'=$data(common))
	. . . . . . ; options are ignored for a delete
	. . . . . . if (killmod) do
	. . . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . . new s set s="" for  set s=$order(common(s)) quit:s=""  kill hasht(gvn,xecute,killindex,"cmds",s)
	. . . . . . . if $data(hasht(gvn,xecute,killindex,"cmds")) do
	. . . . . . . . write "Modified Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,! if $incr(trigs("modified"))
	. . . . . . . else  do
	. . . . . . . . kill hasht(gvn,xecute,killindex)  do hashtdecrement(gvn)
	. . . . . . . . write "Deleted Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,!  if $incr(trigs("deleted"))
	. . . . . . else  if killspecified do
	. . . . . . . ; KILL trigger is not modified. Issue appropriate message.
	. . . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . . write "Non-SET trigger on ^",gvn," not present in trigger named ",gvn,"#",killindex," - no action taken",!
	. . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . write "SET trigger on ^",gvn," does not exist - no action taken",!
	. . . . . else  do
	. . . . . . ; need to touch KILL and SET trigger separately
	. . . . . . ; modify KILL trigger first
	. . . . . . kill tmp merge tmp=hasht(gvn,xecute,killindex,"cmds")
	. . . . . . do computediff(.tmp,.cmds,.common,.uniq1,.uniq2)
	. . . . . . set killmod=(0'=$data(common))
	. . . . . . ; options are ignored for a delete
	. . . . . . if (killmod) do
	. . . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . . new s set s="" for  set s=$order(common(s)) quit:s=""  kill hasht(gvn,xecute,killindex,"cmds",s)
	. . . . . . . if $data(hasht(gvn,xecute,killindex,"cmds")) do
	. . . . . . . . write "Modified Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,! if $incr(trigs("modified"))
	. . . . . . . else  do
	. . . . . . . . kill hasht(gvn,xecute,killindex)  do hashtdecrement(gvn)
	. . . . . . . . write "Deleted Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,!  if $incr(trigs("deleted"))
	. . . . . . else  if killspecified do
	. . . . . . . ; KILL trigger is not modified. Issue appropriate message.
	. . . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . . write "Non-SET trigger on ^",gvn," not present in trigger named ",gvn,"#",killindex," - no action taken",!
	. . . . . . ; modify SET trigger next
	. . . . . . kill tmp merge tmp=hasht(gvn,xecute,setindex,"cmds")
	. . . . . . new tmpcmds set tmpcmds("S")=""
	. . . . . . do computediff(.tmp,.tmpcmds,.common,.uniq1,.uniq2)
	. . . . . . set setmod=(0'=$data(common))
	. . . . . . ; options are ignored for a delete
	. . . . . . if 'setmod zshow "*" halt  ; unreachable hence the zshow/halt
	. . . . . . if (setmod) do
	. . . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . . ; at this time common() must contain only one subscript that is common("S") but we maintain loop below
	. . . . . . . ; so code is similar to code in other places and can be easily modularized later.
	. . . . . . . new s set s="" for  set s=$order(common(s)) quit:s=""  kill hasht(gvn,xecute,setindex,"cmds",s)
	. . . . . . . if $data(hasht(gvn,xecute,setindex,"cmds")) zshow "*" halt  ; unreachable hence the zshow/halt
	. . . . . . . kill hasht(gvn,xecute,setindex)  do hashtdecrement(gvn)
	. . . . . . . kill hasht(gvn,xecute,delim,pieces)
	. . . . . . . write "Deleted SET trigger on ^",gvn," named ",gvn,"#",setindex,!  if $incr(trigs("deleted"))
	. . . . else  do
	. . . . . ; SET and KILL triggers are identical
	. . . . . kill tmp merge tmp=hasht(gvn,xecute,killindex,"cmds")
	. . . . . new tmpcmds merge tmpcmds=cmds if setspecified set tmpcmds("S")=""
	. . . . . do computediff(.tmp,.tmpcmds,.common,.uniq1,.uniq2)
	. . . . . set killmod=(0'=$data(common))
	. . . . . if (killmod) do
	. . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . new s set s="" for  set s=$order(common(s)) quit:s=""  kill hasht(gvn,xecute,killindex,"cmds",s)
	. . . . . . if $data(hasht(gvn,xecute,killindex,"cmds")) do
	. . . . . . . new str
	. . . . . . . set str=$select((setspecified&killspecified):"SET and/or Non-SET",setspecified:"SET",1:"Non-SET")
	. . . . . . . write "Modified ",str," trigger on ^",gvn," named ",gvn,"#",killindex,! if $incr(trigs("modified"))
	. . . . . . . if setspecified do
	. . . . . . . . ; now that we know S type trigger has been removed, remove the pieces/delim parts of the trigger (if any)
	. . . . . . . . kill hasht(gvn,xecute,killindex,"pieces")
	. . . . . . . . kill hasht(gvn,xecute,killindex,"delim")
	. . . . . . . . kill hasht(gvn,xecute,delim,pieces)
	. . . . . . else  do
	. . . . . . . kill hasht(gvn,xecute,killindex)  do hashtdecrement(gvn)
	. . . . . . . kill hasht(gvn,xecute,delim,pieces)
	. . . . . . . new str
	. . . . . . . set str=$select((setspecified&killspecified):"SET and/or Non-SET",setspecified:"SET",1:"Non-SET")
	. . . . . . . write "Deleted ",str," trigger on ^",gvn," named ",gvn,"#",killindex,!
	. . . . . . . if $incr(trigs("deleted"))
	. . . . . else  do
	. . . . . . ; SET trigger might have changes. KILL trigger does not have changes. Issue appropriate message.
	. . . . . . write "File ",trigin,", Line ",i,": "
	. . . . . . set setmod=setexists
	. . . . . . if setmod write "Modified SET trigger on ^",gvn," named ",gvn,"#",killindex,! if $incr(trigs("modified"))
	. . . . . . else      do
	. . . . . . . new str set str=$select(killspecified:"SET and/or Non-SET",1:"SET")
	. . . . . . . write str," trigger on ^",gvn," not present in trigger named ",gvn,"#",killindex," - no action taken",!
	. . . else  do
	. . . . ; only need to touch KILL trigger
	. . . . kill tmp merge tmp=hasht(gvn,xecute,killindex,"cmds")
	. . . . do computediff(.tmp,.cmds,.common,.uniq1,.uniq2)
	. . . . set killmod=(0'=$data(common))
	. . . . ; options are ignored for a delete
	. . . . if (killmod) do
	. . . . . write "File ",trigin,", Line ",i,": "
	. . . . . new s set s="" for  set s=$order(common(s)) quit:s=""  kill hasht(gvn,xecute,killindex,"cmds",s)
	. . . . . if $data(hasht(gvn,xecute,killindex,"cmds")) do
	. . . . . . write "Modified Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,! if $incr(trigs("modified"))
	. . . . . else  do
	. . . . . . kill hasht(gvn,xecute,killindex)  do hashtdecrement(gvn)
	. . . . . . write "Deleted Non-SET trigger on ^",gvn," named ",gvn,"#",killindex,!  if $incr(trigs("deleted"))
	. . . . else  do
	. . . . . ; KILL trigger is not modified. Issue appropriate message.
	. . . . . write "File ",trigin,", Line ",i,": "
	. . . . . write "Non-SET trigger on ^",gvn," not present in trigger named ",gvn,"#",killindex," - no action taken",!
	. . else  do
	. . . ; trigger does not exist (KILL and/or SET). Issue appropriate message.
	. . . write "File ",trigin,", Line ",i,": "
	. . . new str
	. . . set str=$select((setspecified&killspecified):"SET and/or Non-SET",setspecified:"SET",1:"Non-SET")
	. . . write str," trigger on ^",gvn," does not exist - no action taken",!
	. if (setmod!killmod) do
	. .     if $incr(trigfile("upddb"))
	. .     if $incr(cycle(gvn))
	. else  if $incr(trigfile("noupddb"))
	. ;
	. ; zwrite gvn,cmds,pieces,delim,xecute,options
	write "=========================================",!
	write trigs("added")," triggers added",!
	write trigs("deleted")," triggers deleted",!
	write trigs("modified")," triggers modified",!
	write trigfile("upddb")," trigger file entries did update database trigger content",!
	write trigfile("noupddb")," trigger file entries did not update database trigger content",!
	write "=========================================",!
	close trigout
	;
	new index,first
	;
	;;;;;;;;;; GENERATE trigger select file ;;;;;;;;;;;;;;;;;;
	;
	open selectout:(newversion)
	use selectout
	set gvn="" for  set gvn=$order(hasht(gvn))  quit:gvn=""  do
	. set xecute="" for  set xecute=$order(hasht(gvn,xecute))  quit:xecute=""  do
	. . set index="" for  set index=$order(hasht(gvn,xecute,index))  quit:index=""  do
	. . . if +index=0 quit  ; e.g. strings like "-delim"
	. . . write ";trigger name: ",gvn,"#",index," (region ",$view("REGION","^"_gvn),")  cycle: ",cycle(gvn),!
	. . . write "+^",gvn," -commands="
	. . . set first=1 new cmd for cmd="S","K","ZK","ZTK","ZTR" do
	. . . . if $data(hasht(gvn,xecute,index,"cmds",cmd)) write $select(first:cmd,1:","_cmd)  set first=0
	. . . zkill hasht(gvn,xecute,index,"options")
	. . . if $data(hasht(gvn,xecute,index,"options")) do
	. . . . write " -options="
	. . . . set first=1 new option for option="I","NOI","C","NOC" do
	. . . . . if $data(hasht(gvn,xecute,index,"options",option)) write $select(first:option,1:","_option)  set first=0
	. . . if (""'=$get(hasht(gvn,xecute,index,"delim"))) write " ",hasht(gvn,xecute,index,"delim")
	. . . if (""'=$get(hasht(gvn,xecute,index,"pieces"))) write " ",hasht(gvn,xecute,index,"pieces")
	. . . write " ",xecute,!
	close selectout
	;
	quit

trigsplit;
	new file,linein,numin,i,prefix,suffix,cmds,restofline,cmdstr
	set file=$zcmdline
	do readfile(file,.linein)
	set numin=$order(linein(""),-1)
	set cmdstr="-commands="
	for i=1:1:numin do
	. set line=linein(i)
	. set prefix=$piece(line,cmdstr,1),suffix=$piece(line,cmdstr,2)
	. set cmds=$piece(suffix," ",1),restofline=$piece(suffix," ",2,999)
	. ; if commands contain S and non-S then split them into 2 lines one for S and one for non-S commands
	. if (cmds["S,") do
	. . write prefix,cmdstr,$piece(cmds,"S,",2)," "  do
	. . . if (restofline["-delim=")&(restofline["-options=") write $piece(restofline," -",1)," -",$piece(restofline," -",4),!
	. . . else  if (restofline["-delim=")                    write "-",$piece(restofline," -",3),!
	. . . else                                               write restofline,!
	. . write prefix,cmdstr,"S"," ",restofline,!
	. else  write line,!
	quit

hashtdecrement(gvn)
	if (0=$incr(hasht(gvn,"#TNCOUNT"),-1)) kill hasht(gvn) ; remove #SEQNUM in case there are no triggers
	quit

computediff(x,y,common,uniq1,uniq2)
	new s,ret
	kill common,uniq1,uniq2
	set ret=0,s=""
	for  set s=$order(x(s))  quit:s=""  do
	. if ('$data(y(s)))!($data(y(s))'=$data(x(s))) set uniq1(s)=$get(x(s))  quit
	. if ($get(x(s))'=$get(y(s))) set uniq1(s)=$get(x(s)),uniq2(s)=y(s)  quit
	. set common(s)=x(s)
	for  set s=$order(y(s))  quit:s=""  do
	. if ('$data(x(s)))!($data(x(s))'=$data(y(s))) set uniq2(s)=$get(y(s))  quit
	quit

readfile(file,line);
	new i
	open file:(exception="goto done")
        for  use file  read line($incr(i))
done    if '$zeof use $p write $zstatus,!
        close file
        quit

