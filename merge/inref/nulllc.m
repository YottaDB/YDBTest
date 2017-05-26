nulllc;
        SET $ZT="SET $ZT="""" g ERROR^nulllc"
	W !,!,"nulllc:Test for MERGE into local (null subscript is disabled for locals)",!
	W "Using TP:",!
	W "view ""NOLVNULLSUBS""",!
	view "NOLVNULLSUBS"
	SET avar(-1000)="old"
	SET avar("dummy")="oldavar"
	SET ^varlongvariablenamesworkfornull("dummy")="error val"
	W "Next TP Will not COMMIT",!
	TSTART (avar):serial
        if $g(%e) trollback  k %e goto lab2
	W "M avar(1,2,3,4,5,6,7,8,9,10,11,12,13,14)=^varlongvariablenamesworkfornull",!  
	M avar(1,2,3,4,5,6,7,8,9,10,11,12,13,14)=^varlongvariablenamesworkfornull  
	W "Should not be here",!  Q
	trollback
	q
	;
lab2;
	K (avar,varlongvariablenamesworkfornull)
	KILL ^varlongvariablenamesworkfornull("dummy")
	W !,"In lab2",!
	if $GET(avar("dummy"))'="oldavar"   W "Test failed for avar",! Q
	if $GET(avar(-1000))'="old"  W "Test failed for avar",! Q
	K avar(-1000)
	K avar("dummy")
	if ($data(avar)) W "Test failed for avar",! Q
	;
        SET $ZT="SET $ZT="""" g ERROR^nulllc"
	SET bvar("root")="old root"
	SET ^varlongvariablenamesworkfornull("root")="error root"
	W "Next TP Will not COMMIT",!
	TSTART (bvar):serial
        if $g(%e) trollback  k %e goto lab3
	W "M ^vardum=^varlongvariablenamesworkfornull",!  
	M ^vardum=^varlongvariablenamesworkfornull
	W "M bvar(""root"")=^varlongvariablenamesworkfornull",!  
	M bvar("root")=^varlongvariablenamesworkfornull
	W "Should not be here",!  Q
	trollback
	q
	;
lab3;
	W !,"In lab3",!
	if ($data(^vardum)) W "Test failed for ^vardum",! Q
	if $GET(bvar("root"))'="old root" W "Test failed for bvar",! Q
	K bvar("root")
	K ^varlongvariablenamesworkfornull("root")
	if ($data(bvar)) W "Test failed for bvar",! Q
	;
        SET $ZT="SET $ZT="""" g ERROR^nulllc"
	W "Next TP Will not COMMIT",!
	TSTART (cvar):serial
        if $g(%e) trollback  k %e goto lab4
	W "M cvar(1,"")=^varlongvariablenamesworkfornull",!  
	M cvar(1,"")=^varlongvariablenamesworkfornull  
	W "Should not be here",!  Q
	trollback
	Q
lab4;
	W !,"In lab4",!
	if ($data(cvar)) W "Test failed for cvar",! Q
	;
	SET $ZTRAP="GOTO errcont^errcont" 
	W "Using Non-TP:",!
	W "Next Command Will fail",!
	W "M avar(1,2,3,4,5,6,7,8,9,10,11,12,13,14)=^varlongvariablenamesworkfornull",!  
	M avar(1,2,3,4,5,6,7,8,9,10,11,12,13,14)=^varlongvariablenamesworkfornull  
	W "Next Command Will fail",!
	W "M bbvar=^varlongvariablenamesworkfornull",!  
	M bbvar=^varlongvariablenamesworkfornull 
	W "Next Command Will fail",!
	W "M ccvar(1,"""")=^varlongvariablenamesworkfornull",!  
	M ccvar(1,"")=^varlongvariablenamesworkfornull  
	K (avar,bvar,bbvar,cvar)
	W "Final ZWR",!  ZWR
	W "End nulllc",!,!
	Q
ERROR;
        w "In Error trap",!
        if $tlevel s %e=1  w "Do a trestart",!  trestart
        w "End Error trap",!
        q
