;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
; 								;
; 	This source code contains the intellectual property	;
; 	of its copyright holder(s), and is made available	;
; 	under a license.  If you do not know the terms of	;
; 	the license, please stop and do not read further.	;
;	    	     	    	     	    	 		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Test program to generate as many potential display opportunities as possible for debugger/analyzer. Note, since this
; program runs on all versions from V51000 on, it should not have $ZPIECE/$ZEXTRACT or similar functions that came into
; existence in V52000. Any other use of version dependent features needs to be cached in Xecutes and/or indirects to
; prevent compile failures.
;
	Do SetReleaseFlags
	Xecute:'PreV52000 "View ""NOBADCHAR"""	; We create some illegal chars here, don't need UTF8 checks causing trubble
	Set Triggers=1	; Assume triggers work (for now)
	Set $ETrap="Use $P ZShow ""*"" Halt"
	;
	; Create some literals to make a long literal string
	;
	Set x="this is a long meaningless literal for the sake of having a decently long literal string in the literal pool"
	Set x="this one is too but is argueably even less useful since the x var we are assigning it into is replaced later"
	;
	; Do some database stuff
	;
        Kill ^ACCT,^ACNM,^JNL
	Set acntcnt=10000
	Set alphas="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	Set alphalen=$Length(alphas)
	For acct=1:1:acntcnt Do	; Create some accounts
	. ; Generate a random "name" for the account
	. Set name=""
	. For j=1:1:$Random(25)+1 Do 	; 25 or few characters
	. . Set ranchar=$Random(alphalen)+1
	. . Set name=name_$Extract(alphas,ranchar,ranchar)
	. ;
	. ; Generate a random "balance" for the account
	. Set balance=$Random(1000000)
	. TStart ():Transactionid="BATCH"
	. Set ^ACCT(acct)=balance
	. Set ^ACCT(acct,0)=balance	; Opening balance
	. Set ^ACNM(acct)=name
	. Set ^JNL(acct,0)=0
	. TCommit
	Set ^ACCT(0)=acntcnt
	;
	; The code below accesses the same global through 2 different global directories
	;
	Set ^gbltest("hi")=42
	Set zz=^|"mumps.gld"|gbltest("hi")
	;
	; Create some open devices for device reporting validation
	;
	Set file="output-file.txt"
	Open file:(New:Fixed:Recordsize=133)
	;
	; Bypass socket creation on HPUX-IA64 V53000-V53001* due to GETSOCKOPTERR. Note socket port to use fetched
	; from $socketportno setup by basic.csh. Note no need to test for PreV53000 since V53000 was the first
	; IA64 release.
	;
	Do:('(PreV53002&($Piece($ZVersion," ",3,4)="HPUX IA64")))
	. Lock ^InetSocket		; This is the lock that client uses as signal we are done
	. Set portno=$ZTrnlnm("socketportno")
	. Do:(""=portno)
	. . Write "Null socket port - cannot proceed"
	. . Halt
	. Set isocdev="iserver$"_$Job
	. Set timeout=120
	. Job ^makedmpiscl		; Fire up the inet clients
	. Open "makedmpi.job":New
	. Use "makedmpi.job"
	. Write $ZJob,!			; Record its process id for the script to kill
	. Close "makedmpi.job"
	. Open isocdev:(ZLISTEN=portno_":TCP":attach="iserver"):timeout:"SOCKET"
	. Use isocdev
	. Write /listen(5)
	. Use $P
	. Write "Accepting inet listeners",!
	. Use isocdev
	. For i=1:1:5 Write /wait(timeout)
	. Use $P
	. Write "Listeners accepted - waiting for client startup",!
	. ;
	. ; Wait for client to define length of data being sent
	. ;
	. For i=1:1:100 Quit:(0<$Data(^linelen))  Hang 1
	. Use $P
	. Write "Inet client running - waiting for reads",!
	. Write "Socket setup complete",!
	. For i=1:1:5 Do
	. . Use isocdev
	. . Write /Wait(timeout)	; Wait for input to post
	. . Read x#^linelen
	. . Use $P
	. . Write "Inet socket read #",i," complete",!
	. Use $P:CTrap=$C(3)
	. Write "Inet socket reads complete",!
	. ;
	. ; For V61000 and later, do same as above for local sockets
	. ;
	. Do:('PreV61000)
	. . Lock ^LocalSocket		; This is the lock that client uses as signal we are done
	. . Set socpath="local.socket"
	. . Set lsockdev="lserver"_$Job
	. . Set timeout=120
	. . ;
	. . ; Open via Xecute so doesn't cause compile errors on previous versions
	. . ;
	. . Xecute "Open lsockdev:(ZListen=socpath_"":Local"":New:IOError=""T"":Attach=""lserver""):timeout:""Socket"""
	. . Use lsockdev
	. . Write /listen(5)
	. . Use $P
	. . Write "Accepting local listeners",!
	. . Job ^makedmplscl		; Fire up the local clients
	. . Open "makedmpl.job":New
	. . Use "makedmpl.job"
	. . Write $ZJob,!		; Record its process id for the script to kill
	. . Close "makedmpl.job"
	. . Use lsockdev
	. . For i=1:1:5 Write /wait(timeout)	;
	. . Use $P
	. . Write "Local listeners accepted - waiting for client startup",!
	. . ;
	. . ; Wait for client to define length of data being sent
	. . ;
	. . For i=1:1:100 Quit:(0<$Data(^linelen))  Hang 1
	. . Use $P
	. . Write "Local client running - waiting for reads",!
	. . Write "Local socket setup complete",!
	. . For i=1:1:5 Do
	. . . Use lsockdev
	. . . Write /Wait(timeout)	; Wait for input to post
	. . . Read x#^linelen
	. . . Use $P
	. . . Write "Local socket read #",i," complete",!
	. . Use $P:CTrap=$C(3)
	. . Write "Local socket reads complete",!
	;
	; Do pipes after socket due to issues this causes with versions prior to V54003.
	;
	Do:('PreV53003)
	. Set pipe="somepipe"
	. Xecute "Open pipe:(Chset=""M"":Command=""/bin/sh"":NoWriteOnly)::""PIPE"""
	;
	Set $ZYError="zyerrorrtn^makedmp"
	;
	; The below set will drive a trigger which will call back into this module for the rest of the fun
	;
	Set ^Default("Strkey",$Char(0,1,2,3,4,5),0,4200000,-4200000.10,123,-12.3,1.23,-.123,.0123,-.00123,.00123,.000123,0)=42
	;
	; On non-trigger supported platforms, we will return so just invoke triggergames directly..
	;
	If ($Piece($ZVersion," ",3,4)="HP-UX HP-PA")!("V5.4-000"]$Piece($ZVersion," ",2)) Do notriggerentry
	Write !!,"    *      *      ERROR!!!!! Something very wrong!! Trigger was NOT tripped!!",!!
	Quit

;
; Routine to set release flags and return. We need to do this a few times since we re-create the symbol table a few times
;
SetReleaseFlags
	If ("V5.2-000"]$Piece($ZVersion," ",2)) Set PreV52000=1
	Else  Set PreV52000=0
	If ("V5.3-002"]$Piece($ZVersion," ",2)) Set PreV53002=1
	Else  Set PreV53002=0
	If ("V5.3-003"]$Piece($ZVersion," ",2)) Set PreV53003=1
	Else  Set PreV53003=0
	If ("V5.3-004"]$Piece($ZVersion," ",2)) Set PreV53004=1
	Else  Set PreV53004=0
	If ("V5.4-000"]$Piece($ZVersion," ",2)) Set PreV54000=1
	Else  Set PreV54000=0
	If ("V5.4-001"]$Piece($ZVersion," ",2)) Set PreV54001=1
	Else  Set PreV54001=0
	If ("V6.1-000"]$Piece($ZVersion," ",2)) Set PreV61000=1
	Else  Set PreV61000=0
	Quit


;
; This entry point invoked by the trigger when ^Default is updated. Non-trigger platforms calls triggergames directly.
;
triggerentry
	Write "Trigger entered via trigger",!
	Do triggergames(1)
	Quit

notriggerentry
	New	; Simulate trigger new symtab
	Write "Trigger entered via direct call (no trigger support)",!
	Do triggergames(0)
	Quit

triggergames(Triggers)
	Do SetReleaseFlags
	;
	; Note from this point forward, we have a new symbol table
	;
	Set alphanums="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	Set ax=0,bx=0,cx=0,dx=0,ex=0,fx=0,gx=0
	For i=1:1:$Random(100000) Set ax=ax+i
	For i=1:1:$Random(100000) Set bx=bx+i
	For i=1:1:$Random(100000) Set cx=cx+i
	For i=1:1:$Random(100000) Set dx=dx+i
	For i=1:1:$Random(1000) Set ex=ex+i
	For i=1:1:$Random(1000) Set fx=fx+i
	For i=1:1:$Random(1000) Set gx=gx+i
	For i=1:1:5 Set ctls("ctl"_$$ZChar(i))=i
	For i=6:1:10 Set ctls($$ZChar(i)_"ctl")=i	; In case order of args makes any difference
;	Set idx=""
;	For  ZWrite idx Set i=$Order(@("ctls("""_idx_""")")) Quit:(""=idx)  Set v=@("ctls("""_idx_""")") ZWrite v Write !	; Add some indirects using control chars
	Xecute:Triggers "Set $ZTWormhole=""some value"""
	Set x=ax/3
	Set y=bx*cx/dx
	For i=1:1:10 Set x($Random(1000))=$Random(1000000000)/(1+$Random(5113))
	For i=1:1:10 Set len=$Random(22) Set y($Random(1000000000)/(1+$Random(19)))=$Extract(alphanums,len,len+len)
	For i=1:1:$Random(25) Set len=$Random(10) Set z($Extract(alphanums,len,len+$Random(15)))=$Random(100000)*$Random(999999)/(1+$Random(9))
	Set x("some","char","subs","and",0)="others"
	Set x("A ""quoted"" string")=42
	Set killed=x
	Kill killed
	For i=1:1:10 Set simple(i)=$Random(100000)
	Do:'PreV53004	 ; avoid alias stuff on Pre-V53004 releases
	. Xecute "Set *aax=ax,*ddx=dx,*ggx=gx,*earlyx=x"
	. Xecute "Set *a(1)=ax,*a(2)=gx,*z(1)=bx,*z(2)=killed,*z(3)=x,*z(4)=killme"
	. Xecute "Set killme(""a"",""couple"",""subs"")=42,killme(""and"",1,""or"",2,""more or more"")=43,*killme(""z"")=killme2"
	. Xecute "Set killme2(99,""bottles"",""of"")=""beer"",killme2(98,""on"",""the"",""wall"")=""smash"",*killme2(97)=cx,*killme2(96)=zzz"
	. Xecute "Kill *killme,*killme2"
	;
	; We want to NEW $ZTWORMHOLE but only if triggers are supported. Since an Xecuted NEW is popped when the xecute finishes,
	; use an indirect flavor instead.
	;
	If (Triggers&'PreV54001) Set name="$ZTWormhole"
	Else  Set name="nontriggername"
	New @name
	Xecute:Triggers "Set $ZTWormhole=""wormish-text"""
	Xecute:(Triggers&'PreV54001) "Set $ZTSlate=""slate-ish-text"""
	Set file="makedmp_zwr.txt"
	Open file:New
	Use file
	ZWrite	; Preserve our current setup for comparison with gtmpcat
	Close file
	Use $P
	New	; Hide previous stuff creating yet another symbol table.
	;
	; Create a value in a var and NEW it to verify values dump correctly in mvstent stack display
	;
	Set AValue="previous value"
	New AValue
	Set AValue="new value"
	Do SetReleaseFlags
	Do:'PreV53004  ; more alias aversion
	. Xecute "Set t(1)=""t1"",t(2)=""t2"",*t(3)=u,u(1)=""u1"",u(2)=""u2"",*s(1)=t"
	. Xecute "Kill *t,*u"
	. Xecute "Set hidden=42,*hidden(1)=a,*hidden(2)=hidden2,hidden(3)=24,hidden2(1)=98"
	. Xecute "Kill *hidden2"
	;
	; Set some zchar stuff for zwr format testing
	;
	Set t99=$$ZChar(1,2,3)_"abc"_$$ZChar(4,5,6)
	Set t99(1)="ab"_$$ZChar(1,2)_"cd"_$$ZChar(3,4)_"ef"
	Set t99($$ZChar(1,2,3)_"abc"_$$ZChar(4,5,6))=42
	Set t99("ab"_$$ZChar(1,2)_"cd"_$$ZChar(3,4)_"ef",66)=1
	;
	; Create a bunch of local variables but kill their values. Purpose of this is to create a large symbol table but it
	; will have relatively few (used) entries in it. This will test the efficiency of the local var dumping logic.
	; Profile typically has up to 2K-4K vars in the symbol table but with only 10% of that actually having a real value.
	; Easiest way to do this is to create some temorary programs each with a couple hundred vars in it. Relink the same
	; program over and over so we don't swell up too much.
	;
	Set fn="makedmpc.m"
	Set alphanums="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	Set alphanumlen=$Length(alphanums)
	For relinks=1:1:25 Do
	. Open fn:New
	. Use fn
	. For vars=1:1:33 Do
	. . Set varname=""
	. . For varlen=1:1:4+$Random(8)+1 Set varname=varname_$Extract(alphanums,$Random(alphanumlen)+1)
	. . Write " Set XX",varname,"=1 Kill XX",varname,!	; Prefix all varnames with XX to prevent collision with vars we very much use
	. Close fn
	. ZLink fn
	. Do ^makedmpc
	. Open fn
	. Close fn:Delete
	Do:'PreV53004	; More alias aversion
	. Xecute "Set $ZWRTAC1=1"
	. Xecute "Set $ZWRTAC="""""
	Lock +^ACCT(30),+^ACNM("modern","vampire"),+^JNL(1,2,3,"fee","fie","foe")
	Set var97(22,310,"lit",42)=97
	Set var97(22,310,"lit",42,"string")=97
	Set var97(22,310,"lit",42,"string")=97
	Set var97(22,310,"lit",42,"string2")=97
	Set var97(22,310,"lit",42,"string3")=97
	Set var97(22,310,"lit",42,"string4")=97
	Set var97(22,310,"lit",42,"string5")=97
	Set var97(22,310,"lit",42,"string6")=97
	Set var97(22,310,"lit",42,"string7")=97
	Set var97(22,310,"lit",42,"string8")=97
	Set var97(22,310,"lit",42,"string9")=97
	Set var97(22,310,"lit",42,"string10")=97
	Set var97(22,310,"lit",42,"string12")=97
	Set var97(22,310,"lit",42,"string13")=97
	Set var97(22,310,"lit",42,"string14")=97
	Set var97(23,1,"alit")=97
	For i=1:1:10 Set negvals(-i)=$$Negval()
	For i=1:1:10 Set negsubs($$Negval(),$$Negval(),$$Negval())=-i
	Xecute "Do intrtn(.var97)"
	w 1/0

intrtn(hidden)
	;
	; Case old gen version in use
	;
	Do ^makedmpa
	ZLink "makedmpa.m"
	ZLink "makedmpa.m"
	;
	; Case current gen version in use
	;
	ZLink "makedmpb.m"
	ZLink "makedmpb.m"
	;
	; Drive a $ZInterrupt to create an additional frame
	;
	Set $ZInterrupt="Do ^makedmpb"
	ZSystem "$gtm_dist/mupip intr "_$Job
	For i=1:1:120 Hang 1	; Loop that waits for the interrupt
	;
	; Rats - interrupt didn't take - just call ^makedmpb directly then
	;
	Do ^makedmpb		; Doesn't return but drives docore with an artificial error

docore()
	;
	; Sleep until replication catches up.
	;
	ZSystem "setenv gtm_test_cur_sec_name SECINST; $gtm_tst/com/wait_until_src_backlog_below.csh 0"
	Do	; Argumentless Do pushes mvstent on stack
	. If $ZJobexam()
	. ZSystem "/bin/kill -4 "_$Job
	. Write "Waiting to die",!
	. Hang 10
	. ZMessage 150377788	; generates core if other methods fail

;
; Routine to return negative random value
;
Negval()
	Quit -$Random(1000000)

;
; Use $ZChar() to create values in UTF8 capable versions else use $Char(). Support up to 6 args.
;
ZChar(a1,a2,a3,a4,a5,a6)
	New str
	Do:(PreV52000)  Quit:(PreV52000) str
	. Set str=$Char(a1)
	. Set:(0<$Data(a2)) str=str_$Char(a2)
	. Set:(0<$Data(a3)) str=str_$Char(a3)
	. Set:(0<$Data(a4)) str=str_$Char(a4)
	. Set:(0<$Data(a5)) str=str_$Char(a5)
	. Set:(0<$Data(a6)) str=str_$Char(a6)
	;
	; Else we are unicode capable so use $ZChar() instead.
	;
	Set @("str=$ZChar(a1)")				; $ZChar references "protected" inside indirects for use on V51000
	Set:(0<$Data(a2)) @("str=str_$ZChar(a2)")
	Set:(0<$Data(a3)) @("str=str_$ZChar(a3)")
	Set:(0<$Data(a4)) @("str=str_$ZChar(a4)")
	Set:(0<$Data(a5)) @("str=str_$ZChar(a5)")
	Set:(0<$Data(a6)) @("str=str_$ZChar(a6)")
	Quit str

;
; Little nothing routine that is the subject of $ZYERROR
;
zyerrorrtn
	Set $ZYError="nonexist^bogusentryref"
	Quit
