per2601	; ; ; test of overlapping databases with a local db hiding a name that's mapped to a remote db
	;
	s vms=$zv["VMS"
	s $zgbldir="local",(^a0,^a234567,^a2345670,^a2345678,^a3,^a765432,^a7654320,^a7654321,^a8)=1 k ^a765432,^a7654321 
	d minigd
	s $zgbldir="other",(^a0,^a234567,^a2345670,^a2345678,^a3,^a765432,^a7654320,^a7654321,^a8)=1
	d minigd
	s $zgbldir="local"
	d minigd
	i vms d &rundown
	s $zgbldir="mumps",(^a234567,^a2345678,^a765432,^a7654321)=1
	d minigd
	i vms d &rundown
	q
minigd	
	d order(1)
	d order(-1)
	q
order(dir)
	s x=$s(dir=1:"^%",1:"^zzzzzzzz")
	w !
	f  s x=$o(@x,dir) q:x=""  s r=$v("region",x) w !,x,?15,r,?35,$v("gvfile",r)
	q
