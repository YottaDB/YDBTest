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
; $ZTRIGGER("ITEM") of triggers whose subscript is a string too long to fit in a key (see
; r208/u_inref/trigger_subs_too_long-ydb1356.csh)
;
ydb1356	;
	quit
	;
stage	; Run the stage whose number is the first word of $ZCMDLINE
	new n,file
	set n=$piece($zcmdline," ",1)
	; Delete the triggers of an earlier stage (which can be left if that stage failed), and the nodes it set, except for
	; stage 8, which checks the SET of ^b after MUPIP TRIGGER, and stage 13, which checks the SET of ^d after stage 12
	if (n'=8)&(n'=13) do
	. set file="delete_"_n_".out"
	. open file:newversion use file
	. if $ztrigger("item","-*")
	. close file
	. kill ^a,^b,^c,^d,^e,^f,^abcdefghijklmnopqrstuvwxyzabcde,^cnt
	; ^c (stages 9 to 11) has collation 1, the test collation in which each byte of a string is stored twice
	if ((n>=9)&(n<=11))!(n=14)!(n=15) if $$set^%GBLDEF("^c",0,1)
	if n=1 do try($$str(1030),0)
	if n=2 do try($$str(1015),0)
	if n=3 do try($$str(1014),1)
	if n=4 do try("""a"":"_$$str(1030),0)
	if n=5 do try($$chr(508),0)
	if n=6 do try($$chr(507),1)
	if n=8 do sets
	if n=9 do try($$str(507),1,"^c")
	if n=10 do try($$str(508),0,"^c")
	if n=11 do try($$str(600),0,"^c")
	if n=14 do try($$mix(507),1,"^c",$$q("b")_","_$$q("c"))
	if n=15 do try($$mix(508),0,"^c")
	if n=16 do try($$str(1030)_":"_$$q("z"),0)
	; ^abcdefghijklmnopqrstuvwxyzabcde has the longest global name (31 characters), so the longest string subscript that
	; fits in a key of that global is 984 bytes (1019 - 31 - 4)
	if n=17 do try($$str(984),1,"^abcdefghijklmnopqrstuvwxyzabcde")
	if n=18 do try($$str(985),0,"^abcdefghijklmnopqrstuvwxyzabcde")
	if n=12 do addd("^d",$$str(600)),addd("^e",$$str(600)_":"_$$q("z")),addd("^f",$$q("a")_":"_$$str(600))
	if n=13 do setd
	quit
	;
str(n)	; A string literal of n x's, in the form it has in a trigger specification
	quit """"_$translate($justify("",n)," ","x")_""""
	;
q(s)	; s in double-quotes
	quit $char(34)_s_$char(34)
	;
mix(n)	; Two subscripts with a pattern with parentheses, a local variable name, a string with a double-quote, ranges (one
	; with an open side) and alternations: ?1(1"a,",1"b"),x="a""b":"xxx...";"c";:"d", where the first range ends with n x's
	quit "?1(1"_$$q("a,")_",1"_$$q("b")_"),x="_$$q("a"_$char(34,34)_"b")_":"_$$str(n)_";"_$$q("c")_";:"_$$q("d")
	;
chr(n)	; $CHAR(1,1,...,1) with n 1's
	new i,s
	set s="$CHAR(1" for i=2:1:n set s=s_",1"
	quit s_")"
	;
try(spec,expect,gvn,nodeexpr)
	; Load a SET trigger on gvn(<spec>) (^a by default) with $ZTRIGGER("ITEM"), and check that $ZTRIGGER returns "expect".
	; The output of $ZTRIGGER (which shows the long specification) goes to a file, and only its first line is shown. Then check that
	; SET gvn(1) works and does not invoke the trigger, and, when the trigger was loaded, that a SET of the node that the
	; trigger specification names (or "nodeexpr", the subscripts of a node that it names) invokes the trigger.
	new $etrap,file,line,r,node
	set:'$data(gvn) gvn="^a"
	set $etrap="write ""FAIL : "",$piece($zstatus,"","",3,4),! set $ecode="""" halt"
	set file="ztrigger_"_$piece($zcmdline," ",1)_".out"
	open file:newversion use file
	set r=$ztrigger("item","+"_gvn_"("_spec_") -commands=S -xecute=""set ^cnt=^cnt+1""")
	close file
	open file:readonly use file read line close file
	write "# First line of the $ZTRIGGER output : ",$extract(line,1,40),!
	write $select(r=expect:"PASS",1:"FAIL")," : $ZTRIGGER returned ",r," (expected ",expect,")",!
	set ^cnt=0,@gvn@(1)=1
	write $select(0=^cnt:"PASS",1:"FAIL")," : SET ",gvn,"(1) worked, and the trigger was invoked ",^cnt," times",!
	if expect do
	. if $data(nodeexpr) set @(gvn_"("_nodeexpr_")")=1
	. else  do
	. . set node=$select(spec["$CHAR":$translate($justify("",507)," ",$char(1)),1:$extract(spec,2,$length(spec)-1))
	. . set @gvn@(node)=1
	. write $select(1=^cnt:"PASS",1:"FAIL")," : SET ",gvn,"(<node>) invoked the trigger ",^cnt," times (expected 1)",!
	quit
	;
addd(gvn,spec)
	; Add a SET trigger on gvn(spec) while gvn has the standard collation, then give gvn collation 1 (with ^%GBLDEF, as
	; gvn has no data), so the key form of the string of 600 x's in spec (1200 bytes) no longer fits in a key
	new file,r
	set file="ztrigger_12.out"
	open file:append use file
	set r=$ztrigger("item","+"_gvn_"("_spec_") -commands=S -xecute=""set ^cnt=^cnt+1""")
	close file
	write $select(r=1:"PASS",1:"FAIL")," : $ZTRIGGER of the trigger on ",gvn," returned ",r," (expected 1)",!
	write $select($$set^%GBLDEF(gvn,0,1):"PASS",1:"FAIL")," : ",gvn," has collation 1",!
	quit
	;
setd	; In a new process (which loads the triggers of stage 12 with collation 1), SET ^d(1), ^e(1) and ^f(1) each issue
	; TRIGSUBS2BIG and store nothing, and after the triggers are deleted, the SETs work
	new $etrap,err,file,gvn,i
	for i=1:1:3 set gvn=$piece("^d,^e,^f",",",i) do
	. set err=""
	. set $etrap="set err=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit"
	. do setd1(gvn)
	. write $select(err="TRIGSUBS2BIG":"PASS",1:"FAIL")," : SET ",gvn,"(1) issued [",err,"] (expected TRIGSUBS2BIG)",!
	. write $select('$data(@gvn@(1)):"PASS",1:"FAIL")," : SET ",gvn,"(1) stored nothing",!
	set file="delete_13.out"
	open file:newversion use file
	if $ztrigger("item","-*")
	close file
	set $etrap="write ""FAIL : "",$piece($zstatus,"","",3,4),! set $ecode="""" halt"
	for i=1:1:3 set gvn=$piece("^d,^e,^f",",",i) do
	. set @gvn@(1)=1
	. write "PASS : SET ",gvn,"(1) worked after the triggers were deleted",!
	quit
	;
setd1(gvn)
	set @gvn@(1)=1
	quit
	;
sets	; After MUPIP TRIGGER rejected the trigger on ^b, check that SET ^b(1) works
	new $etrap
	set $etrap="write ""FAIL : "",$piece($zstatus,"","",3,4),! set $ecode="""" halt"
	set ^b(1)=1
	write "PASS : SET ^b(1) worked",!
	quit
