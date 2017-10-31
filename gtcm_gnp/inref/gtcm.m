;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtcm	; test GT.CM functionality
	; ^A is local
	zshow "G"
tset	; Test SET
	W "TESTING SET...",!
	f i=1:1:5 s ^A(i)=$j(i,i)
  	f i=1:1:5 s ^BLONGGLOBALVARIABLE(i)=$j(i,i)
	f i=1:1:5 s ^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",i)=$j(i,i)
  	f i=1:1:5 s ^BLONGGLO(i)=$j("G",i)
	f i=1:1:5 s ^CGLOBALVARIABLE(i)=$j(i,i)
	f i=1:1:5 s ^CGLOBALV(i)=$j("G",i)
	f i=1:1:5 s ^D(i)=$j(i,i)
	; basic check
	s fail=0
	F i=1:1:5  d
	. if ^A(i)'=^BLONGGLOBALVARIABLE(i) s fail=1
	. if ^A(i)'=^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",i) s fail=1
	. if ^A(i)'=^CGLOBALVARIABLE(i) s fail=1
	. if ^A(i)'=^D(i) s fail=1
	if fail w "SET FAILED",!,"===>^A(",i,")'=^BLONGGLOBALVARIABLE(",i,") (^A(",i,")=",^A(i),",^BLONGGLOBALVARIABLE(",i,")=",^BLONGGLOBALVARIABLE(i),")",!
	s str="abcd/._-"
	f i=1:1:8 s x=$E(str,i,i+1) s ^A(x)=x,^BLONGGLOBALVARIABLE(x)=x,^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",x)=x,^CGLOBALVARIABLE(x)=x,^D(x)=x
	s str="ABCD1234ZYXW"
	f i=1:1:8 s x=$E(str,i,i+1),y=$E(str,i+1,i+2) s ^A(x,y)=x,^BLONGGLOBALVARIABLE(x,y)=x,^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",x,y)=x,^CGLOBALVARIABLE(x,y)=x,^D(x,y)=x
	S ^A=5,^BLONGGLOBALVARIABLE=5,^CGLOBALVARIABLE=5,^D=5,^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript")=5
	ZWR ^A,^D
	new val
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	quit
tdata	; Test $DATA
	W !,"TESTING $DATA...",!
	W "$D(^A)=",$D(^A),"   $D(^D)=",$D(^D),!
	S DATASTR=""
	f ind="^A","^BLONGGLOBALVARIABLE","^CGLOBALVARIABLE","^D"  d
	. S DATASTR=DATASTR_$D(@ind)_","	; ^A
	. s ind2=ind_"(""AB"")"			; ^A("AB") = ("AB","BC")="AB"
	. S DATASTR=DATASTR_$D(@ind2)_","
	. s ind3=ind_"(""impossible"")"		; ^A("impossible") does not exist
	. S DATASTR=DATASTR_$D(@ind3)_","
	. s ind4=ind_"(2)"			; ^A(2) = " 2"
	. S DATASTR=DATASTR_$D(@ind4)_";"
	S DATASTR=DATASTR_$D(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript"))_","
	S DATASTR=DATASTR_$D(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript","AB"))_","
	S DATASTR=DATASTR_$D(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript","impossible"))_","
	S DATASTR=DATASTR_$D(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",2))_";"
	w "$DATA output of various elements of the arrays:",!,"(^, ^(""AB""), ^(""impossible""), ^(2) for each array)",!,DATASTR,!
	; check:
	S CMPSTR="11,10,0,1;11,10,0,1;11,10,0,1;11,10,0,1;11,10,0,1;"
	if DATASTR'=CMPSTR W "$DATA FAILED.",!,"===>",CMPSTR,"<== was expected.",! h
	s ab="AB"
	new val
	zshow "g":val	; use of lower-case 'g' is intentional to make sure that works as good as 'G'
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	q
tquery	; Test $QUERY and also that the globals are equal (in every item of the array)
	W !,"TESTING $QUERY..."
	do tquerydir(1)
	quit
trevquery; Test reverse $QUERY and also that the globals are equal (in every item of the array)
	W !,"TESTING Reverse $QUERY..."
	do tquerydir(-1)
	quit
tquerydir(dir)
	F gbl="^A","^D"  D
	. do tyqueryinit(.y,gbl,dir) F  do tyquery(.y,dir) Q:y=""  W !,y,"=",@y
	W !
	F gbl="^A","^BLONGGLOBALVARIABLE","^CGLOBALVARIABLE","^D"  D
	. do tyqueryinit(.y,gbl,dir) F  do tyquery(.y,dir) Q:y=""  S len=$L($P(y,"(",1))+1 S string(gbl,$E(y,len,50))=@y
	s gbl="^BWITHKEYLENGRTRTHANLOCAL"
	do tyqueryinit(.y,gbl,dir) F  do tyquery(.y,dir) Q:y=""  S len=$L($P(y,",",1))+2 S string(gbl,"("_$E(y,len,100))=@y
	; CHECK THE VALUES:
	; ^A is local, compare against that
	F gbl="^BLONGGLOBALVARIABLE","^CGLOBALVARIABLE","^D","BWITHKEYLENGRTRTHANLOCAL"  D
	. do tyqueryinit(.y,gbl,dir)
	. F  do tyquery(.y,dir) Q:y=""  d
	. . s cmp=""_gbl_""
	. . s len=$L($P(y,"(",1))+1
	. . s len1=$Select(gbl="^BWITHKEYLENGRTRTHANLOCAL":$L($P(y,",",1))+2,1:len)
	. . s ext=$E(y,len,50),ext1=$Select(gbl="^BWITHKEYLENGRTRTHANLOCAL":"("_$E(y,len1,100),1:ext)
	. . if string(cmp,ext1)'=string("^A",ext) d
	. . . s cmp1=string(cmp,ext),cmp2=string("^A",ext)
	. . . w "FAIL. Either SET or $QUERY FAILED. The different globals are:"
	. . . w cmp," and ^A:",!,"^A",ext,"=",cmp2," vs ",cmp,"(",ext,")=",cmp1,!
	. . . w "Check the actual values of the globals to determine what's wrong",!
	. . . h
	new val
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	q
tyqueryinit(y,gbl,dir)
	if dir=1  set y=gbl
	else      set y=gbl_"(""zzzz"")"	; start from maximum subscript for reverse $query
	quit
tyquery(y,dir);
	if dir=1 do
	. ; randomly use $query(gvn,1) vs $query(gvn) i.e. to test that both are equivalent
	. if $random(2) set y=$query(@y)
	. else  do
	. . if $random(2) set y=$query(@y,dir)
	. . else          set y=$query(@y,1)
	else  do
	. if $random(2) set y=$query(@y,dir)
	. else          set y=$query(@y,-1)
	quit
tget	; Test $GET
	W !,"TESTING $GET...",!
	F ind="1)","10000)","""AB"",""BC"")" d
	. F gbl="^A","^BLONGGLOBALVARIABLE","^CGLOBALVARIABLE","^D","^BWITHKEYLENGRTRTHANLOCAL" d
	. . s gblind=gbl_"("_ind if gbl="^BWITHKEYLENGRTRTHANLOCAL" s gblind=gbl_"(""withaverylongsubscript"","_ind
	. . W "$GET(",gblind,")=",$GET(@gblind,"NO VALUE"),!
	. . s string(gbl)=$GET(@gblind,"NO VALUE")
	. . if gbl'="^A"  d
	. . . if string(gbl)'=string("^A")  d
	. . . . w "$GET FAILED.",!,"$GET(",gblind,")'=$GET(^A",$E(gblind,3,50),") (",string(gbl)," vs ",string("^A"),")",!
	. . . . w "Check the values of the globals.",!
	. . . . h
	new val
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	;
	; Test for D9I10-002704 (test that repeated $get does NOT cause stringpool expansion)
	; If ever expansion occurs, an assert in expand_stp() will fail. Since stringpool starts off with a size of
	; less than 1Mb, it is enough to ensure the total data size of $gets across all iterations is > 1Mb. Just
	; to be safe, we ensure it is approximately 2Mb (10,000 iterations * 200 bytes). We dont want niters to be
	; too big either as it will significantly increase the test runtimes on the slower boxes.
	;
	set niters=10000,^BLONGGLOBALVARIABLE(niters)=$j(1,200),^CGLOBALVARIABLE(niters)=$j(1,200)
	for i=1:1:niters set val=$get(^BLONGGLOBALVARIABLE(niters)),val=$get(^CGLOBALVARIABLE(niters))
	kill ^BLONGGLOBALVARIABLE(niters),^CGLOBALVARIABLE(niters)
	quit
torder	; Test $ORDER
	W !,"TESTING $ORDER..."
	s astr="",bstr="",bwithgrtrkeylenstr="",cstr="",dstr=""
	w !,"^A: " s x="" F  s x=$O(^A(x)) Q:x=""  W x,", " s astr=astr_x
	w !,"^BLONGGLOBALVARIABLE: " s x="" F  s x=$O(^BLONGGLOBALVARIABLE(x)) Q:x=""  W x,", " s bstr=bstr_x
	w !,"^BWITHKEYLENGRTRTHANLOCAL: " s x="" F  s x=$O(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",x)) Q:x=""  W x,", " s bwithgrtrkeylenstr=bwithgrtrkeylenstr_x
	w !,"^CGLOBALVARIABLE: " s x="" F  s x=$O(^CGLOBALVARIABLE(x)) Q:x=""  W x,", " s cstr=cstr_x
	w !,"^D: " s x="" F  s x=$O(^D(x)) Q:x=""  W x,", " s dstr=dstr_x
	w !,"^A: " w $ORDER(^A)
	w !
	s TESTSTR="$ORDER" d CHEKORD
	do namelevelorder(1)	; forward name level $order
	new val
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val

trorder	; the other direction
	W !,"OTHER WAY ROUND..."
	s astr="",bstr="",bwithgrtrkeylenstr="",cstr="",dstr=""
	w !,"^A: " s x="" F  s x=$O(^A(x),-1) Q:x=""  W x,", " s astr=astr_x
	w !,"^BLONGGLOBALVARIABLE: " s x="" F  s x=$O(^BLONGGLOBALVARIABLE(x),-1) Q:x=""  W x,", " s bstr=bstr_x
	w !,"^BWITHKEYLENGRTRTHANLOCAL: " s x="" F  s x=$O(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",x),-1) Q:x=""  W x,", " s bwithgrtrkeylenstr=bwithgrtrkeylenstr_x
	w !,"^CGLOBALVARIABLE: " s x="" F  s x=$O(^CGLOBALVARIABLE(x),-1) Q:x=""  W x,", " s cstr=cstr_x
	w !,"^D: " s x="" F  s x=$O(^D(x),-1) Q:x=""  W x,", " s dstr=dstr_x
	w !,"^A: " w $ORDER(^A,-1)
	w !
	s TESTSTR="REVERSE $ORDER" d CHEKORD
	do namelevelorder(-1)	; backward name level $order
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	q

tzprev	; test $ZPREVIOUS
	W !,"TESTING $ZPREVIOUS..."
	s astr="",bstr="",bwithgrtrkeylenstr="",cstr="",dstr=""
	w !,"^A: " s x="" F  s x=$ZPREVIOUS(^A(x)) Q:x=""  W x,", " s astr=astr_x
	w !,"^BLONGGLOBALVARIABLE: " s x="" F  s x=$ZPREVIOUS(^BLONGGLOBALVARIABLE(x)) Q:x=""  W x,", " s bstr=bstr_x
	w !,"^BWITHKEYLENGRTRTHANLOCAL: " s x="" F  s x=$ZPREVIOUS(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",x)) Q:x=""  W x,", " s bwithgrtrkeylenstr=bwithgrtrkeylenstr_x
	w !,"^CGLOBALVARIABLE: " s x="" F  s x=$ZPREVIOUS(^D(x)) Q:x=""  W x,", " s cstr=cstr_x
	w !,"^D: " s x="" F  s x=$ZPREVIOUS(^D(x)) Q:x=""  W x,", " s dstr=dstr_x
	w !,"^A: " w $ZPREVIOUS(^A)
	w !
	s TESTSTR="$ZPREVIOUS" d CHEKORD
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	q

setpie	; set piece
	W !,"TESTING SET $PIECE...",!
	s ^A("piece")="a b c d e f g h i j k l"
	S ^BLONGGLOBALVARIABLE("piece")="a b c d e f g h i j k l"
	S ^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript","piece")="a b c d e f g h i j k l"
	s ^CGLOBALVARIABLE("piece")="a b c d e f g h i j k l"
	s ^D("piece")="a b c d e f g h i j k l"
	zwr ^A("piece"),^D("piece")
	W "set them piece by piece...",!,"^A(""piece"")=",!
	f i=1:1:9 s $P(^A("piece")," ",i)=i W ^A("piece"),!
	f i=1:1:9 s $P(^BLONGGLOBALVARIABLE("piece")," ",i)=i
	f i=1:1:9 s $P(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript","piece")," ",i)=i
	f i=1:1:9 s $P(^CGLOBALVARIABLE("piece")," ",i)=i
	w !,"^D(""piece"")=",!
	f i=1:1:9 s $P(^D("piece")," ",i)=i W ^D("piece"),!
	zwr ^A("piece"),^D("piece")
	S CMPSTR="1 2 3 4 5 6 7 8 9 j k l",TEST="SET $PIECE",ELEM="piece"
	d CHECK
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val

setpie1	; "of dif. lengths",!
	view "RESETGVSTATS"	; start afresh
	W "OF DIF. LENGTHS",!
	s ^A("piece")="a b c d e f g h i j k l"
	s ^BLONGGLOBALVARIABLE("piece")="a b c d e f g h i j k l"
	S ^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript","piece")="a b c d e f g h i j k l"
	s ^CGLOBALVARIABLE("piece")="a b c d e f g h i j k l"
	s ^D("piece")="a b c d e f g h i j k l"
	zwr ^A("piece"),^D("piece")
	W "^A(""piece"")=",!
	f i=1:1:4 S $P(^A("piece")," ",i,i+i)=i W ^A("piece"),!
	f i=1:1:4 S $P(^BLONGGLOBALVARIABLE("piece")," ",i,i+i)=i
	f i=1:1:4 S $P(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript","piece")," ",i,i+i)=i
	f i=1:1:4 S $P(^CGLOBALVARIABLE("piece")," ",i,i+i)=i
	W "^D(""piece"")=",!
	f i=1:1:4 S $P(^D("piece")," ",i,i+i)=i W ^D("piece"),!
	zwr ^A("piece"),^D("piece")
	S CMPSTR="1 2 3 4",TEST="SET $PIECE",ELEM="piece"
	D CHECK
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	q

textr	; Test set $extract
	W !,"TESTING SET $EXTRACT...",!
	s ^A("extract")="abcdefghijkl"
	s ^BLONGGLOBALVARIABLE("extract")="abcdefghijkl"
	s ^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript","extract")="abcdefghijkl"
	s ^CGLOBALVARIABLE("extract")="abcdefghijkl"
	s ^D("extract")="abcdefghijkl"
	zwr ^A("extract"),^D("extract")
	w "^A(""extract"")=",!
	f i=1:3:8 S $E(^A("extract"),i,i+3)=i_i+1_"." W ^A("extract"),!
	f i=1:3:8 S $E(^BLONGGLOBALVARIABLE("extract"),i,i+3)=i_i+1_"."
	f i=1:3:8 S $E(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript","extract"),i,i+3)=i_i+1_"."
	f i=1:3:8 S $E(^CGLOBALVARIABLE("extract"),i,i+3)=i_i+1_"."
	w "^D(""extract"")=",!
	f i=1:3:8 S $E(^D("extract"),i,i+3)=i_i+1_"." W ^D("extract"),!
	S CMPSTR="12.45.78.",TEST="SET $EXTRACT",ELEM="extract"
	D CHECK
	zwr ^A("extract"),^D("extract")
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	q

tkill	; Test KILL
	W !,"TESTING KILL...",!
	W "kill some...",!
	f i=1:1:10 K ^A(i)
	f i=1:1:10 K ^BLONGGLOBALVARIABLE(i)
	f i=1:1:10 K ^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",i)
	f i=1:1:10 K ^CGLOBALVARIABLE(i)
	f i=1:1:10 K ^D(i)
	W $D(^A),$D(^BLONGGLOBALVARIABLE),$D(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript")),$D(^CGLOBALVARIABLE),$D(^D),!
	W "then, kill all...",!
	K ^A,^BLONGGLOBALVARIABLE,^BWITHKEYLENGRTRTHANLOCAL,^CGLOBALVARIABLE,^D
	W "Any data left?:",$D(^A),$D(^BLONGGLOBALVARIABLE),$D(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript")),$D(^CGLOBALVARIABLE),$D(^D),!
	s total=$D(^A)+$D(^BLONGGLOBALVARIABLE)+$D(^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript"))+$D(^CGLOBALVARIABLE)+$D(^D)
	if total'=0 W "ERROR, Not all were KILLed! Check ^A, ^BLONGGLOBALVARIABLE, ^CGLOBALVARIABLE, and ^D.",!
	zshow "G":val
	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	zwrite val
	q

gvstats	;
	new reg,val
	set reg=$view("GVFIRST")
	; Test that cumulative statistics are ZERO or NON-ZERO depending on incoming <type>
	for  quit:reg=""  do
	.	set val("G",0)=$VIEW("GVSTATS",reg) ; need to use val("G",0) instead of just val to simulate ZSHOW "G" output format
	.	do out^zshowgfilter(.val,"DRD,DWT,DFL,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")	; filter out any that could contain varying output
	.	write "$VIEW(""GVSTATS"",",reg,")=",val("G",0),!
	.	set reg=$VIEW("GVNEXT",reg)
	quit

namelevelorder(dir)	;
	new x,i,fail,expect,actual,arrcnt,expectorder
	if dir=1 set x="^%"	; forward $order : start from earliest possible key
	else     set x="^zzzzz"	; reverse $order : start from latest possible key
	for i=1:1  set x=$order(@x,dir) q:x=""  set actual(i)=x
	set expectorder(1)="^A"
	set expectorder(2)="^BGLOBALFORREGB"
	set expectorder(3)="^BGLOBALFORREGIONB"
	set expectorder(4)="^BGLOBALFORREGIONC"
	set expectorder(5)="^BGLOBALFORREGIOND"
	set expectorder(6)="^BLONGGLO"
	set expectorder(7)="^BLONGGLOBALVARIABLE"
	set expectorder(8)="^BWITHKEYLENGRTRTHANLOCAL"
	set expectorder(9)="^CGLOBALFORREGC"
	set expectorder(10)="^CGLOBALFORREGIONC"
	set expectorder(11)="^CGLOBALV"
	set expectorder(12)="^CGLOBALVARIABLE"
	set expectorder(13)="^Cmecorrectthere"
	set expectorder(14)="^D"
	set expectorder(15)="^DGLOBALFORREGD"
	set expectorder(16)="^DGLOBALFORREGIOND"
	set expectorder(17)="^DingomeDingo"
	set expectorder(18)="^Dothings"
	set expectorder(19)="^Dothingsrightthefirsttime"
	set expectorder(20)="^ZGLOBALFORREGDEFAULT"
	set expectorder(21)="^ZGLOBALFORREGIONDEFAULT"
	set expectorder(22)="^adoes"
	set expectorder(23)="^aforappl"
	set expectorder(24)="^aforapplecomputers"
	set expectorder(25)="^aillruntoolongtobecalledalongna"
	set expectorder(26)="^begintochecklongname31chartrunc"
	set expectorder(27)="^beherest"
	set expectorder(28)="^beherestaylongtocheck"
	set expectorder(29)="^bthis"
	set expectorder(30)="^cfly"
	set expectorder(31)="^cmecorrecthere"
	set expectorder(32)="^cmecorrecthereagainonemoretime"
	set expectorder(33)="^dat"
	set expectorder(34)="^zall"
	set expectorder(35)="^zeelongmelongmelongme"
	set expectorder(36)="^zeezeete"
	set expectorder(37)="^zeezeetelevision"
	set arrcnt=37
	if dir=1  for i=1:1:arrcnt set expect(i)=expectorder(i)
	else      for i=1:1:arrcnt set expect(i)=expectorder(arrcnt+1-i)
	set fail=0
	for i=1:1:arrcnt  do
	.	if actual(i)'=expect(i)  write "TEST-E-NAMELEVELORDER : Failed in namelevel $ORDER actual(",i,")",! set fail=1
	if $data(actual(arrcnt+1))'=0  write "TEST-E-NAMELEVELORDER : Failed in name-level $ORDER actual(arrcnt+1)",!  set fail=1
	if fail=1 zshow "*"
	quit

CHECK	; check that ^A,^BLONGGLOBALVARIABLE,^CGLOBALVARIABLE,^D are the same
	n fail
	s fail=0
	if ^A(ELEM)'=CMPSTR s fail=1
	if ^BLONGGLOBALVARIABLE(ELEM)'=CMPSTR s fail=1
	if ^BWITHKEYLENGRTRTHANLOCAL("withaverylongsubscript",ELEM)'=CMPSTR s fail=1
	if ^CGLOBALVARIABLE(ELEM)'=CMPSTR s fail=1
	if ^D(ELEM)'=CMPSTR s fail=1
	if fail w TEST," FAILED. One (or more) of ^A,^BLONGGLOBALVARIABLE,^CGLOBALVARIABLE,^D(""",ELEM,""") is/are not as expected.",!,"Expected: """,CMPSTR,"""",! ZWR ^A(ELEM),^BLONGGLOBALVARIABLE(ELEM),^CGLOBALVARIABLE(ELEM),^D(ELEM) H
	q
CHEKORD	; Check $ORDER and $ZPREVIOUS
	s fail=0
	if astr'=bstr s fail=1
	if astr'=cstr s fail=2
	if astr'=dstr s fail=3
	if astr'=bwithgrtrkeylenstr s fail=4
	if fail w TESTSTR,"  FAILED. ^A and ^BLONGGLOBALVARIABLE,^CGLOBALVARIABLE, or ^D do not match in order (",fail,"):",! w astr,!,bstr,!,cstr,!,dstr,!,bwithgrtrkeylenstr,! H
	q
