per0470	;per0470 - Problems with nested indirect Gotos
	;
	s c=0
	s x="@y",y="@z",z="lab1" g @x
	s c=c+1 w !,"indirect goto failed"
lab1	i $l($p($zpos,"^",2))=0 s c=c+1 w !,"indirect goto caused damage"
	w !,$s(c:"BAD result",1:"OK")," from test of indirect goto"
	q
