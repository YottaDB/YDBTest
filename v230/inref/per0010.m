per0010	;per0010 - ZBreak to a shareable image will ACCVIO
	;
	s c=1
	zb label:"s c=0"
label	w !,$s(c:"BAD result",1:"OK"),"from test of ZBREAK to a shareable image"
	q
