start(cert) ; data base volume test with TP
	; test stops when $d(^STOP)'=0

	Set $ZTrap="Set $ZTrap="""" TROllback:$TLevel  ZGoto "_$ZLevel_":error^volktp"

	View "GDSCERT":cert

	W "PID: ",$J,!
	If $Data(^light)  s pass=5
	Else  s pass=500
	s mark=$j*pass,maxnod=500,maxlen=120,lenidx=0,FAIL=0,ermax=3
	W !!,"VOLKTP volume test"

	s ITEM="VOLKTP volume test - no wait "
	W !,ITEM,pass," passes, accepts ",ermax," errors"
	s exam=pass\16+1
	k ^b5($j)
	f i=1:1:pass d proc0 i i#exam=0 d EXAMIN(i)
	W !,"   PASS  ",ITEM,",",i," PASSES"

	s ITEM="VOLKTP volume test - random wait "
	W !,ITEM,pass," passes, accepts ",ermax," errors"
	k ^b5($j)
	f i=1:1:pass d proc1 i i#exam=0 d EXAMIN(i)
	W !,"   PASS  ",i

	s ITEM="VOLKTP volume test - with $TRANSLATE a "
	W !,ITEM,pass," passes"
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") d proc2
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") k ^a6(k1,1) i i#exam=0 d EXAMIN(i)
	W !,"   PASS  ",i

	s ITEM="VOLKTP volume test - with $TRANSLATE b "
	W !,ITEM,pass," passes"
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") s ^a6(k1,1)=$j(i,i#20) i i#exam=0 d EXAMIN(i)
	f i=1:7:pass s k1=$tr($j(i,10)," ","0") k ^a6(k1)
	W !,"   PASS  ",i
	W !,"VOLKTP volume tests COMPLETE"
	q

error	Write ! ZSHOW "*" Write ! 
	ZMessage +$ZStatus
	q

proc0	k ^b5($j)
	s cpass=$e(pass,$l(pass))
	if cpass#2 tstart *:serial
	i $d(^b5($j))'=0			d TRACE(0,$d(^b5($j)),0) q 
	s x=$o(^b5($j-1)) i x'="",x<($j+1)	d TRACE(1,$o(^b5($j-1)),"")  q
	s (top,^b5($j))=mark,mark=mark+1
	s (left,^($j,1))=mark,mark=mark+1
	s (right,^(3))=mark,mark=mark+1
	f i1=1:1:i#maxnod s lenidx=lenidx+1#maxlen,^b5($j,2,i1)=$j("",lenidx)
	d chktop("a")
	if $tlevel,cpass#4>1 tcommit  d chktop("a")
	i i#maxnod=0,$d(^b5($j,2))'=0 d TRACE(2,$d(^b5($j,2)),0)  q
	i i#maxnod,$d(^b5($j,2))'=10 d TRACE(3,$d(^b5($j,2)),10) q
	if cpass>4 ts ():serial
	f i1=1:i#10+1:i#maxnod k ^b5($j,2,i1)
	d chktop("b")
	if $tlevel,cpass>6 tcommit  d chktop("b")
	if cpass>8 tstart ():serial
	k ^b5($j,2)
	d chktop("c")
	f  q:'$tlevel  tcommit  d chktop("c")
	q

proc1	k ^b5($j)
	h $r(2)*0.17
	i $d(^b5($j))'=0			d TRACE(0,$d(^b5($j)),0) q 
	h $r(3)*0.17
	s x=$o(^b5($j-1)) i x'="",x<($j+1)	d TRACE(1,$o(^b5($j-1)),"")  q
	h $r(2)*0.17
	s (top,^b5($j))=mark,mark=mark+1
	h $r(3)*0.17
	s (left,^($j,1))=mark,mark=mark+1
	h $r(3)*0.17
	s (right,^(3))=mark,mark=mark+1
	h $r(2)*0.17
	if pass#2 tstart lenidx:serial
	f i1=1:1:i#maxnod s lenidx=lenidx+1#maxlen,^b5($j,2,i1)=$j("",lenidx)
	if $tlevel tcommit
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
	i $d(^($j))'=11 		d TRACE(pos_6,$d(^($j)),11)  q
	i ^($j)'=top 			d TRACE(pos_7,^($j),top)  q
	i $d(^($j,1))'=1 		d TRACE(pos_8,$d(^($j,1)),1)  q
	i ^(1)'=left 			d TRACE(pos_9,^(1),left)  q
	i $d(^(3))'=1 			d TRACE(pos_10,$d(^(3)),1)  q
	i ^(3)'=right 			d TRACE(pos_11,^(3),right)  q
	i $o(^(3))'="" 			d TRACE(pos_12,$o(^(3)),"")  q
	i $o(^(""))'=1 			d TRACE(pos_13,$o(^("")),1)  q
	q

proc2	i pass#2=0 tstart ():serial
	s ^a6(k1)=$j(i,i#8)
	f j=0:1:i#97 s ^a6(k1,1,j+1000)=$j(j,i+j#9)
	if $tlevel tcommit
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
