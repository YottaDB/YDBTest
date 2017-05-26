sq	;
t0	w ^["/a/b/c","beowulf"]GBL
t1	d tsq("/a/b/c","emotehost","GBL")
t2	d tsq("/b/c","beowulf","GBL")
t3	d tsq("a/a/b/c","beowulf","GBL")
tg	d tsq("/a/b/c","beowulf","GBL")
	d tsq("/a/b/c","beowulf","GBL")
	q
tsq(a,b,c) ;
	s x="^["""_a_""","""_b_"""]"_c
	w x,"= ",!
	w @x,!
	
