;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YDB#1278 : indirection whose source string names a local variable with simple subscripts is
; located without compiling the string.
;
; Each check compares an indirection through @ref with the same indirection through @(ref_" "). The
; trailing space makes the second string one the fast path does not accept, while the compiler
; ignores trailing spaces, so the second always gives what the compiled indirect code gives. The two
; must agree, value or error, for every string, whichever path the first takes.
;
; Each stage is run in its own process by indir_fast_lvn-ydb1278.csh.
;
ydb1278	;
	write "Run one label at a time. See indir_fast_lvn-ydb1278.csh",!
	quit
	;
reads	; $DATA, $ZDATA, $GET, $ORDER, value fetch and $NAME on reference strings of many shapes
	new qrefs,qi,qk
	do init
	set qrefs="x|x(1)|x(1,2)|x(-1)|x(.5)|x(""a"")|x(""a"",""b"")|x("""")|x(""5x"")|x(""q""""q"")|x(1.5)|x(2)|x(2,""z"")"
	set qrefs=qrefs_"|x(""ab"",3,""c"")|%p(""%"")|x(y)|x(n)|x(d)|x(neg)|x(s)|x(y,""b"")|x(e)|x(undefvar)|x(yy)|x(big)"
	set qrefs=qrefs_"|x(str5)|x(mix)|x(01)|x(1.0)|x(""1.0"")|x(-0)|x(1E0)|x(12345678901234567890)|nosuch|nosuch(1)"
	set qrefs=qrefs_"|nosuch(y)|x(1,)|x(,1)|x(1|x(1))|x( 1)|x(""a"" )|x(""a|x(1)x|al(1)|al(""a"",""b"")|X(1)|x(ctl)|x(""a""_1)"
	set qrefs=qrefs_"|x(1+1)|x(@y)|x(-)|x(.)|x(-.5)|x(1.)|x(y(1))|x(%p)|abcdefghijklmnopqrstuvwxyz12345678(1)"
	set qrefs=qrefs_"|x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28)"
	set qrefs=qrefs_"|x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29)"
	set qrefs=qrefs_"|x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)"
	set qrefs=qrefs_"|x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)"
	set (qbad,qcnt)=0
	for qi=1:1:$length(qrefs,"|") for qk="$data(@R)","$zdata(@R)","$get(@R)","$get(@R,""dflt"")","$order(@R)","$order(@R,-1)","@R","$name(@R)","$name(@R,0)","$name(@R,1)","$name(@R,2)" do cmp(qk,$piece(qrefs,"|",qi))
	do verdict("reads")
	quit
	;
saves	; SET, multiple SET, SET $PIECE and $EXTRACT, FOR, MERGE, KILL and $INCREMENT with an indirect target
	new qcmds,qc,qi,qr,qa,qb
	set qcmds="set @R=9|set (@R,y2)=5|set $piece(@R,""^"",2)=""p""|set $extract(@R,2)=""E""|set z=$order(@R,1)"
	set qcmds=qcmds_"|set z=$get(@R,""d"")|merge @R=x(""a"")|merge z=@R|for @R=1:1:3 set z=$get(z)_@R|set z=$increment(@R)"
	set qcmds=qcmds_"|set i=1,@R=$$inci()|kill @R"
	set (qbad,qcnt)=0
	for qi=1:1:$length(qcmds,"|") set qc=$piece(qcmds,"|",qi) do
	. for qr="x(9)","x(n,n)","x(y,""c"")","newv(1)","x","x(undefvar)","x(e,1)","x(i,""ev"")" do
	. . kill qa,qb
	. . do init,run(qc,qr) do snap(.qa)
	. . do init,run(qc,qr_" ") do snap(.qb)
	. . set qcnt=qcnt+1
	. . if $$same(.qa,.qb) quit
	. . set qbad=qbad+1 write "WRONG : ",qc," with R=",qr," leaves different variables than compiled",! zwrite qa,qb
	do verdict("saves")
	quit
	;
names	; name indirection @r@(subs), compared with the compiled form of the text op_indname composes
	new qtgts,qsubs,qt,qs,qk
	do init
	set qtgts="x|x(1)|x(""a"")|x(""a"",""b"")|nosuch|al|%p|x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30)"
	set qsubs="1|n|s|e|""q""""q""|ctl|big|neg|d|5|""5""|""1.0""|mix|n,2|n,n+1|y,""b""|i,$$inci(),i|@""y""|$$side()|31,32"
	set (qbad,qcnt)=0
	for qt=1:1:$length(qtgts,"|") for qs=1:1:$length(qsubs,"|") do
	. for qk="$data(@r@(S))","$get(@r@(S))","$order(@r@(S))","@r@(S)","$name(@r@(S))","$name(@r@(S),1)" do
	. . do ncmp(qk,$piece(qtgts,"|",qt),$piece(qsubs,"|",qs))
	do verdict("names")
	quit
	;
random	; randomly generated reference strings, valid and not, many sharing a prefix with the one before
	new qi,qr,qbase,qprev,qk
	set qseed=+$zcmdline set:'qseed qseed=1278
	do init
	set (qbad,qcnt)=0
	for qi=1:1:5000 do
	. if (qi#5)=1 set qbase=$$rname
	. set qr=qbase_$$rsubs
	. if $data(qprev),qprev?1.e1"("1.e1")",$$rnd(3)=0 set qr=$piece(qprev,",",1,$length(qprev,",")-1)_$select($length(qprev,",")>1:",",1:$piece(qprev,"(",1)_"(")_$$rsub_")"
	. else  if $data(qprev),qprev?1.e1")",$$rnd(3)=0 set qr=$extract(qprev,1,$length(qprev)-1)_","_$$rsub_")"
	. set qprev=qr
	. for qk="$data(@R)","$get(@R)","$order(@R)","@R","$name(@R)","$name(@R,1)","$order(@R,-1)" do cmp(qk,qr)
	do verdict("random")
	quit
	;
lits	; string literals from unique indirect compilations must survive cache eviction and garbage collection
	new qi,qn,x,y,w
	set qn=20000,qbad=0
	for qi=1:1:qn do
	. set @("x("_qi_")=""lit"_qi_"""_$char(65)")
	. set y(qi)=$get(@("z(""s"_qi_""")"),"dflt"_qi)
	. xecute "set w("_qi_")=""xl"_qi_""""
	. if 0=(qi#1000) view "STP_GCOL"
	view "STP_GCOL"
	for qi=1:1:qn do
	. if x(qi)'=("lit"_qi_"A") set qbad=qbad+1 write:qbad<10 "WRONG : x(",qi,")=",x(qi),", expected lit",qi,"A",!
	. if y(qi)'=("dflt"_qi) set qbad=qbad+1 write:qbad<10 "WRONG : y(",qi,")=",y(qi),", expected dflt",qi,!
	. if w(qi)'=("xl"_qi) set qbad=qbad+1 write:qbad<10 "WRONG : w(",qi,")=",w(qi),", expected xl",qi,!
	write $select(qbad:"FAIL : "_qbad_" values are wrong",1:"PASS : all "_(3*qn)_" values hold what was assigned"),!
	quit
	;
cost	; a new reference string on every call costs less than 5 times a repeated one
	new x,qi,qref,qt,qd,qn,qr,qs,qu,qsame,quniq
	set qn=100000
	for qi=1:1:qn set x("a",qi,"b")=qi
	; 3 alternating rounds, comparing the fastest of each, so that a pause in one round cannot fail the stage
	for qr=1:1:3 do
	. set qref="x(""a"",1)",qt=$zut for qi=1:1:qn set qd=$data(@qref@("b"))
	. set qs=$zut-qt
	. set qt=$zut for qi=1:1:qn set qref=$name(x("a",qi)),qd=$data(@qref@("b"))
	. set qu=$zut-qt
	. if qr=1 set qsame=qs,quniq=qu
	. else  set:qs<qsame qsame=qs set:qu<quniq quniq=qu
	if quniq<(5*qsame) write "PASS : a new reference string on every call costs less than 5 times a repeated one",!
	else  write "FAIL : a new reference string on every call costs ",quniq\qsame," times a repeated one (",quniq," against ",qsame," microseconds, fastest of 3 rounds), expected less than 5",!
	quit
	;
grow	; with a large local array, garbage collections grow the stringpool rather than walk the array every few KiB
	new x,qi,qref,qd,qn,qsp
	set qn=200000
	for qi=1:1:qn set x("a",qi,"b")=qi
	for qi=1:1:qn set qref=$name(x("a",qi)),qd=$data(@qref@("b"))
	set qsp=$piece($view("SPSIZE"),",",1)
	if qsp>(2*98304) write "PASS : the stringpool grew beyond twice its initial 96KiB",!
	else  write "FAIL : the stringpool is ",qsp," bytes, expected more than twice its initial 96KiB (196608)",!
	quit
	;
	; ---- helpers (their own variables all start with q, and the test data never does) ----
	;
init	; the test data
	kill *al
	kill (qrefs,qcmds,qtgts,qsubs,qi,qk,qc,qr,qa,qb,qt,qs,qbad,qcnt,qseed,qbase,qprev,qerr)
	set x=1,x(1)="one",x(1,2)="onetwo",x(-1)="neg",x(.5)="half",x("a")="A",x("a","b")=2,x("")="null",x("5x")="s5x"
	set x("q""q")="quote",x(1.5)=15,x(2,"z")="2z",x("ab",3,"c")="deep",%p("%")="pct",y="a",y(1)="b",n=1,d=.5,neg=-1,s="5x"
	set e="",yy("k")=1,big=12345678901234567890,str5="5",mix="1.0",x(1.0)="one again",x("1.0")="str 1.0"
	set x(12345678901234567890)="big",ctl="a"_$char(1)_"b",x(ctl)="ctl",*al=x,i=1
	for qj=1:1:30 set x("t",qj)=qj,x("t",qj,1)="t"_qj
	kill qj
	quit
cmp(qform,qref)	; compare QFORM through @ref (the fast path if it applies) with it through @(ref_" ") (always compiled)
	new qfast,qslow
	set qfast=$$try(qform,qref),qslow=$$try(qform,qref_" ")
	set qcnt=qcnt+1
	if qfast'=qslow set qbad=qbad+1 write "WRONG : ",$$subst(qform,qref)," gives ",qfast,", but compiled ",qslow,!
	quit
try(qform,qval)	; value of QFORM with @R standing for @ref, ref being QVAL, or the error it raises. Each form has its
	; own label rather than being run by XECUTE, since an error raised inside XECUTE while an indirect reference
	; is saved in the glvn pool leaves the pool space it took (repeated, that trips glvn_pool.c asserts).
	new $etrap,qv,ref
	set $etrap="set qv=""ERR ""_$piece($zstatus,"","",3),$ecode="""" quit:$quit qv  quit"
	set ref=qval
	set qv=$select(qform="$data(@R)":$$fd(),qform="$zdata(@R)":$$fzd(),qform="$get(@R)":$$fg(),qform="$get(@R,""dflt"")":$$fg2(),qform="$order(@R)":$$fo(),qform="$order(@R,-1)":$$fo2(),qform="@R":$$fv(),qform="$name(@R)":$$fn(),qform="$name(@R,0)":$$fn0(),qform="$name(@R,1)":$$fn1(),qform="$name(@R,2)":$$fn2(),1:$$fx(qform))
	quit qv
fd()	quit $data(@ref)
fzd()	quit $zdata(@ref)
fg()	quit $get(@ref)
fg2()	quit $get(@ref,"dflt")
fo()	quit $order(@ref)
fo2()	quit $order(@ref,-1)
fv()	quit @ref
fn()	quit $name(@ref)
fn0()	quit $name(@ref,0)
fn1()	quit $name(@ref,1)
fn2()	quit $name(@ref,2)
fx(qform)	; any other form, by XECUTE
	new qv
	xecute "set qv="_$$subst(qform,"@ref")
	quit qv
ncmp(qform,qtgt,qsub)	; compare QFORM on @r@(qsub) with the compiled form of the text op_indname composes
	new qfast,qslow,qf1,qf2,qcomp
	set qf1=$piece(qform,"S",1)_qsub_$piece(qform,"S",2,9)
	set qcomp=$select($extract(qtgt,$length(qtgt))=")":$extract(qtgt,1,$length(qtgt)-1)_",",1:qtgt_"(")_qsub_") "
	set qf2=$piece(qform,"@r@(S)",1)_"@R"_$piece(qform,"@r@(S)",2,9)
	set r=qtgt,i=1,qfast=$$ntry(qf1)
	set i=1,qslow=$$try(qf2,qcomp)
	set qcnt=qcnt+1
	if qfast'=qslow set qbad=qbad+1 write "WRONG : ",qf1," with r=",qtgt," gives ",qfast,", but compiled ",qslow,!
	quit
ntry(qform)	; value of QFORM, or the error it raises
	new $etrap,qv
	set $etrap="set qv=""ERR ""_$piece($zstatus,"","",3),$ecode="""" quit:$quit qv  quit"
	xecute "set qv="_qform
	quit qv
subst(qform,qwith)	; QFORM with @R replaced by QWITH
	quit $piece(qform,"@R",1)_qwith_$piece(qform,"@R",2,9)
run(qcmd,qref)	; run QCMD with @R standing for @ref, ref being QREF, leaving the mnemonic of any error in qerr
	new $etrap,qcode,qj,ref
	set qerr=""
	set $etrap="set qerr=$piece($zstatus,"","",3),$ecode="""" quit"
	set ref=qref
	set qcode=$piece(qcmd,"@R",1) for qj=2:1:$length(qcmd,"@R") set qcode=qcode_"@ref"_$piece(qcmd,"@R",qj)
	xecute qcode
	quit
snap(qout)	; the test data that the commands can change, in QOUT
	merge qout("x")=x,qout("newv")=newv,qout("y2")=y2,qout("z")=z,qout("i")=i
	set qout("error")=qerr
	quit
same(qa,qb)	; 1 if QA and QB hold the same nodes and values
	quit $$eq("qa","qb")
eq(qn1,qn2)	; 1 if the trees at the names QN1 and QN2 are the same. This walks with $ORDER, not $QUERY, since
	; $QUERY of a reference whose last subscript is "" returns that reference itself.
	new qs,qok
	if $data(@qn1)'=$data(@qn2) quit 0
	if $data(@qn1)#2,@qn1'=@qn2 quit 0
	if $data(@qn1@(""))!$data(@qn2@("")) quit:'$$eq($name(@qn1@("")),$name(@qn2@(""))) 0
	set qok=1,qs="" for  set qs=$order(@qn1@(qs)) quit:qs=""  if '$$eq($name(@qn1@(qs)),$name(@qn2@(qs))) set qok=0 quit
	quit:'qok 0
	set qs="" for  set qs=$order(@qn2@(qs)) quit:qs=""  if '$data(@qn1@(qs)) set qok=0 quit
	quit qok
verdict(qstage)
	write $select(qbad:"FAIL : "_qbad_" of "_qcnt_" "_qstage_" checks give a different result through the fast path",1:"PASS : all "_qcnt_" "_qstage_" checks give the same result through the fast path as compiled"),!
	quit
inci()	set i=i+1 quit "rhs"
side()	set r="y" quit 1
rnd(qm)	set qseed=(qseed*1103515245+12345)#2147483648
	quit qseed\65536#qm
rname()	quit $piece("x,x,x,x,y,nosuch,%p,X,abcdefghijklmnopqrstuvwxyz12345,x2",",",$$rnd(10)+1)
rsubs()	new qn,qi,qs
	set qn=$$rnd(6) quit:'qn $select($$rnd(20):"",1:"()")
	set qs="("
	for qi=1:1:qn set qs=qs_$select(qi>1:$select($$rnd(40):",",1:",,"),1:"")_$$rsub
	quit qs_$select($$rnd(30):")",$$rnd(2):"",1:"))")
rsub()	new qt set qt=$$rnd(14)
	quit:qt=0 $$rnd(40)
	quit:qt=1 "-"_($$rnd(9)+1)
	quit:qt=2 $piece(".5,-.5,1.5,1.0,01,-0,1E2,1.,.,-,12345678901234567890,123456789012345678,0",",",$$rnd(13)+1)
	quit:qt=3 """"_$piece("a,b,c,t,5x,1.0,5,,ab,%",",",$$rnd(10)+1)_""""
	quit:qt=4 """q""""q"""
	quit:qt=5 """"_$char(233)_""""
	quit:qt=6 $piece("n,d,s,e,y,neg,str5,mix,ctl",",",$$rnd(9)+1)
	quit:qt=7 $piece("undefvar,yy,x,%p",",",$$rnd(4)+1)
	quit:qt=8 """t"""
	quit:qt=9 $$rnd(31)+1
	quit:qt=10 $piece("1+1,""a""_1,$l(""ab""),y(1),@y, 1,1 ,$c(97)",",",$$rnd(8)+1)
	quit:qt=11 """leaf"""
	quit:qt=12 $$rnd(4)
	quit """a"""
