per0525	;per0525 - local subscripts problems
	;
	k
	s nul=$c(0),cpuo=$zgetjpi("","CPUTIM")
	f z=98:1:121 s a=$c(z),@a=$c(11)
	f j=-10:.1:9.9 w:j\1=j ! w ?$x\5+1*5,j f k=-33:1:33 s a=j_"E"_k,a(a)=a 
	f j=-10:.1:9.9 w:j\1=j ! w ?$x\5+1*5,j f k=-33:1:33 s a=j_"E"_k,a(+a)=a 
	W !,"OK from test of large local arrays"
	q
