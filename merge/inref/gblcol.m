gblcol;
	set ^prefix="^"
	W "d ^colfill(""set"",15)",!  d ^colfill("set",15)
	W "d ^colfill(""ver"",15)",!  d ^colfill("ver",15)
	set fname="col1.out"  open fname:new   use fname      
	zwrite ^A,^B
	close fname
	;
	w "M newvar(""^A"")=^A",!  M newvar("^A")=^A
	W "M newvar(""^B"")=^B",!  M newvar("^B")=^B
	;
	zshow "v":zshowvar(1)
	w "d ^colfill(""ver"",15)",!  d ^colfill("ver",15)
	;
	set fname="col2.out"  open fname:new   use fname      
	zwrite ^A,^B
	close fname
	;
	w "K ^A,^B",!  K ^A,^B
	;
	w "M ^A=newvar(""^A"")",!  M ^A=newvar("^A")
	w "M ^B=newvar(""^B"")",!  M ^B=newvar("^B")
	W "K newvar",!  K newvar
	;
	zshow "v":zshowvar(2)
	W "d ^colfill(""ver"",15)",!  d ^colfill("ver",15)
	;
	set fname="col3.out"  open fname:new   use fname      
	zwrite ^A,^B
	close fname
	;
	set fname="zshowgbl.out"  open fname:new   use fname      
	zwrite zshowvar
	close fname
	Q
