; This test is written to ensure that $ZTRIGGER operates correctly irrespective of HOW the preceding M function ($order
; specifically) manipulates the gv_some_subsc_null and gv_last_subsc_null global variables. Depending on whether null
; subscripts were allowed/disallowed, the results were different. The tests below tries to capture all the known configurations
; test1 and test2 -> null subscripts DISALLOWED
; test3 and test4 -> null subscripts ALLOWED
;
init
	; Setup a simple trigger and a subscripted global
	do ^echoline
	write "In the init routine",!
	do text^dollarztrigger("trivialtfile^ztrignullsubs","trivial.trg")
	set res=$ztrigger("file","trivial.trg")
	set ^GBL("SUBS")="VALUE"
	do ^echoline
	quit

test1	;
	do ^echoline
	write "test1^ztrignullsubs",!
	set x=$order(^GBL("SUBS",""))
	set x=$ztrigger("select","*")
	do ^echoline
	quit

test2	;
	do ^echoline
	write "test2^ztrignullsubs",!
	set x=$order(^GBL("SUBS",""))
	set x=$ztrigger("select","^a*")
	do ^echoline
	quit

test3	;
	do ^echoline
	write "test3^ztrignullsubs",!
	zwrite ^GBL				; NOTE: zwrite invokes op_gvorder ($order) internally
	set x=$ztrigger("select")
	do ^echoline
	quit

test4	;
	do ^echoline
	write "test4^ztrignullsubs",!
	set x=$order(^GBL("SUBS",""))
	set x=$ztrigger("select","^a*")
	do ^echoline
	quit

trivialtfile
	;+^a(acn=:) -commands=S -xecute="set x=2" -name=trivial
