;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2009, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Additional basic functionality of alias support
;
	Write !,!,"******* Start of ",$Text(+0)," *******",!,!

        Set $ETrap="Write ""Error trap signaled"",!! ZShow ""*"" Halt"
	; Build list of cases and run them
	Set caselist="alsnewpop alsdotprm subnewals chkcntflg lvrehash memleak killaliasall killdotprms killdotver xkilltst"
	Set caselist=caselist_" varreuse repcntnr1 repcntnr2 killaliasall2 repals1 repals2 repcntnr3 zahtst alsindir"
	Set caselist=caselist_" varretain zahindir zdataindir pvalrepl killaliasall3 zwrundefals alslvgc alscmrglv alscmrggv"
	W !,"--------------------------",!
	For i=1:1:$Length(caselist," ") Do
	. Set casename=$Piece(caselist," ",i)
	. Kill *	; Rid the world of aliases prior to new case
	. Write "Test case: ",casename,!
	. Do @casename
	. Write !,"--------------------------",!

	Write !,!,"******* Finish ",$Text(+0)," *******",!,!
	Quit

	; test#1 - Check alias var can be new'd and restored when new pops
alsnewpop
	New
	Set a=1
	Set *b=a
	Write "Prior to call - $ZData(b)=",$ZData(b)," - value: ",b,!
	Do alsnewpopsub
	Write "After call (New pop) - $ZData(b)=",$ZData(b)," - value: ",b,!
	Quit
alsnewpopsub
	New b
	Write "In subrtn prior to set - $ZData(b)=",$ZData(b)," - value: ",$Get(b,"not-set"),!
	Set b=2
	Write "In subrtn after set - $ZData(b)=",$ZData(b)," - value: ",b,!
	Quit

	; test#2 - Check reference counts with dotted parms and verify revert on return
alsdotprm
	New
	Set a=1
	Write "prior to call to suba - parm type: ",$ZData(a)," -- parm refcnt: ",$View("LV_REF","a"),!
	Do alsdotprmsuba(.a)
	Write "returned from suba - parm type: ",$ZData(a)," -- parm refcnt: ",$View("LV_REF","a"),!
	Do alsdotprmsubb(.a)
	Write "returned from subb - parm type: ",$ZData(a)," -- parm refcnt: ",$View("LV_REF","a"),!
	Quit
alsdotprmsuba(A)	; Parameter named something different than base var name
	Write "In suba - parm type: ",$ZData(A)," -- parm refcnt: ",$View("LV_REF","A"),!
	Write "In suba - base type: ",$ZData(a)," -- base refcnt: ",$View("LV_REF","a"),!
	Quit
alsdotprmsubb(a)	; Parameter named same as base var name
	Write "In subb - parm type: ",$ZData(a)," -- parm refcnt: ",$View("LV_REF","a"),!
	Quit

	; test#3 - Subroutine news and var and creates alias .. verify new pop reverts to non-alias status yet
	;          retains value set through temp alias.
subnewals
	New
	Set x=1
	Write "prior to call - x type: ",$ZData(x)," -- x refcnt: ",$View("LV_REF","x")," -- x value: ",x,!
	Do subnewalssub
	Write "after call (New pop) - x type: ",$ZData(x)," -- x refcnt: ",$View("LV_REF","x")," -- x value: ",x,!
	Quit
subnewalssub
	New X
	Set *X=x
	Set X=2
	Write "in sub - x type: ",$ZData(x)," -- x refcnt: ",$View("LV_REF","x")," -- x value: ",x,!
	Write "in sub - X type: ",$ZData(X)," -- X refcnt: ",$View("LV_REF","X")," -- X value: ",X,!
	Quit

	; test#3 - Check that the container flag is not copied when a container var is copied and that it does copy correctly
	; 	   when used with SET * and that the refcount is appropriately increased
chkcntflg
	New
	Set a=1
	Set *b(1)=a
	Set c(1)=b(1)
	Write $Select($ZData(c(1))>99:"Container flag inappropriately copied with assignment",1:"Container flag was supressed with assignment"),!
	Set d(1)=$Get(b(1))
	Write $Select($ZData(d(1))>99:"Container flag inappropriately copied with $Get()",1:"Container flag was supressed with $Get()"),!
	Merge e=b
	Write $Select($ZData(e(1))>99:"Container flag inappropriately copied with Merge",1:"Container flag was supressed with Merge"),!
	Set g(1)=$$chkcntflgsub()
	Write $Select($ZData(g(1))>99:"Container flag inappropriately copied with subrtn return value",1:"Container flag was supressed with subroutine return value"),!
	Set a=$View("LV_REF","a")
	Set *f(1)=b(1)
	Write $Select((($ZData(f(1))>99)&($View("LV_REF","a")=(a+1))):"Container was properly copied",1:"Container improperly copied"),!
	Quit
chkcntflgsub()
	If '$ZData(b(1)) Write "Ooops .. missing container flag",!
	Quit b(1)

	; test #4 - Force lv hash table rebuild and verify can still access local variables. This basically
	;           checks the als_lsymtab_repair routine in alias_funcs.
lvrehash
	New
	Set x=1
	Set y=2
	Do lvrehashsub(.x,y)
	Write "lvrehash test ",$Select((y=3)&(x=2):"PASS",1:"FAIL"),!
	Quit
lvrehashsub(a,b)
	View "LV_REHASH"
	Set a=a+1
	View "LV_REHASH"
	Set y=y+1
	Quit

	; test #5 - Check for memory leaks in parameter passing and routine unwind/return
memleak
	New
	For i=1:1:10 do memleaksub1	; Prime the pump
	Set memstart=$ZRealstor
	For i=1:1:500 do memleaksub1
	Set memend=$ZRealstor
	Write "memleak test ",$Select(memend=memstart:"PASS",1:"FAIL"),!
	Quit
memleaksub1
	New A,B,C,D,E,V,W,X,Y,Z,caselist,casename,i
	Set A="avar"
	Set B="bvar"
	Set C="cvar"
	Set D="dvar"
	Set E="evar"
	For i=1:1:100 Do memleaksub2(.A,.B,.C,D,E)
	Quit
memleaksub2(V,W,X,Y,Z)
	Set *V=Y
	Set *W=X
	Set A=Z
	Quit

	; test#6 - Check KILL * that it kills all vars that are aliases and containers
killaliasall
	New
	Set *A=B
	Set *C=D
	Set A=2,C=3
	Set E=4,F=5
	Set Estat=$ZData(E)
	Set *F(1)=E
	Set F1stat=$ZData(F(1))
	Write "*** Begin ZWrite ***",!
	ZWrite
	Write "*** End of ZWrite ***",!
	Write "$ZData(E) was ",Estat," and is now ",$ZData(E),!,!
	Write "Killing all aliases now",!
	Kill *
	Write "*** Begin ZWrite ***",!
	ZWrite
	Write "*** End of ZWrite ***",!
	Write "$ZData(F(1)) was ",F1stat," and is now ",$ZData(F(1)),!
	Quit

	; test#7 - Kill * inside a routine called with dotted parms (which are considered aliases)
killdotprms
	New
	Set a=1,b=2,c=3,d=4
	Set *z=b
	Do killdotprmssub(.a,.b,c,d)
	Write "****** Returned from tc15sub",!
	; All parms passed as dots are gone
	ZWrite
	Quit
killdotprmssub(e,f,g,h)
	Write "****** Inside tc15sub",!
	ZWrite
	Write "Performing kill *",!
	Kill *
	ZWrite
	Quit

	; test#8 - Var a exists, parm b passed as dotted parm to sub as "var a". Kill *a and upon
	;          return verify a is correct.
killdotver
	New
	Set a=42,b=43
	Do killdotversub(.b)
	Write "killdotver test ",$Select(a=42:"PASS",1:"FAIL"),!
	Quit
killdotversub(a)
	Kill *a
	; Create enough vars to cause reuse of released control blocks
	For i=1:1:1000 Set v="a"_i X "Set "_v_"=i"
	Quit

	; test#9 - Exclusive kill - Two arrays with a container pointer between them. The exclusive
	;          kill will kill one of them but not the other .. check ref cnts.
xkilltst
	New
	Set a=1,*a(1)=b,b=2
	Write "Pre-kill zwr follows:",!
	ZWrite
	Write "refcount for a: ",$View("LV_REF","a"),!
	Write "refcount for b: ",$View("LV_REF","b"),!
	Write "Performing Kill (b)",!
	Kill (b)
	Write "Post-kill ZWrite follows:",!
	ZWrite
	Write "refcount for b: ",$View("LV_REF","b"),!
	Quit

	; test#10 - Verify can use var kill *'d on same line (verify a usable lv_val remains)
varreuse
	New
	Set a=1,b=2
	Kill *a Set a=3
	Set *c=a
	ZWrite
	Write "So far so good, trying unqualified Kill *",!
	Kill * Set d=4
	ZWrite
	Quit

	; test#11 - Replace an existing container, make sure refcnts for previous target adjusted.
repcntnr1
	New
	Set a=1,*b(1)=a
	If $View("LV_REF","a")'=2 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 2",! ZShow "*" Quit
	Set b(1)=2
	If $View("LV_REF","a")'=1 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 1",! ZShow "*" Quit
	Write "repcntnr1: PASS",!
	Quit

	; test#12 - Replace an existing container, make sure refcnts for previous target adjusted.
repcntnr2
	New
	Set a=1,b=2,*c(1)=a
	If $View("LV_REF","a")'=2 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 2",! ZShow "*" Quit
	If $View("LV_REF","b")'=1 Write "Bad refcount: b refcnt is ",$View("LV_REF","b")," and should be 1",! ZShow "*" Quit
	Set *c(1)=b
	If $View("LV_REF","a")'=1 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 1",! ZShow "*" Quit
	If $View("LV_REF","b")'=2 Write "Bad refcount: b refcnt is ",$View("LV_REF","b")," and should be 2",! ZShow "*" Quit
	Write "repcntnr2: PASS",!
	Quit

	; test#13 - Kill * but verify the lv_vals were recovered and not left orphaned due to improper refcnt maint
killaliasall2
	New
	Set a=1,b=2,*a(1)=b,*b(1)=a
	If $View("LV_REF","a")'=2 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 2",! ZShow "*" Quit
	If $View("LV_CREF","a")'=1 Write "Bad crefcount: a refcnt is ",$View("LV_CREF","a")," and should be 1",! ZShow "*" Quit
	If $View("LV_REF","b")'=2 Write "Bad refcount: b refcnt is ",$View("LV_REF","b")," and should be 2",! ZShow "*" Quit
	If $View("LV_CREF","b")'=1 Write "Bad crefcount: b refcnt is ",$View("LV_CREF","b")," and should be 1",! ZShow "*" Quit
	Kill *
	View "LV_GCOL"	; Would find any orphans but if couldn't recover them, this will cause an assert failure (dbg only of course)
	If $View("LV_REF","a")'=1 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 1",! ZShow "*" Quit
	If $View("LV_CREF","a")'=0 Write "Bad crefcount: a refcnt is ",$View("LV_CREF","a")," and should be 0",! ZShow "*" Quit
	If $View("LV_REF","b")'=1 Write "Bad refcount: b refcnt is ",$View("LV_REF","b")," and should be 1",! ZShow "*" Quit
	If $View("LV_CREF","b")'=0 Write "Bad crefcount: b refcnt is ",$View("LV_CREF","b")," and should be 0",! ZShow "*" Quit
	Write "killaliasall2: PASS",!
	Quit

	; test#14 - Replace an alias, verify counts
repals1
	New
	Set a=1,*b=a,c=2
	If $View("LV_REF","a")'=2 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 2",! ZShow "*" Quit
	If $View("LV_REF","b")'=2 Write "Bad refcount: b refcnt is ",$View("LV_REF","b")," and should be 2",! ZShow "*" Quit
	If $View("LV_REF","c")'=1 Write "Bad refcount: c refcnt is ",$View("LV_REF","c")," and should be 1",! ZShow "*" Quit
	Set *b=c
	If $View("LV_REF","a")'=1 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 1",! ZShow "*" Quit
	If $View("LV_REF","b")'=2 Write "Bad refcount: b refcnt is ",$View("LV_REF","b")," and should be 2",! ZShow "*" Quit
	If $View("LV_REF","c")'=2 Write "Bad refcount: c refcnt is ",$View("LV_REF","c")," and should be 2",! ZShow "*" Quit
	Write "repals1: PASS",!
	Quit

	; test#15 - Replace an alias with the container var pointing to it, verify no change
repals2
	New
	Set a=42,*b(1)=a
	If $View("LV_REF","a")'=2 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 2",! ZShow "*" Quit
	If $View("LV_CREF","a")'=1 Write "Bad refcount: a crefcnt is ",$View("LV_CREF","a")," and should be 1",! ZShow "*" Quit
	Set *a=b(1)
	If $View("LV_REF","a")'=2 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 2",! ZShow "*" Quit
	If $View("LV_CREF","a")'=1 Write "Bad refcount: a crefcnt is ",$View("LV_CREF","a")," and should be 1",! ZShow "*" Quit
	If 42'=a Write "Lost variable value in reassign, value is '",a,"' and should be '42'",! ZShow "*" Quit
	Write "repals2: PASS",!
	Quit

	; test#16 - Replace a container var with the same pointer, verify counts
repcntnr3
	New
	Set a=42,*c(1)=a
	If $View("LV_REF","a")'=2 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 2",! ZShow "*" Quit
	If $View("LV_CREF","a")'=1 Write "Bad refcount: a crefcnt is ",$View("LV_CREF","a")," and should be 1",! ZShow "*" Quit
	Set *c(1)=a
	If $View("LV_REF","a")'=2 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 2",! ZShow "*" Quit
	If $View("LV_CREF","a")'=1 Write "Bad refcount: a crefcnt is ",$View("LV_CREF","a")," and should be 1",! ZShow "*" Quit
	Write "repcntnr3: PASS",!
	Quit

	; test#17 - Verify $ZAHANDLE functionality
zahtst
	New
	Set A=$ASCII("A"),Z=$ASCII("Z"),NUM0=$ASCII("0"),NUM9=$ASCII("9")
	Set a=1,b=2,*c=b,d(1)=3,*e(1)=b,err=0
	Set za=$ZAHANDLE(a)
	If '$$zahtstvalidhex(za) Write "Invalid $ZAHANDLE() return value for a - should be hex, value was: '",za,"'",! Set err=1
	Set zb=$ZAH(b)
	If '$$zahtstvalidhex(zb) Write "Invalid $ZAHANDLE() return value for b - should be hex, value was: '",zb,"'",! Set err=1
	Set zc=$ZAHANDLE(c)
	If '$$zahtstvalidhex(zc) Write "Invalid $ZAHANDLE() return value for c - should be hex, value was: '",zc,"'",! Set err=1
	If zc'=zb Write "$ZAH(b) not equal to $ZAH(c) - b: ",zb,"  c: ",zc,! Set err=1
	Set zd=$ZAH(d(1))
	If ""'=zd Write "Invalid $ZAHANDLE() return value for d(1) - should be null, value was: '",zd,"'",! Set err=1
	Set ze=$ZAHANDLE(e(1))
	If '$$zahtstvalidhex(ze) Write "Invalid $ZAHANDLE() return value for e(1) - should be hex, value was: '",ze,"'",! Set err=1
	If ze'=zb Write "$ZAH(b) not equal to $ZAH(e(1)) - b: ",zb,"  e(1): ",ze,! Set err=1
	Write "zahtst: ",$Select(err:"FAIL",1:"PASS"),!
	Quit
zahtstvalidhex(ha)
	If ""=ha Quit 0	; Null value is not valid
	Quit (""=$Translate(ha,"0123456789ABCDEF"))

	; test#18 - Check the limited indirection support for aliases.
alsindir
	New
	Set a=1,x1="*b=a",x2="*c(1)=b"
	Set @x1,@x2
	If $View("LV_REF","a")'=3 Write "Bad refcount: a refcnt is ",$View("LV_REF","a")," and should be 3",! ZShow "*" Quit
	Write "alsindir: PASS",!
	Quit

	; test#19 - Create a new reference from container var contained in current array of same name. Verify we are
	;	    preventing the data the container refers to from going away before the new reference can be created
varretain
	New
	Set a("prop")="outside"
	Set a="root"
	Do varretainsub(a,.b)
	Set *b=b(-1.5)
	If "inside"'=b("prop") Write "Data not correct returned from subroutine",! ZShow "*" Quit
	Write "varretain: PASS",!
	Quit
varretainsub(c,d)
	Set c("prop")="inside"
	Set *d(-1.5)=c
	Quit

	; test#20 - Test indirect for $ZAHANDLE
zahindir
	New
	Set a=42,*b(1)=a,x="b(1)"
	Set c=$ZAHandle(b(1))
	Set d=$ZAHandle(@x)
	If c'=d Write "Indirect for $ZAHANDLE not returning expected value",! ZShow "*" Quit
	Write "zahindir: PASS",!
	Quit

	; test#21 - Test indirect for $ZDATA
zdataindir
        New
        Set a=42,*b(1)=a,x="b(1)"
        If $Data(@x)'=1 Write "Improper return value from $DATA: ",$Data(@x),! ZShow "*" Quit
        If $ZData(@x)'=101 Write "Improper return value from $ZDATA: ",$ZData(@x),! ZShow "*" Quit
        Write "zahindir: PASS",!
        Quit

	; test#22 - Replace pval (parameter in subroutine) by resetting its alias then do an LVGC
	;	    to verify it handles the situation correctly.
pvalrepl
	New
	Set a="A42"
	Do pvalreplsub(a)
	If $ZData(b)'=0 Write "** FAIL ** b not properly unwound",! ZShow "*" Quit
	If a'="A42" Write "** FAIL ** a has improper value",! ZShow "*" Quit
	Write "pvalrepl: PASS",!
	Quit
pvalreplsub(b)
	Set *b=a
	View "LV_GCOL"
	Quit

	; test#23 - Create two arrays each with a container pointing to the other array. Then KILL *.
	; 	    Both should be non-visible but still exist. Run LV_GCOL to verify both are recovered.
killaliasall3
	New
	Set a=1,b=2,*a(1)=b,*b(1)=a
	Kill *
	If $ZData(a)'=0 Write "** FAIL ** Variable 'a' has not completely disappeared",! ZShow "*" Quit
	If $ZData(b)'=0 Write "** FAIL ** Variable 'b' has not completely disappeared",! ZShow "*" Quit
	Set recovlvs=$View("LV_GCOL")
	; If dbg image we cannot expect deterministic VIEW "LV_GCOL" return values (due to VIEW "LV_GCOL" called
	; randomly from gtm_fetch). This means the above LV_GCOL might not have recovered anything because
	; a random LV_GCOL called from gtm_fetch recovered that already. Account for that possibility below.
	; In Unix check tst_image env var and in VMS test gtm$exe logical.
	set isdbg=($ztrnlnm("tst_image")="dbg")!($ztrnlnm("gtm$exe")["DBG")
	If (recovlvs'=2)&('isdbg!(recovlvs'=0)) do  Quit
	. Write "** FAIL ** KILL * left orphaned LV_VALS which LV_GCOL could not recover",! ZShow "*"
	If $View("LV_GCOL")'=0 Write "** FAIL ** KILL * left orphaned LV_VALS",! ZShow "*" Quit
	Write "killaliasall3: PASS",!
	Quit

	; test#24 - Verify that ZWrite will output relationships even if the values of the vars in those
	;	    relationships is undefined [C9J07-003148].
zwrundefals
	New
	Set *a=b
	ZShow "V":%zsout	; Picked local var name that preceeds the first var it will find before anything is set
	Write "zwrundefals: ",$Select((($Get(%zsout("V",1))="*b=a")&(0=$Data(%zsout("V",2)))):"PASS",1:"**FAIL**"),!
	Quit

	; test #25 - Test fix for D9K05-002772 - LV_GCOL problems. Create 31 var with 1-31 subscripts. Each subscript
	;            contains a container to a simple subscripted var (XX). After each container is created, XX is
	; 	     Kill-#'d to orphan the data. Then run VIEW LV_GCOL to force an lv_val garbage collection. In
	; 	     versions prior to V5.4-001, the containers with more than one subscript had the subscripted orphaned
	; 	     data nodes they were pointing to deleted.
	;
	;            Enhance this test to also have non-containers at certain subscript levels; exposed a regression in V54002
alslvgc
	New
	Set abc="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	Set key=""
	For cnt=1:1:31 Do
	. Set newsubscr=$Extract(abc,cnt)
	. If key'="" Set key=key_","
	. Set key=key_""""_newsubscr_""""
	. Set XX=cnt,XX(1)=cnt+1
	. if cnt#2=0  do
	. . Set @("*a("_key_")=XX")
	. . Kill *XX
	. else  Set @("a("_key_")=cnt")
	;
	; Now run the lv_gcol
	View "LV_GCOL"

	; Now verify the nodes
	Set key=""
	For cnt=1:1:31 Do
	. Set newsubscr=$Extract(abc,cnt)
	. If key'="" Set key=key_","
	. Set key=key_""""_newsubscr_""""
	. if cnt#2=0  do
	. . Set @("*XX=a("_key_")")
	. . If (XX'=cnt) Write !,"Invalid value for base XX var",!! ZShow "*" ZGoto $ZLevel-1
	. . If (XX(1)'=(cnt+1)) Write !,"Invalid value for XX(1)",!! ZShow "*" ZGoto $ZLevel-2
	. if cnt#2=1  do
	. . Set @("cnt1=a("_key_")")
	. . If cnt1'=cnt Write !,"Invalid value for a(key) var",!! ZShow "*" ZGoto $ZLevel-1
	Write "alslvgc: PASS",!
	Quit

	; test #26 - Test fix for C9K06-003279. When a merge overwrites an alias container, the reference counts
	;      	     are correct. This is for a local var source.
alscmrglv
	New
	Set x=42,x(1)=43,x(2)=44,*x(3)=z,z="42A"
	Set y=24,y(1)=25,y(2)=26,*y(3)=zz,zz="24A"
	Merge x=y
	If (x'=y)!(x(1)'=y(1))!(x(2)'=y(2)) Write "Unexpected values",!! ZShow "*" Quit
	If (1'=$ZData(x(3)))!(101'=$ZData(y(3))) Write "Unexpected container values",!! ZShow "*" Quit
	If (1'=$View("LV_REF","z"))!(0'=$View("LV_CREF","z")) Write "Incorrect reference values for z",!! ZShow "*" Quit
	If (2'=$View("LV_REF","zz"))!(1'=$View("LV_CREF","zz")) Write "Incorrect reference values for zz",!! ZShow "*" Quit
	Write "alscmrglv: PASS",!
	Quit

	; test #27 - Test fix for C9K06-003279. When a merge overwrites an alias container, the reference counts
	;      	     are correct. This is for a global var source.
alscmrggv
	New
	Set x=42,x(1)=43,x(2)=44,*x(3)=z,z="42A",zz="24A"
	Set ^y=24,^y(1)=25,^y(2)=26,^y(3)=zz
	Merge x=^y
	If (x'=^y)!(x(1)'=^y(1))!(x(2)'=^y(2)) Write "Unexpected values",!! ZShow "*" Quit
	If (1'=$ZData(x(3)))!(1'=$ZData(^y(3))) Write "Unexpected container values",!! ZShow "*" Quit
	If (1'=$View("LV_REF","z"))!(0'=$View("LV_CREF","z")) Write "Incorrect reference values for z",!! ZShow "*" Quit
	Kill ^y
	Write "alscmrggv: PASS",!
	Quit
