start	; data base volume test with KILL
	; test stops when $d(^STOP)'=0

	Set $ZTrap="Set $ZTrap="""" do error^volkill"

	do ^cmclient(1,101,$ZPARSE("mumps.gld"))
	set portfile="portno.txt" open portfile use portfile
	read port
	close portfile
	i $$^connect("127.0.0.1",port,"user","pw")=0 w "Attempted connection to GT.CM server failed!",! q

	w "Child process id is: ",$J,!
 	q:'$$^lock("^JOB")
	i $$^define("^JOB") q:'$$^set("^JOB",$$^get("^JOB")+1)
	e  q:'$$^set("^JOB",1)
	q:'$$^unlockcl()
	s pass=10
	s mark=$j*pass,maxnod=500,maxlen=120,lenidx=0,FAIL=0,ermax=3
	W !!,"VOLKILL volume test"

	W !!,"NO GDS certification"

	s ITEM="VOLKILL volume test - no wait "
	W !,ITEM,pass," passes, accepts ",ermax," errors"
	s exam=pass\4+1
	q:'$$^kill("^b5("_$j_")")
 	f i=1:1:pass D
	.  d proc0 
	.  i i#exam=0 d EXAMIN(i)
 	W !,"   PASS  ",ITEM,",",i," PASSES"

	s ITEM="VOLKILL volume test - random wait "
	W !,ITEM,pass," passes, accepts ",ermax," errors"
	q:'$$^kill("^b5("_$j_")")
	f i=1:1:pass d proc1 i i#exam=0 d EXAMIN(i)
	W !,"   PASS  ",i

	s ITEM="VOLKILL volume test - with $TRANSLATE a "
	W !,ITEM,pass," passes"
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") d proc2
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") q:'$$^kill("^a6("_k1_",1)")  i i#exam=0 d EXAMIN(i)
	W !,"   PASS  ",i

	s ITEM="VOLKILL volume test - with $TRANSLATE b "
	W !,ITEM,pass," passes"
	f i=1:1:pass s k1=$tr($j(i,10)," ","0") q:'$$^set("^a6("_k1_",1)",$j(i,i#20))  i i#exam=0 d EXAMIN(i)
	f i=1:7:pass s k1=$tr($j(i,10)," ","0") q:'$$^kill("^a6("_k1_")")
	W !,"   PASS  ",i
	q:'$$^lock("^JOB")  q:'$$^set("^JOB",$$^get("^JOB")-1)  q:'$$^unlockcl()
	W !,"VOLKILL volume tests COMPLETE"
	q:'$$^disc()
	q

error	Write ! ZSHOW "*" Write !
	Lock ^JOB 
	Set ^JOB=^JOB-1 
	Lock  
	ZMessage +$ZStatus
	q


proc0
	q:'$$^kill("^b5("_$j_")")
	i $$^define("^b5("_$j_")")'=0	d TRACE(0,$$^define("^b5("_$j_")"),0) q 
	s x=$$^order("^b5("_($j-1)_")") i x'="",x<($j+1)	d TRACE(1,$$^order("^b5("_($j-1)_")"),"")  q
	q:'$$^set("^b5("_$j_")",mark)
	s top=mark,mark=mark+1
	q:'$$^set("^b5("_$j_",1)",mark)
	s left=mark,mark=mark+1
	q:'$$^set("^b5("_$j_",3)",mark)
	s right=mark,mark=mark+1
	f i1=1:1:i#maxnod s lenidx=lenidx+1#maxlen q:'$$^set("^b5("_$j_",2,"_i1_")",$j("",lenidx))
	d chktop("a")
	i i#maxnod=0,$$^define("^b5("_$j_",2)")'=0 d TRACE(2,$$^define("^b5("_$j_",2)"),0)  q
	i i#maxnod,$$^define("^b5("_$j_",2)")'=10 d TRACE(3,$$^define("^b5("_$j_",2)"),10) q
	f i1=1:i#10+1:i#maxnod q:'$$^kill("^b5("_$j_",2,"_i1_")")
	d chktop("b")
	q:'$$^kill("^b5("_$j_",2)")
	d chktop("c")
	q

proc1	q:'$$^kill("^b5("_$j_")")
	h $r(2)
	i $$^define("^b5("_$j_")")'=0				d TRACE(0,$$^define("^b5("_$j_")"),0) q 
	h $r(3)
	s x=$$^order("^b5("_($j-1)_")") i x'="",x<($j+1)	d TRACE(1,$$^order("^b5("_($j-1)_")"),"")  q
	h $r(2)
	q:'$$^set("^b5("_$j_")",mark)
	s top=mark,mark=mark+1
	h $r(3)
	q:'$$^set("^b5("_$j_",1)",mark)
	s left=mark,mark=mark+1
	h $r(3)
	q:'$$^set("^b5("_$j_",3)",mark)
	s right=mark,mark=mark+1
	h $r(2)
	f i1=1:1:i#maxnod s lenidx=lenidx+1#maxlen q:'$$^set("^b5("_$j_",2,"_i1_")",$j("",lenidx))
	h $r(3)
	d chktop("a")
	h $r(2)
	i i#maxnod=0,$$^define("^b5("_$j_",2)")'=0	d TRACE(2,$$^define("^b5("_$j_",2)"),0)  q
	i i#maxnod,$$^define("^b5("_$j_",2)")'=10	d TRACE(3,$$^define("^b5("_$j_",2)",10)) q
	d chktop("b")
	h $r(3)
	q:'$$^kill("^b5("_$j_",2)")
	h $r(2)
	d chktop("c")
	q

chktop(pos)
	i $$^define("^b5("_$j_")")'=11		d TRACE(pos_4,$$^define("^b5("_$j_")"),11)  q
	s x=$$^order("^b5("_($j-1)_")") i x'=$j	d TRACE(pos_5,x,$j) q
	i $$^define("^b5("_$j_")")'=11 		d TRACE(pos_6,$$^define("^b5("_$j_")"),11)  q
	i $$^get("^b5("_$j_")")'=top 		d TRACE(pos_7,$$^get("^b5("_$j_")"),top)  q
	i $$^define("^b5("_$j_",1)")'=1 	d TRACE(pos_8,$$^define("^b5("_$j_",1)"),1)  q
	i $$^get("^b5("_$j_",1)")'=left		d TRACE(pos_9,$$^get("^b5("_$j_",1)"),left)  q
	i $$^define("^b5("_$j_",3)")'=1		d TRACE(pos_10,$$^define("^b5("_$j_",3)"),1)  q
	i $$^get("^b5("_$j_",3)")'=right	d TRACE(pos_11,$$^get("^b5("_$j_",3)"),right)  q
	i $$^order("^b5("_$j_",3)")'=""		d TRACE(pos_12,$$^order("^b5("_$j_",3)"),"")  q
	i $$^order("^b5("_$j_","""")")'=1 	d TRACE(pos_13,$$^order("^b5("_$j_","""")"),1)  q
	q

proc2	q:'$$^set("^a6("_k1_")",$j(i,i#8))
	f j=0:1:i#97 q:'$$^set("^a6("_k1_",1,"_(j+1000)_")",$j(j,i+j#9))
	q

EXAMIN(cnt)	s q=$H
	W !,"   PASS ",cnt," at ",$ZD(q,"24:60:SS") W:$Y>55 #  
	If $$^define("^STOP") q:'$$^lock("^JOB")  q:'$$^set("^JOB",$$^get("^JOB")-1)  q:'$$^unlockcl()  Halt
	q

TRACE(LBL,VCOMP,VCORR)	S FAIL=FAIL+1,q=$H
	W !,"** FAIL ",FAIL," in ",ITEM,"check ",LBL,", ",i,"-th pass at ",$ZD(q,"24:60:SS") W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	W !,"$j = ",$j,!
	If FAIL=ermax  q:'$$^set("^STOP",1)  q:'$$^lock("^JOB")  q:'$$^set("^JOB",$$^get("^JOB")-1)  q:'$$^unlockcl()  Halt
	Q
