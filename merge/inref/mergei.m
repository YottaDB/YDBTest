mergei;
	NEW $ZTRAP
	SET $ZTRAP="GOTO errcont^errcont"
LCLLCL;
	W "1: Local : Local",!
	SET bvar("def",456,7)="VALUE1"
	M avar(123,"abc")=bvar("def",456,7)
	if avar(123,"abc")="VALUE1" w "1:PASS",!
	zwr avar,bvar  K
	;
	W "2:@CMD",!
	SET bvar("def",456,7)="VALUE2"
	SET cmd="avar(123,""abc"")=bvar(""def"",456,7)"
	M @cmd
	ZSHOW "V"  K
	;
	W "3:Local : @Local",!
	SET bvar("def",456,7)="VALUE3"
	SET rhs="bvar(""def"",456,7)"
	M avar(123,"abc")=@rhs
	ZSHOW "V"  K
	;
	W "4:@Local : Local",!
	SET bvar("def",456,7)="VALUE4"
	SET lhs="avar(123,""abc"")"
	M @lhs=bvar("def",456,7)
	ZSHOW "V"  K
	;
	W "5:@Local : @Local",!
	SET lhs="avar(123,""abc"")"
	SET rhs="bvar(""def"",456,7)"
	SET bvar("def",456,7)="VALUE5"
	M @lhs=@rhs
	ZSHOW "V"  K
	;
	W "6:@Local : Local",!
	SET lhs="avar"
	SET bvar("def",456,7)="VALUE1"
	M @lhs=bvar("def",456,7)
	ZSHOW "V" K
	;
	W "7:Local : @Local",!
	SET avar(1)="VALUE11"
	SET avar(1,2)="VALUE112"
	SET rhs="avar"
	M bvar=@rhs
	ZSHOW "V"  K
	;
	W "8:Nested Indirection",!
	Set nestrhs="@avar"
	Set avar="bvar(1)"  
	Set bvar(1)="Actual Value of nestrhs"
	M newvar("foo")=@nestrhs
	ZSHOW "v"  K
	;
	W "9:Nested Indirection",!
	Set cvar="Root_cvar"
	Set cvar(1)="Root_cvar(1)"
	Set nestlhs="@avar"
	Set avar="bvar(1)"  
	M @nestlhs=cvar
	;
	ZSHOW "v"  K
	W "10:@LCL1=LCL2:LCL1 will have new variable  ",!
	s abc="def"
	set rhs(1,55,99.99,"aa")="If def has it then PASS"
	M @abc=rhs
	ZSHOW "v"
	set rhs(1,55,99.99,"aa")="If new1 has it then PASS"
	s abc="new1(1,4,""aaa"")"
	M @abc=rhs
	ZSHOW "v" 
	M @abc=rhs(1)
	W "10:@""lv"":LCL1 will have new variable  ",!
	M @"new1"=def
	M @"new1(1,2)"=def
	M @"new1(1,2,3)"=@"def"
	ZSHOW "v"  K
	Q
GBLGBL;
	W "Global: Global",!
	SET ^bvar("def",456,7)="VALUE1"
	M ^avar(123,"abc")=^bvar("def",456,7)
	zwr ^avar,^bvar  K ^avar,^bvar
	W "@CMD",!
	SET ^bvar("def",456,7)="VALUE1"
	SET cmd="^avar(123,""abc"")=^bvar(""def"",456,7)"
	M @cmd
	zwr ^avar,^bvar  K ^avar,^bvar
	W "@Global : Global",!
	SET ^bvar("def",456,7)="VALUE1"
	SET lhs="^avar(123,""abc"")"
	M @lhs=^bvar("def",456,7)
	zwr ^avar,^bvar  K ^avar,^bvar
	SET ^bvar("def",456,7)="VALUE1"
	SET lhs="^avar(123,""abc"")"
	SET rhs="^bvar(""def"",456,7)"
	W "@Local : @Local",!
	M @lhs=@rhs
	zwr ^avar,^bvar  K ^avar,^bvar
