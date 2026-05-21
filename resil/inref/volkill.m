;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2003-2016 Fidelity National Information         ;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start(cert) ; data base volume test with KILL
	; test stops when $d(^STOP)'=0

	Set $ZTrap="Set $ZTrap="""" ZGoto "_$ZLevel_":error^volkill"

	View "GDSCERT":cert

	W "PID: ",$J,!
	; ^light was set in drive based on LFE
	If $Data(^light)  s pass=5
	Else  s pass=500
	s mark=$j*pass,maxnod=500,maxlen=120,lenidx=0,FAIL=0,ermax=1
	W !!,"VOLKILL volume test"

	s ITEM="VOLKILL volume test - no wait "
	W !,ITEM,pass," passes, accepts ",ermax," errors"
	s exam=pass\16+1
	k ^b5($j)
	f i=1:1:pass d proc0 i i#exam=0 d EXAMIN(i)
	W !,"   PASS  ",ITEM,",",i," PASSES"

	s ITEM="VOLKILL volume test - random wait "
	W !,ITEM,pass," passes, accepts ",ermax," errors"
	k ^b5($j)
	f i=1:1:pass d proc1 i i#exam=0 d EXAMIN(i)
	W !,"   PASS  ",i

	s ITEM="VOLKILL volume test - with $TRANSLATE a "
	W !,ITEM,pass," passes"
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") d proc2
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") k ^a6(k1,1) i i#exam=0 d EXAMIN(i)
	W !,"   PASS  ",i

	s ITEM="VOLKILL volume test - with $TRANSLATE b "
	W !,ITEM,pass," passes"
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") s ^a6(k1,1)=$j(i,i#20) i i#exam=0 d EXAMIN(i)
	f i=1:7:pass s k1=$tr($j(i,10)," ","0") k ^a6(k1)
	W !,"   PASS  ",i
	W !,"VOLKILL volume tests COMPLETE"
	q

error	Write ! ZSHOW "*" Write !
	ZMessage +$ZStatus
	q

proc0	k ^b5($j)
	i $d(^b5($j))'=0			d TRACE(0,$d(^b5($j)),0) q
	s x=$o(^b5($j-1)) i x'="",x<($j+1)	d TRACE(1,$o(^b5($j-1)),"")  q
	s (top,^b5($j))=mark,mark=mark+1
	s (left,^($j,1))=mark,mark=mark+1
	s (right,^(3))=mark,mark=mark+1
	f i1=1:1:i#maxnod s lenidx=lenidx+1#maxlen,^b5($j,2,i1)=$j("",lenidx)
	d chktop("a")
	i i#maxnod=0,$d(^b5($j,2))'=0 d TRACE(2,$d(^b5($j,2)),0)  q
	i i#maxnod,$d(^b5($j,2))'=10 d TRACE(3,$d(^b5($j,2)),10) q
	f i1=1:i#10+1:i#maxnod k ^b5($j,2,i1)
	d chktop("b")
	k ^b5($j,2)
	d chktop("c")
	q

proc1	k ^b5($j)
	h $r(2)*0.17
	i $d(^b5($j))'=0				d TRACE(0,$d(^b5($j)),0) q
	h $r(3)*0.17
	s x=$o(^b5($j-1)) i x'="",x<($j+1)	d TRACE(1,$o(^b5($j-1)),"")  q
	h $r(2)*0.17
	s (top,^b5($j))=mark,mark=mark+1
	h $r(3)*0.17
	s (left,^($j,1))=mark,mark=mark+1
	h $r(3)*0.17
	s (right,^(3))=mark,mark=mark+1
	h $r(2)*0.17
	f i1=1:1:i#maxnod s lenidx=lenidx+1#maxlen,^b5($j,2,i1)=$j("",lenidx)
	h $r(3)*0.17
	d chktop("a")
	h $r(2)*0.17
	i i#maxnod=0,$d(^b5($j,2))'=0	d TRACE(2,$d(^b5($j,2)),0)  q
	i i#maxnod,$d(^b5($j,2))'=10	d TRACE(3,$d(^b5($j,2)),10) q
	d chktop("b")
	h $r(3)*0.17
	k ^b5($j,2)
	h $r(2)*0.17
	d chktop("c")
	q

chktop(pos)
	i $d(^b5($j))'=11		d TRACE(pos_4,$d(^b5($j)),11)  q
	s x=$o(^b5($j-1)) i x'=$j	d TRACE(pos_5,x,$j) q
	i $d(^b5($j))'=11               d TRACE(pos_6,$d(^b5($j)),11)  q
	i ^b5($j)'=top                  d TRACE(pos_7,^b5($j),top)  q
	i $d(^b5($j,1))'=1              d TRACE(pos_8,$d(^b5($j,1)),1)  q
	i ^b5($j,1)'=left                       d TRACE(pos_9,^b5($j,1),left)  q
	i $d(^b5($j,3))'=1                      d TRACE(pos_10,$d(^b5($j,3)),1)  q
	i ^b5($j,3)'=right                      d TRACE(pos_11,^b5($j,3),right)  q
	i $o(^b5($j,3))'=""                     d TRACE(pos_12,$o(^b5($j,3)),"")  q
	i $o(^b5($j,""))'=1                     d TRACE(pos_13,$o(^b5($j,"")),1)  q
	q

proc2	s ^a6(k1)=$j(i,i#8)
	f j=0:1:i#97 s ^a6(k1,1,j+1000)=$j(j,i+j#9)
	q

EXAMIN(cnt)	s q=$H
	W !,"   PASS ",cnt," at ",$ZD(q,"24:60:SS") W:$Y>55 #
	If $DATA(^STOP) Halt
	q

TRACE(LBL,VCOMP,VCORR)	S FAIL=FAIL+1,q=$H
	W !,"** FAIL ",FAIL," in ",ITEM,"check ",LBL,", ",i,"-th pass at ",$ZD(q,"24:60:SS") W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	W !,"$j = ",$j,!
	If FAIL=ermax  Set ^STOP=1  Halt
	Q
