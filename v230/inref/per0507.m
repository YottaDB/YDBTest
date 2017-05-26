per0507	;per0507 - set indirect problems
	;
	s c=0
	s b=0,a="b",^c=1,@a=^c i b=0 s c=c+1 w !,"set indirect failed @ ",$zpos
	s b=0,c(1)=1,@a=c(1) i b=0 s c=c+1 w !,"set indirect failed @ ",$zpos
	s b=0,a="@^c",^c="b",@a=c(1) i b=0 s c=c+1 w !,"set indirect failed @ ",$zpos
	s b=0,a="@c(1)",c(1)="b",^c=1,@a=^c i b=0 s c=c+1 w !,"set indirect failed @ ",$zpos
	w !,$s(c:"BAD result",1:"OK")," from test of set indirection"
	q
