pero0119	;per0119 - indirect goto returns
	; 
	s a="label"
	g @a
	w !,"BAD result: should NOT return"
	q
label	w !,"Indirect Goto"
	q
