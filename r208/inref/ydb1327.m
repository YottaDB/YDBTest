;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; TP restarts after an argumentless or exclusive NEW that follows TSTART, for r208/tp_restart_new-ydb1327
;
; $gtm_dist/mumps -run one^ydb1327 <case> runs the label <case>, which records in ^r(<case>,"in") what it sees in the
; transaction after the restart, and in ^r(<case>,"after") what it sees after the transaction, as ^r survives the end of
; the NEW. It then compares them with the values the table below gives for the case, and prints PASS or WRONG.
;
; Table lines are ;<case>;<expected in the transaction>;<expected after it>;<description>
;
ydb1327
	quit

one	;
	new case,exp,i,line,got,desc
	set case=$zcmdline,exp=""
	for i=1:1 set line=$text(table+i) quit:line'[";"  if $piece(line,";",2)=case set exp=$piece(line,";",3,4),desc=$piece(line,";",5)
	kill ^r(case)
	do @case
	set got=$get(^r(case,"in"),"-")_";"_$get(^r(case,"after"),"-")
	write $select(got=exp:"PASS",1:"WRONG")," : ",case," : ",desc,!
	write "       in the transaction, then after it : ",$translate(got,";","|")
	write:got'=exp " (expected ",$translate(exp,";","|"),")"
	write !
	quit

table	; In the transaction : x then $TRESTART, unless stated. After it : x then $TLEVEL, unless stated.
	;xa;10 1;2 0;XECUTE: TSTART (x), argumentless NEW, TRESTART
	;xi;10 <undef> 1;10 6 0;XECUTE: TSTART (x,z), NEW (x), TRESTART (x z $TRESTART, then x z $TLEVEL)
	;xx;2 1;2 0;XECUTE: TSTART (), NEW (x), TRESTART
	;xn2;10 1;2 0;XECUTE: TSTART (x), then an inner XECUTE with an argumentless NEW and the TRESTART
	;im;10 1;2 5 0;XECUTE: TSTART (x), argumentless NEW, implicit restart from a concurrent update (x ^b $TLEVEL after)
	;ri;10 <undef> 1;10 6 0;DO frame: TSTART (x,z), NEW (x), TRESTART (as xi, in a DO instead of an XECUTE)
	;b;2 <undef> 1;2 0;TSTART (x) then an XECUTE with an argumentless NEW, then TRESTART (x y $TRESTART in)
	;c;2 1;2 0;TSTART (x) then a DO with an argumentless NEW, then TRESTART
	;d;<undef> 3 1;<undef> 0;TSTART (x), argumentless NEW and TRESTART in the same frame (x y $TRESTART in)
	;e;2 1;2 0;TSTART (x) then an XECUTE with NEW x, then TRESTART
	;f;3 1;2 0;XECUTE: TSTART (x), NEW x, TRESTART
	;g;2 1;2 0;XECUTE: TSTART (x), NEW $ETRAP, TRESTART
	;h;3 0;2 0;XECUTE: TSTART (x), argumentless NEW, no TRESTART
	;j;2 1;2 0;XECUTE: TSTART (x), a DO with an argumentless NEW, TRESTART

xa	set x=1 xecute "tstart (x) set x=x+1 new  set x=10 trestart:$trestart<1  set ^r(""xa"",""in"")=x_"" ""_$trestart tcommit"
	set ^r("xa","after")=x_" "_$tlevel
	quit
xi	set x=1,z=5 xecute "tstart (x,z) set x=x+1,z=z+1 new (x) set x=10 trestart:$trestart<1  set ^r(""xi"",""in"")=x_"" ""_$get(z,""<undef>"")_"" ""_$trestart tcommit"
	set ^r("xi","after")=x_" "_z_" "_$tlevel
	quit
xx	set x=1 xecute "tstart () set x=2 new (x) trestart:$trestart<1  set ^r(""xx"",""in"")=x_"" ""_$trestart tcommit"
	set ^r("xx","after")=x_" "_$tlevel
	quit
xn2	set x=1 xecute "tstart (x) set x=x+1 xecute ""new  set x=10 trestart:$trestart<1  set ^r(""""xn2"""",""""in"""")=x_"""" """"_$trestart"" tcommit"
	set ^r("xn2","after")=x_" "_$tlevel
	quit
im	set x=1,^a=0 kill ^b
	xecute "tstart (x) set x=x+1 new  set x=10,v=^a zsystem:$trestart<1 ""$gtm_dist/mumps -run %XCMD 'set ^a=5'"" set ^b=v,^r(""im"",""in"")=x_"" ""_$trestart tcommit"
	set ^r("im","after")=x_" "_^b_" "_$tlevel
	quit
ri	set x=1,z=5 do ri1
	set ^r("ri","after")=x_" "_z_" "_$tlevel
	quit
ri1	tstart (x,z) set x=x+1,z=z+1 new (x) set x=10 trestart:$trestart<1  set ^r("ri","in")=x_" "_$get(z,"<undef>")_" "_$trestart tcommit
	quit
b	set x=1 tstart (x) set x=2 xecute "new  set y=3" trestart:$trestart<1
	set ^r("b","in")=$get(x,"<undef>")_" "_$get(y,"<undef>")_" "_$trestart tcommit
	set ^r("b","after")=x_" "_$tlevel
	quit
c	set x=1 tstart (x) set x=2 do c1 trestart:$trestart<1
	set ^r("c","in")=$get(x,"<undef>")_" "_$trestart tcommit
	set ^r("c","after")=x_" "_$tlevel
	quit
c1	new  set y=3 quit
d	set x=1 tstart (x) set x=2 new  set y=3 trestart:$trestart<1
	set ^r("d","in")=$get(x,"<undef>")_" "_$get(y,"<undef>")_" "_$trestart tcommit
	set ^r("d","after")=$get(x,"<undef>")_" "_$tlevel
	quit
e	set x=1 tstart (x) set x=2 xecute "new x set x=5" trestart:$trestart<1
	set ^r("e","in")=$get(x,"<undef>")_" "_$trestart tcommit
	set ^r("e","after")=x_" "_$tlevel
	quit
f	set x=1 xecute "tstart (x) set x=2 new x set x=3 trestart:$trestart<1  set ^r(""f"",""in"")=x_"" ""_$trestart tcommit"
	set ^r("f","after")=x_" "_$tlevel
	quit
g	set x=1 xecute "tstart (x) set x=2 new $etrap trestart:$trestart<1  set ^r(""g"",""in"")=x_"" ""_$trestart tcommit"
	set ^r("g","after")=x_" "_$tlevel
	quit
h	set x=1 xecute "tstart (x) set x=2 new  set x=3 set ^r(""h"",""in"")=x_"" ""_$trestart tcommit"
	set ^r("h","after")=x_" "_$tlevel
	quit
j	set x=1 xecute "tstart (x) set x=2 do j1 trestart:$trestart<1  set ^r(""j"",""in"")=x_"" ""_$trestart tcommit"
	set ^r("j","after")=x_" "_$tlevel
	quit
j1	new  quit
