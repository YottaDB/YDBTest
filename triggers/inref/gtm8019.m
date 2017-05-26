;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8019	;
	new str,len,i,ystr,namestr,tail,xstr,x
	set str="a2345678901234567890123456789012",len=$length(str)
	for i=1,2,20,21,22,27,28,29,31,32 do
	. write "----------------------------------------------------------------------",!
	. write "Testing for name length : ",i,!
	. write "----------------------------------------------------------------------",!
	. set ystr=$extract(str,1,i)
	. for namestr="","-name="_ystr_" " do
	. . for tail="#02","#023","#0234","#00045","#023456","#203456","*","#*","#1","#",""  do
	. . . set xstr="set x=$ztrigger(""item"",""-*"")"
	. . . write !,xstr,! xecute xstr write "  --> Return value of $ztrigger = ",x,!
	. . . ; write !,xstr," : " use file xecute xstr use $principal write x,!
	. . . set xstr="set x=$ztrigger(""item"",""+^"_ystr_" -commands=S "_namestr_"-xecute=""""write 1"""""")"
	. . . write xstr,! xecute xstr write "  --> Return value of $ztrigger = ",x,!
	. . . set xstr="set x=$ztrigger(""select"","""_ystr_tail_""")"
	. . . write xstr,! xecute xstr write "  --> Return value of $ztrigger = ",x,!
	. . . set xstr="set x=$ztrigger(""item"",""-"_ystr_tail_""")"
	. . . write xstr,! xecute xstr write "  --> Return value of $ztrigger = ",x,!
	quit

delete	;
	write "# Delete non-existent named trigger when no triggers exist in the db",!
	write $ztrigger("file","t1.trg"),!
	write $ztrigger("item","-abcdt0"),!
	write "# A no-op named-trigger deletion is followed by a not-noop operation",!
	write $ztrigger("file","t2.trg"),!
	write "# Delete non-existent named trigger when some triggers exist in the db but the named trigger does not",!
	write $ztrigger("file","t1.trg"),!
	write $ztrigger("item","-abcdt0"),!
	quit
