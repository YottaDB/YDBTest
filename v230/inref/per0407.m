per0407	;per0407 - local subscripts in E form evaluate to 0
	;
	k  s c=0
	f j=-10:.5:10 f k=-33:1:33 s a=j_"E"_k,a(+a)=a
	s x="",y=-10.1E33 f  s x=$o(a(x)) q:x=""  d test s y=x i c>10 w !,"Excessive errors, run aborted",! q
	w !,$s(c:"BAD result",1:"OK")," from test of local array E form subscripts"
	q
test	i x'=+a(x) s c=c+1 w !,"Subcript: ",a(x),!,"Expected: ",+a(x),!,"Returned: ",x
	i x'>y s c=c+1 w !,"Last subscript: ",y,!,"$Order returned: ",x
	q
