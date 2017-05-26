per0526	;PER0526 - each call to $RANDOM was adding 4 bytes to program size
	;
	k
	s sd="dum.dum" o sd 
	d test
	s a=$zgetjpi("","PAGFILCNT")
	f i=1:1:5000 d test
	w !,$s(a'=$zgetjpi("","PAGFILCNT"):"BAD result",1:"OK")," from partial test of stable image size"
	c sd:delete
	q
test	n (sd)
	s a1=$a("A"),a2=$a("AA",2)
	s c=$c(67)
	s d=$d(D)
	s e1=$E(c),e2=$E(c,1),e3=$e(c,1,2)
	s f2=$f("C",c),f3=$f("C",c,2)
	s fn2=$fn(1,""),fn3=$fn(1,"",0)
	s g=$g(G)
	s j2=$j(1,0),j3=$j(1,0,0)
	s l1=$l("L"),l2=$l("L",",")
	s n=$n(N(-1))
	s o=$o(O(""))
	s p2=$p(c,"\"),p3=$p(c,"\",1),p4=$p(c,"\",1,2)
	s r=$r(10)
	s s=$s(0:1,1:0)
	s t=$t(TEST)
	s tr2=$tr("TR","RT"),tr3=$tr("TR","RT","rt")
	u sd w "t" u ""
	c "" 
	h 0
	i 1
	e
	x "k k"
	l L
	o "" 
	s a(1)=1,a("A")="A"
	;r x:0	
	q
