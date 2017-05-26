bug301	s ^n="f i=1:1:5 s ^p=i,@(""x""_(i#100)_""=0"")"
	x ^n
	w !,"this should be 5: ",^p,!
	q
