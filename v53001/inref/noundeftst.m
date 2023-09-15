;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
noundeftst	; test for noundef operation with local variables
	;
	N (act,cmdline)
	I '$D(act) N act S act="W ! ZSH ""*""" ; "B"=$E(act) causes the NOUNDEF Mode to emulate success
	S zcmdline=$S($D(cmdline):cmdline,1:$ZCMDLINE) N cmdline
	S nound("errors")=$select(""'=$ztrnlnm("ydb_noundef"):$ztrnlnm("ydb_noundef"),1:$ztrnlnm("gtm_noundef"))
	I $ZVER'["VMS",$L(nound("errors")) D
	. I ";YES;TRUE"[(";"_nound("errors"))!nound("errors") S nound("errors")=1=$V("UNDEF")
	. E  S nound("errors")=0=$V("UNDEF")
	. I nound("errors") W !,"Test not responding to ydb_noundef/gtm_noundef environment variable"
	E  I $L(zcmdline) V $S(";YES;TRUE"[(";"_$P(zcmdline," "))!zcmdline:"NOUNDEF",1:"UNDEF")
	E  V "NOUNDEF"
	S nound("gen")=zcmdline["GEN"
	K zcmdline
	V "NOLVNULLSUBS" ; make sure we get detect these
	N $ET,$ES S $EC="",nound("ret")=($ZL+1)_":ret^noundeftst",$ET="D err^noundeftst"
	;
	I nound("gen") D
	. N genfile S genfile="noundefgen.m"
	. O genfile:(NEWVERSION:EXCEPTION="ZG "_$ZL_":badfile") U genfile
	. F nound("test")=0:1 S nound("case")=$T(@$S($ZVER["VMS":"casevms",1:"casetab")+nound("test")) Q:""=nound("case")  D
	.. I "BREAK"=$E(act,1,5)!("skip;skip"'=$P(nound("case"),";",5,6)) W nound("test")," ",$P(nound("case"),";",2),!," Q",!
	. C genfile
	. ZCOMPILE genfile
	. I 1'=$ZCSTATUS,$I(nound("errors")) W !,"Wrong compile status: ",$ZCSTATUS
	. Q
badfile	. B
	F nound("test")=0:1 S nound("case")=$T(@$S($ZVER["VMS":"casevms",1:"casetab")+nound("test")) Q:""=nound("case")  D
	. S nound("ocnt")=$P(nound("case"),";",3),nound("varlst")=$P(nound("case"),";",4)
	. S nound("ee")=$P(nound("case"),";",$S($V("UNDEF"):6,1:5))
	. I $ZVER["VMS" D
	.. S nound("temp")=$P(nound("case"),";",$S($V("UNDEF"):8,1:7))
	.. I $L(nound("temp")) S nound("ee")=nound("temp"),nound("ocnt")=0
	. S nound("case")=$P(nound("case"),";",2),$ZS=""
	. I "M"=$ZCHSET,nound("case")["$ZCO" Q
	. I $L(nound("ee")) S:"skip"=nound("ee")&("BREAK"=$E(act,1,5)) nound("ee")=""  Q:"skip"=nound("ee")
	. E  S nound("ee")=$S($V("UNDEF"):"UNDEF",1:"VAREXPECTED")
	. I $V("UNDEF") S @($NA(nound("ocnt"))_"="_nound("ocnt"))
	. I $I(nound("real"))
	. N (act,nound)
try	. X $S(nound("gen"):"N act D "_nound("test")_"^noundefgen",1:nound("case"))
ret	. D chk(nound("ocnt"),nound("varlst"))
	. I '$D(nound("test")),$I(nound("test"))
	W !,$S($I(nound("errors"),0):nound("errors")_" FAIL(s)",1:"PASS")," from ",nound("real")," cases in ",$T(+0)
	W " in ","operating in ",$S($V("UNDEF"):"UNDEF",1:"NOUNDEF")," mode",!
	Q
chk(cnt,var)
	W !,"Test case: ",nound("case")
	K ^noundef
	S nound("cnt")=0,cnt=cnt+4 ; act + cnt + nound + var
	I $L(var) F nound("imyqi")=1:1:$L(var,",") I $D(@$P(var,",",nound("imyqi")))'[0,$S("B"=$E(act):$I(nound("cnt")),1:$I(nound("errors"))) D
	. I "B"=$E(act) N t S t=$P(var,",",nound("imyqi")) W:"k"'=t !,"************** ",t Q
	. W !,"*** test case predicted ",$P(var,",",nound("imyqi"))," would be undefined, but $Data reports it has data"
	ZSH "V":^noundef
	S nound("save")=""
	F nound("imyqi")=1:1 Q:'$D(^noundef("V",nound("imyqi")))  D
	. I $O(^noundef("V",""),-1)<nound("imyqi") W !,"##### BAD $DATA()" H
	. S nound("temp")=$P($P(^noundef("V",nound("imyqi")),"=",1),"(",1)
	. I "B"'=$E(act),nound("save")'=nound("temp"),$I(nound("cnt")) S nound("save")=nound("temp")
	I "B"'=$E(act),cnt'=nound("cnt"),$I(nound("errors")) D
	. W !,"**** Expected ",cnt-4," test case locals, but ZSH/ZWR found ",nound("cnt")-4;,! ZWR ^noundef("V",*)
	S nound("imyqi")=cnt-4,nound("nam")="%"
	F cnt=cnt+$S("B"=$E(act):nound("cnt"),1:0)-$S($D(%):1,1:0):-1 S nound("nam")=$O(@nound("nam")) Q:""=nound("nam")
	I cnt,$I(nound("errors")) D
	. W !,"***** Expected ",nound("imyqi")," test case locals, but name-level $O() found ",nound("imyqi")-cnt;,! ZWR
	Q
err	I '$D(act) Q ; get ourselves reinvoked down a frame after we get act back.
	I $P'=$I C $I:delete
	I $S(nound("gen"):nound("test"),1:"try")=$P($P($ZSTATUS,"^"),",",2)!$D(oops) D
	. S $EC=""
	. K oops
	. I $ZS'[nound("ee"),$I(nound("errors")) D  X act
	.. W !,"Test case: ",nound("case"),!,"****** Expected error: ",nound("ee")," but got:",!,$ZS
	I  ZG @nound("ret")
	W !,"****** Unexpected error location",! X act
	B
	Q
	;
dummy	;
	Q
dummy1(a,b)
	Q:$Q b Q
dummy2(a,b)
	S oops=1
	Q k
	; The casetab has the following format
	; cnt;varlst;ee (noundef);ee (undef) WHERE
	; cnt is the # of lvns defined by the (passing) case
	; varlst is a comma delimited list of lvns NOT be defined by (passing) case
	; ee is the expected error for the (passing) case - defaults to VAREXPECTED and UNDEF respectively for no and undef
	; when ee is "skip" the test skips the case unless act="BREAK"
	; where you find usages like 1-1 => in NOUNDEF case use +"1-1" i.e. 1 (take first part), and in UNDEF case use 1-1 i.e. 0
casetab	;S $ZE(j,k,k+1)=k;1-1;k
	;S $ZE(j,@k)=k;0;k
	;S $ZE(k,k,@k)=k;0;k
	;S $ZPI(j,k,k,k+1)=k;1-1;k
	;S $ZPI(j,@k)=k;0;k
	;S $ZPI(j,k,@k)=k;0;k
	;S $ZPI(j,k,k,@k)=k;0;k
	;S j=$ZA(k,k);1-1;k
	;S j=$ZA(@k);0;j,k
	;S j=$ZA(k,@k);0;j,k
	;B:k k;0;k
	;S j=$ZCH(k);1-1;k
	;S j=$ZCH(@k);0;j,k
	;S j=$ZCO(k,k,k);0;k;INVZCONVERT
	;S j=$ZCO(@k,k);0;j,k
	;S j=$ZCO(k,@k);0;j,k
	;S j=$ZCO(k,k,@k);0;j,k
	;S j=$ZE(k,k,k+1);1-1;k
	;S j=$ZE(@k);0;j,k
	;S j=$ZE(k,@k,@k);0;j,k
	;S j=$ZF(k,k,k);1-1;k
	;S j=$ZF(@k,k);0;j,k
	;S j=$ZF(k,@k);0;j,k
	;S j=$ZJ(k,k);1-1;k
	;S j=$ZJ(k,k,k);1-1;k
	;S j=$ZJ(@k,k);0;j,k
	;S j=$ZJ(k,@k);0;j,k
	;S j=$ZJ(k,k,@k);0;j,k
	;S j=$ZL(k);1-1;k
	;S j=$ZL(k,k);1-1;k
	;S j=$ZL(@k);0;j,k
	;S j=$ZL(k,@k);0;j,k
	;S j=$ZPI(k,k);1-1;k
	;S j=$ZPI(k,k,k);1-1;k
	;S j=$ZPI(k,k,k,k);1-1;k
	;S j=$ZPI(@k,k);0;j,k
	;S j=$ZPI(k,@k);0;j,k
	;S j=$ZPI(k,k,@k);0;j,k
	;S j=$ZPI(k,k,k,@k);0;j,k
	;S j=$ZSUB(k,k,k);1-1;k
	;S j=$ZSUB(@k,k);0;k
	;S j=$ZSUB(k,k,@k);0;k
	;S j=$ZTR(k,k,k);1-1;k
	;S j=$ZTR(@k,k);0;j,k
	;S j=$ZTR(k,@k);0;j,k
	;S j=$ZTR(k,k,@k);0;j,k
	;S j=$ZW(k);1-1;k
	;S j=$ZW(@k);0;j,k
casevms	;C k;0;k
	;C "foo":rename=k;0;k
	;C @k;0;k;EXPR
	;D dummy+k^noundeftst;0;k
	;D dummy1^noundeftst(k);0;k
	;D @k;0;k;LABELEXPECTED
	;D ^@k;0;k;ZLINKFILE
	;F j=k:1:2;1-1;k
	;F j=1:1:k;1-1;k
	;F j=1:k:1 q;1-1;k
	;F j=k,l;1-1;k,l
	;G ick+k;0;k;LABELMISSING
	;G @k;0;k;LABELEXPECTED
	;G ^@k;0;k;ZLINKFILE;;;;don't much like this error - seems it should not get this far with no routinename
	;H k;0;k
	;H @k;0;k;EXPR
	;I k=k;0;k
	;I k'=k;0;k
	;I k=+k;0;k
	;I k'=+k;0;k
	;I k>k;0;k
	;I k'>k;0;k
	;I k'<k;0;k
	;I k'<k;0;k
	;I k&k;0;k
	;I k!k;0;k
	;I k[k;0;k
	;I k'[k;0;k
	;I k]k;0;k
	;I k']k;0;k
	;I k]]k;0;k
	;I k']]k;0;k
	;I k?.e;0;k
	;I k?@k;0;k;PATCODE
	;I ""=k;0;k
	;I ""'=k;0;k
	;I @k;0;k;EXPR
	;J dummy+k^noundeftst;0;k;;;JOBFAIL;
	;J dummy1^noundeftst(k);0;k;;;JOBFAIL;
	;J @k;0;k;LABELEXPECTED;;;;
	;J ^@k;0;k;JOBFAIL;;;;;
	;J dummy+@k^noundeftst;0;k;;;;
	;K j(k);0;k
	;K (act,k,nound);0;k
	;N  K @k;0;k;;;;;;
	;L j(k):k L;0;j,k
	;L @k;0;k;LKNAMEXPECTED
	;M j=k;0;j,k
	;M @k;0;k
	;N k;0;k
	;N (act,k,nound);0;k
	;N @k;0;k
	;O k C k:delete;0;k
	;O "foo":(exception=k:extension=k):k C "foo":delete;0;k
	;O "foo"::k C "foo":delete;0;k
	;O @k;0;k;EXPR
	;R j:k;1-1;k;IOEOF
	;R *j:k;1-1;k;IOEOF;;;; If run from a terminal with noundef, this produces 1 more variable than "expected"
	;R j#k:k;0;j,k;RDFLTOOSHORT
	;TS k:TRANSACTIONID=k TRO:$TR  S:$TL ^noundef=k TRE:$TL;0;k
	;TS (k) S ^noundef=k TC;0;k
	;S j=k;1-1;k
	;S j=+k;1-1;k
	;S j=-k;1-1;k
	;S j=k+k;1-1;k
	;S j=k-k;1-1;k
	;S j=k*k;1-1;k
	;S j=k**k;1-1;k
	;S j=k/k;0;j,k;DIVZERO
	;S j=k\k;0;j,k;DIVZERO
	;S j=k#k;0;j,k;DIVZERO
	;S j(k)=l;0;j,k,l;LVNULLSUBS
	;S ^k(k)=k;0;k;NULSUBSC
	;S j=$$dummy2^noundeftst(1);2-2;k
	;S j="k",l=j_@j;2-1;k
	;S j=@k;0;j,k
	;S @k;0;k
	;S $E(j,k,k+1)=k;1-1;k
	;S $E(j,@k)=k;0;k
	;S $E(k,k,@k)=k;0;k
	;S $P(j,k,k,k+1)=k;1-1;k
	;S $P(j,@k)=k;0;k
	;S $P(j,k,@k)=k;0;k
	;S $P(j,k,k,@k)=k;0;k
	;U $P:(length=k:length=24:exception=k);0;k
	;U @k;0;k;EXPR
	;V k;0;k;VIEWNOTFOUND
	;V @k;0;k;EXPR
	;W k;0;k
	;W ?k;0;k
	;W *k;0;k
	;W @k;0;k;EXPR
	;X k;0;k
	;X @k;0;k;EXPR
	;ZA j(k):k L;0;j,k
	;ZA @k;0;k;LKNAMEXPECTED
	;ZCOM k;0;k;FNF
	;ZCOM @k;0;k
	;ZD j(k),@k;0;j,k;LKNAMEXPECTED
	;ZG k:ick+k;0;k;LABELMISSING
	;ZG @k;0;k;skip
	;ZG @k:ick;0;k
	;ZG $ZL:@k;0;k;skip
	;ZG $ZL:^@k;0;k;RTNNAME
	;ZK j(k);0;j,k
	;ZK @k;0;k
	;ZL k;0;k;ZLINKFILE
	;ZL @k;0;k;ZLINKFILE
	;ZM k;0;k;UNKNOWN;;skip;skip
	;ZM @k;0;k;skip;skip;;; GTMASSERT with either mode @ /usr/library/V990/src/emit_code.c line 837 (at least in Linux)
	;ZP k;0;k;ZPRTLABNOTFND;ZPRTLABNOTFND;;; as a debugging tool, it tries it as a label as well as a variable
	;O "tmp":newv U "tmp" ZP @k C "tmp":delete;0;k
	;ZSH k;0;k
	;O "tmp":newv U "tmp" ZSH @k C "tmp":delete;0;k
	;ZSY $S($ZVER["VMS":"log/brief",1:"exit")_k;0;k
	;ZWI j(k);0;k
	;ZWI @k;0;k
	;ZWR k;0;k;UNDEF
	;S j=$A(k,k);1-1;k
	;S j=$A(@k);0;j,k
	;S j=$A(k,@k);0;j,k
	;S j=$C(k);1-1;k
	;S j=$C(@k);0;j,k
	;S j=$D(k);1;k
	;S j=$D(@k);0;j,k
	;S j=$E(k,k,k+1);1-1;k
	;S j=$E(@k);0;j,k
	;S j=$E(k,@k,@k);0;j,k
	;S j=$F(k,k,k);1-1;k
	;S j=$F(@k,k);0;j,k
	;S j=$F(k,@k);0;j,k
	;S j=$FN(k,k,k);1-1;k
	;S j=$FN(@k,k,k);0;j,k
	;S j=$FN(k,@k,k);0;j,k
	;S j=$FN(k,k,@k);0;j,k
	;S j=$G(k,k);1-1;k
	;S j=$G(@k);0;j,k
	;S j=$G(k,@k);0;j,k
	;S j=$I(k,k);2-2;
	;S j=$I(@k);0;j,k
	;S j=$I(k,@k);0;j,k
	;S j=$J(k,k);1-1;k
	;S j=$J(k,k,k);1-1;k
	;S j=$J(@k,k);0;j,k
	;S j=$J(k,@k);0;j,k
	;S j=$J(k,k,@k);0;j,k
	;S j=$L(k);1-1;k
	;S j=$L(k,k);1-1;k
	;S j=$L(@k);0;j,k
	;S j=$L(k,@k);0;j,k
	;S j=$NA(k,k);1-1;k
	;S j=$NA(@k);0;j,k
	;S j=$NA(k,@k);0;j,k
	;S j=$N(k(k));1;k,l
	;S j=$N(@k);0;j,k
	;S j=$O(l(k));1;k,l
	;S j=$O(l(""),k);0;j,k,l;ORDER2
	;S j=$O(@k);0;j,k
	;S j=$O(k(""),@k);0;j,k
	;S j=$P(k,k);1-1;k
	;S j=$P(k,k,k);1-1;k
	;S j=$P(k,k,k,k);1-1;k
	;S j=$P(@k,k);0;j,k
	;S j=$P(k,@k);0;j,k
	;S j=$P(k,k,@k);0;j,k
	;S j=$P(k,k,k,@k);0;j,k
	;S j=$Q(k(l));1;k,l
	;S j=$Q(@k);0;j,k
	;S j=$QL(k);0;j,k;NOCANONICNAME
	;S j=$QL(@k);0;j,k
	;S j=$QS(k,k);0;j,k;NOCANONICNAME
	;S j=$QS("k",k);1-1;k
	;S j=$QS(@k,k);0;j,k
	;S j=$QS("k",@k);0;j,k
	;S j=$R(k);0;j,k;RANDARGNEG
	;S j=$R(@k);0;j,k
	;S j=$RE(k);1-1;k
	;S j=$RE(@k);0;j,k
	;S j=$S(k:k,1:0);1-1;k
	;S j=$S(@k:k,1:0);0;j,k
	;S j=$S(k:k,1:@k);0;j,k
	;S j=$ST(k);1-1;k
	;S j=$ST(k,k);0;j,k;INVSTACODE
	;S j=$ST(@k);0;j,k
	;S j=$ST(k,@k);0;j,k
	;S j=$T(k+k^k);1-1;k
	;S j=$T(@k+k^k);1-1;k
	;S j=$T(k+@k^k);0;j,k
	;S j=$T(k+k^@k);0;j,k;RTNNAME
	;S j=$T(@k+@k^k);0;k
	;S j=$T(k+@k^@k);0;j,k
	;S j=$T(@k+k^@k);0;j,k;RTNNAME
	;S j=$T(@k+@k);0;k
	;S j=$T(+@k^@k);0;j,k
	;S j=$T(@k^@k);0;j,k;RTNNAME
	;S j=$T(@k);0;j,k;TEXTARG
	;S j=$TR(k,k,k);1-1;k
	;S j=$TR(@k,k);0;j,k
	;S j=$TR(k,@k);0;j,k
	;S j=$TR(k,k,@k);0;j,k
	;S j=$V(k);0;j,k;VIEWNOTFOUND
	;S j=$V(@k);0;j,k
	;S j=$ZBITAND(k,k);0;j,k;INVBITSTR
	;S j=$ZBITAND(@k,k);0;j,k
	;S j=$ZBITAND(k,@k);0;j,k
	;S j=$ZBITCOUNT(k);0;j,k;INVBITSTR
	;S j=$ZBITCOUNT(@k);0;j,k
	;S j=$ZBITFIND(k,k,k);0;j,k;INVBITSTR
	;S j=$ZBITFIND(@k,k,k);0;j,k
	;S j=$ZBITFIND(k,@k,k);0;j,k
	;S j=$ZBITFIND(k,k,@k);0;j,k
	;S j=$ZBITGET(k,k);0;j,k;INVBITSTR
	;S j=$ZBITGET(@k,k);0;j,k
	;S j=$ZBITGET(k,@k);0;j,k
	;S j=$ZBITLEN(k);0;j,k;INVBITSTR
	;S j=$ZBITLEN(@k);0;j,k
	;S j=$ZBITNOT(k);0;j,k;INVBITSTR
	;S j=$ZBITNOT(@k);0;j,k
	;S j=$ZBITOR(k,k);0;j,k;INVBITSTR
	;S j=$ZBITOR(@k,k);0;j,k
	;S j=$ZBITOR(k,@k);0;j,k
	;S j=$ZBITSET(k,k,k);0;j,k;INVBITSTR
	;S j=$ZBITSET(@k,k,k);0;j,k
	;S j=$ZBITSET(k,@k,k);0;j,k
	;S j=$ZBITSET(k,k,@k);0;j,k
	;S j=$ZBITSTR(k,k);0;j,k;INVBITLEN
	;S j=$ZBITSTR(@k,k);0;j,k
	;S j=$ZBITSTR(k,@k);0;j,k
	;S j=$ZBITXOR(k,k);0;j,k;INVBITSTR
	;S j=$ZBITXOR(@k,k);0;j,k
	;S j=$ZBITXOR(k,@k);0;j,k
	;S j=$ZD(k);1-1;k
	;S j=$ZD(@k);0;j,k
	;S j=$ZJOBEXAM(k);1-1;k;
	;S j=$ZJOBEXAM(@k);0;j,k;
	;S j=$ZM(k);1-1;k
	;S j=$ZM(@k);0;k,l
	;S j=$ZP(k(l));1;k,l
	;S j=$ZP(@k);0;j,k
	;S j=$ZPARSE(k,k,k,k,k);1-1;k
	;S j=$ZPARSE(@k,k,k,k,k);0;j,k
	;S j=$ZPARSE(k,@k,k,k,k);0;j,k
	;S j=$ZPARSE(k,k,@k,k,k);0;j,k
	;S j=$ZPARSE(k,k,k,@k,k);0;j,k
	;S j=$ZPARSE(k,k,k,k,@k);0;j,k
	;S j=$ZQGBLMOD(^noundef(k));0;j,k;NULSUBSC
	;S j=$ZQGBLMOD(@k);0;j,k
	;S j=$ZSEARCH(k,k);1-1;k;;;ESL;;
	;S j=$ZSEARCH(@k);0;j,k
	;S j=$ZSEARCH(k,@k);0;j,k;;;
	;S j=$ZTRNLNM(k);1-1;k;;;IVLOGNAM;;
	;S j=$ZTRNLNM(@k);0;k;;;
	;S j=$ZWRITE(k);1-1;k
