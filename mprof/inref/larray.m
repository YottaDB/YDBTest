larray	; Test of $DATA, $ORDER, $NEXT
	New
	Do begin^header($TEXT(+0))

	Set errstep=errcnt
	Set a(1)="hi"
	Do test1
	If errcnt=errstep Write "   PASS  1",!

;  up/down test
	Set errstep=errcnt
	Kill a  For i=0:1:2  For j=0:0.0005:0.001  Set a(i+j)="DATA"_(i+j)
	Do test2
	If errcnt=errstep Write "   PASS  2a",!

	Set errstep=errcnt
	Kill a  For i=2:-1:0  For j=0.001:-0.0005:0  Set a(i+j)="DATA"_(i+j)
	Do test2
	If errcnt=errstep Write "   PASS  2b",!

	Set errstep=errcnt
	Kill a  For j=0:0.0005:0.001  For i=0:1:2  Set a(i+j)="DATA"_(i+j)
	Do test2
	If errcnt=errstep Write "   PASS  2c",!

	Do end^header($TEXT(+0))
	Quit

test1	; access a(1)
	Do ^examine($DATA(a),"10","$DATA(a)")
	Do ^examine($DATA(a(1)),"1","$DATA(a(1))")
	Do ^examine($DATA(a(2)),"0","$DATA(a(2))")
	Do ^examine($ORDER(a("")),"1","$ORDER(a(""""))")
	Do ^examine($ORDER(a(0.9999)),"1","$ORDER(a(0.9999))")
	Do ^examine($ORDER(a(0.1)),"1","$ORDER(a(0.1))")
	Do ^examine($ORDER(a(1.1)),"","$ORDER(a(1.1))")
	Do ^examine($ORDER(a(2)),"","$ORDER(a(2))")
	Do ^examine($NEXT(a(-1)),"1","$NEXT(a(-1))")
	Do ^examine($NEXT(a(0.9999)),"1","$NEXT(a(0.9999))")
	Do ^examine($NEXT(a(0.1)),"1","$NEXT(a(0.1))")
	Do ^examine($NEXT(a(1.1)),"-1","$NEXT(a(1.1))")
	Do ^examine($NEXT(a(2)),"-1","$NEXT(a(2))")
	Kill a
	Do ^examine($DATA(a),"0","$DATA(a)")
	Do ^examine($DATA(a(1)),"0","$DATA(a(1))")
	Quit

test2
	Do ^examine($DATA(a),"10","$DATA(a)  No value")
	Set a=""
	DO ^examine($DATA(a),"11","$DATA(a)  a=""""")
	Set x="",(q,r)=0

loop	Set x=$ORDER(a(x))
	Do ^examine(x,(q+r),"x '= (q+r)")
	Do ^examine($DATA(a(x)),"1","$DATA(a("_x_"))")
	Do ^examine(a(x),"DATA"_(q+r),"a("_x_")")
	Set r=r+0.0005  Set:r>0.001 q=q+1,r=0
	Goto loop:q<3

	Do ^examine($ORDER(a(x)),"","$ORDER(a(x))  End")
	Quit
