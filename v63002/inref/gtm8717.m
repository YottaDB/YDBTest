;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

select  ;
        write "temp",!
        write "         set $ztrap=""goto incrtrap^incrtrap""",!
        set rand=$random(4) set strlit1=$select(rand=0:"a",rand=1:"",rand=2:"0",rand=3:"1")
        set rand=$random(4) set strlit2=$select(rand=0:"a",rand=1:"",rand=2:"0",rand=3:"1")
        set rand=$random(2) set numlit1=$select(rand=0:0,rand=1:1)
        set rand=$random(2) set numlit2=$select(rand=0:0,rand=1:1)
        set lcl1="x",lcl2="y",gbl1="^x",gbl2="^y"
        write "         set x=$random(2),y=$random(2),^x=$random(2),^y=$random(2)",!
        set noerr=$random(2)
        write "         set noerr=",noerr," ; noerr=0 implies possibility of syntax errors in generated $select() statement",!
        write "         write "
        do sideeffect
        do dollarselect
        write !
        write "         quit",!
        quit

sideeffect;
        set rand=$random(3)
        if rand=0 write "$incr(x)!"
        if rand=1 write "$incr(x)&"
        if rand=2 write ""
        quit

dollarselect;
        write "$select("
        set n=$random(8)+1
        for i=1:1:n do selectatom  if i'=n write ","
        if noerr!$random(2) write ")"
        quit

selectatom;
        if noerr!$random(2) do selectleft
        if noerr!$random(2) write ":"
        if noerr!$random(2) do selectright
        quit

selectleft;
        set rand=$random(32)
        if rand=0   write "0"
        if rand=1   write "1"
        if rand=2   write strlit1,"=",strlit2
        if rand=3   write strlit1,"'=",strlit2
        if rand=4   write strlit1,"=",numlit1
        if rand=5   write strlit1,"'=",numlit1
        if rand=6   write numlit1,"=",numlit2
        if rand=7   write numlit1,"'=",numlit2
        if rand=8   write strlit1,"=",lcl1
        if rand=9   write strlit1,"'=",lcl1
        if rand=10  write strlit1,"=",lcl2
        if rand=11  write strlit1,"'=",lcl2
        if rand=12  write strlit1,"=",gbl1
        if rand=13  write strlit1,"'=",gbl1
        if rand=14  write strlit1,"=",gbl2
        if rand=15  write strlit1,"'=",gbl2
        if rand=16  write numlit1,"=",lcl1
        if rand=17  write numlit1,"'=",lcl1
        if rand=18  write numlit1,"=",lcl2
        if rand=19  write numlit1,"'=",lcl2
        if rand=20  write numlit1,"=",gbl1
        if rand=21  write numlit1,"'=",gbl1
        if rand=22  write numlit1,"=",gbl2
        if rand=23  write numlit1,"'=",gbl2
        if rand=24  write lcl1,"=",lcl2
        if rand=25  write lcl1,"'=",lcl2
        if rand=26  write lcl1,"=",gbl2
        if rand=27  write lcl1,"'=",gbl2
        if rand=28  write gbl1,"=",gbl2
        if rand=29  write gbl1,"'=",gbl2
        if rand=30  write gbl1,"=",lcl2
        if rand=31  write gbl1,"'=",lcl2
        quit

selectright:
        set rand=$random(14)
        if rand=0 write "0"
        if rand=1 write "1"
        if rand=2 write strlit1
        if rand=3 write strlit2
        if rand=4 write numlit1
        if rand=5 write numlit2
        if rand=6 write lcl1
        if rand=7 write lcl2
        if rand=8 write gbl1
        if rand=9 write gbl2
        if rand=10 write "$incr(",lcl1,")"
        if rand=11 write "$incr(",lcl2,")"
        if rand=12 write "$incr(",gbl1,")"
        if rand=13 write "$incr(",gbl2,")"
        quit

