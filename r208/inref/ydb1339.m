;################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;################################################################
; Helper M program for the r208/expr_too_deep-ydb1339 subtest. Each label compiles one kind of deeply nested
; expression and checks that the compiler issues EXPRTOODEEP and still works afterwards.
ydb1339
	quit

minus	; 100,000 unary minus operators
	do deep("x="_$$rep("-",100000)_"1")
	quit

paren	; 100,000 levels of parentheses
	do deep("x="_$$rep("(",100000)_"1"_$$rep(")",100000))
	quit

func	; 100,000 nested $LENGTH() calls
	do deep("x="_$$rep("$length(",100000)_"1"_$$rep(")",100000))
	quit

subs	; a local variable reference with 100,000 nested subscripts
	do deep("x="_$$rep("a(",100000)_"1"_$$rep(")",100000))
	quit

plus	; a chain of 100,000 + operators
	do deep("x=1"_$$rep("+1",100000))
	quit

and	; a chain of 100,000 & operators
	do deep("x=1"_$$rep("&1",100000))
	quit

xecute	; XECUTE of a SET with 30,000 unary minus operators (within the maximum XECUTE string length of 32,766 bytes)
	new status,y
	set status=""
	do tryx("set x="_$$rep("-",30000)_"1")
	write $select(status["EXPRTOODEEP":"PASS",1:"WRONG")," : XECUTE issues EXPRTOODEEP : $ZSTATUS=",status,!
	do tryx("set y=-1")
	write $select((""=status)&(-1=$get(y)):"PASS",1:"WRONG")," : a later XECUTE works : $ZSTATUS=",status,!
	quit

routine	; a routine with 2 lines nested too deeply, then 2 lines at exactly the maximum depths. The later lines
	; check that the compile errors in lines 3 and 4 leave no nesting level counted for the lines after them.
	new file,status,line
	set file="deep1339.m"
	open file:newversion use file
	write "deep1339",!
	write " set line(2)=1",!
	write " set line(3)="_$$rep("-",2000)_"1",!
	write " set line(4)=1"_$$rep("+1",5000),!
	write " set line(5)="_$$rep("-",1024)_"1",!
	write " set line(6)=1"_$$rep("+1",4095),!
	write " quit",!
	close file
	kill line
	write "# Compile deep1339.m with ZLINK; expect EXPRTOODEEP for lines 3 and 4",!
	zlink file
	write "# Run deep1339; expect lines 2, 5 and 6 to run and lines 3 and 4 to issue EXPRTOODEEP",!
	do tryrtn("^deep1339")
	write $select((status["EXPRTOODEEP")&(status["deep1339+2^deep1339"):"PASS",1:"WRONG")," : line 3 issues EXPRTOODEEP : $ZSTATUS=",status,!
	write $select(1=$get(line(2)):"PASS",1:"WRONG")," : line 2 ran",!
	do tryrtn("deep1339+3^deep1339")
	write $select((status["EXPRTOODEEP")&(status["deep1339+3^deep1339"):"PASS",1:"WRONG")," : line 4 issues EXPRTOODEEP : $ZSTATUS=",status,!
	do tryrtn("deep1339+4^deep1339")
	write $select((""=status)&(1=$get(line(5))):"PASS",1:"WRONG")," : line 5 (1,024 unary minus operators) runs and sets 1 : $ZSTATUS=",status,!
	write $select((""=status)&(4096=$get(line(6))):"PASS",1:"WRONG")," : line 6 (a chain of 4,095 + operators) runs and sets 4096 : $ZSTATUS=",status,!
	quit

limits	; expressions just inside the limits compile and evaluate correctly
	new status,x
	set status=""
	do try("x="_$$rep("(",1000)_"5"_$$rep(")",1000))
	write $select((""=status)&(5=$get(x)):"PASS",1:"WRONG")," : 1,000 levels of parentheses evaluate to 5 : $ZSTATUS=",status,!
	kill x
	do try("x=1"_$$rep("+1",4000))
	write $select((""=status)&(4001=$get(x)):"PASS",1:"WRONG")," : a chain of 4,000 + operators evaluates to 4001 : $ZSTATUS=",status,!
	kill x
	do try("x=1"_$$rep("&1",2000))
	write $select((""=status)&(1=$get(x)):"PASS",1:"WRONG")," : a chain of 2,000 & operators evaluates to 1 : $ZSTATUS=",status,!
	quit

deep(arg)	; SET @arg must issue EXPRTOODEEP, after which a SET with argument indirection must still compile and run
	new status,y
	set status=""
	do try(arg)
	write $select(status["EXPRTOODEEP":"PASS",1:"WRONG")," : SET with argument indirection issues EXPRTOODEEP : $ZSTATUS=",status,!
	do try("y=2+3")
	write $select((""=status)&(5=$get(y)):"PASS",1:"WRONG")," : a later SET with argument indirection works : $ZSTATUS=",status,!
	quit

	; Each try* label leaves out the error number at the start of $ZSTATUS, so the reference file does not
	; depend on the number that the message file assigns to EXPRTOODEEP.
try(arg)	; SET @arg and put any error in status (of the caller)
	new $etrap
	set status="",$etrap="set status=$piece($zstatus,"","",2,$length($zstatus,"","")),$ecode="""" quit"
	set @arg
	quit

tryx(cmd)	; XECUTE cmd and put any error in status (of the caller)
	new $etrap
	set status="",$etrap="set status=$piece($zstatus,"","",2,$length($zstatus,"","")),$ecode="""" quit"
	xecute cmd
	quit

tryrtn(entry)	; DO entry and put any error in status (of the caller)
	new $etrap
	set status="",$etrap="set status=$piece($zstatus,"","",2,$length($zstatus,"","")),$ecode="""" quit"
	do @entry
	quit

rep(str,cnt)	; returns str repeated cnt times
	new i,x
	set x=""
	for i=1:1:cnt set x=x_str
	quit x
