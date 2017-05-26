nulltp;
        SET $ZT="SET $ZT="""" g ERROR^nulltp"
	W !,!,"nulltp started....",!
	W "view ""LVNULLSUBS""",!
	view "LVNULLSUBS"
	W "Test global to global:",!
	K ^atp,^ctp,^btp,^xtp,(varlongvariablenamesworkfornull)
	W "Next TP Will not COMMIT",!
	TSTART ():serial
        if $g(%e) trollback  k %e goto lab2
	W "M ^ctp=^varlongvariablenamesworkfornull",!  M ^ctp=^varlongvariablenamesworkfornull
	W "M ^btp=^varlongvariablenamesworkfornull",!  M ^btp=^varlongvariablenamesworkfornull
	TCOMMIT
	W "Should not be here"  Q
lab2;
	W !,"In lab2",!
	if ($data(^ctp)) w "TEST FAILED for ^ctp",! q
	if ($data(^btp)) w "TEST FAILED for ^btp",! q
	;
	TSTART ():serial
        if $g(%e) trollback  k %e goto lab3
	W "M ^ctp=^varlongvariablenamesworkfornull",!  M ^ctp=^varlongvariablenamesworkfornull
	TCOMMIT
	do ^nullfill("ver","^ctp")
lab3;
        SET $ZT="SET $ZT="""" g ERROR^nulltp"
	W !,"In lab3",!
	if ($data(^ctp)=0) w "TEST FAILED for ^ctp",! q
	;
	W !,!,"Test local to global",!
	W "Next TP Will not COMMIT",!
	TSTART ():serial
        if $g(%e) trollback  k %e goto lab4
	W "M ^xtp=varlongvariablenamesworkfornull",!  M ^xtp=varlongvariablenamesworkfornull
	W "M ^atp=varlongvariablenamesworkfornull",!  M ^atp=varlongvariablenamesworkfornull
	TCOMMIT
	W "Should not be here"  Q
lab4	;
	W !,"In lab4",!
	if ($data(^xtp)) w "TEST FAILED for ^xtp",! q
	if ($data(^atp)) w "TEST FAILED for ^atp",! q
	;
	TSTART ():serial
        if $g(%e) trollback  k %e goto lab5
	W "M ^xtp=varlongvariablenamesworkfornull",!  M ^xtp=varlongvariablenamesworkfornull
	TCOMMIT
	do ^nullfill("ver","^xtp")
	;
lab5;
	W !,"In lab5",!
	W !,!,"Test global into local (null enabled for local):",!
	TSTART ():serial
        if $g(%e) trollback  k %e goto lab6
	W "M avar(1,2,3,4,5,6,7,8,9,10,"""",12,13,14)=^varlongvariablenamesworkfornull",!
	M avar(1,2,3,4,5,6,7,8,9,10,"",12,13,14)=^varlongvariablenamesworkfornull
	TCOMMIT
	do ^nullfill("ver","avar(1,2,3,4,5,6,7,8,9,10,"""",12,13,14)")
lab6	;
        SET $ZT="SET $ZT="""" g ERROR^nulltp"
	W !,"In lab6",!
	TSTART ():serial
        if $g(%e) trollback  k %e goto lab7
	W "M bvar=^varlongvariablenamesworkfornull",!
	M bvar=^varlongvariablenamesworkfornull
	TCOMMIT
	do ^nullfill("ver","bvar")
lab7;
	W !,"nulltp finished",!
	Q
ERROR;
        w "In Error trap",!
        if $tlevel s %e=1 trestart
        w "End Error trap",!
        q
