per2601	; ; ; test of overlapping databases with a local db hiding a name that's mapped to a remote db
	;
	s $zgbldir="mumps",(^a0,^a234567,^a2345670,^a2345678,^a3,^a765432,^a7654320,^a7654321,^a8)=1 k ^a765432,^a7654321 
	d minigd
	s $zgbldir="other",(^a0,^a234567,^a2345670,^a2345678,^a3,^a765432,^a7654320,^a7654321,^a8)=1
	d minigd
	s $zgbldir="local"
	d minigd
	d &rundown
	s $zgbldir="remote"
	d minigd
	d &rundown
	s ja="job^cmtst:(startup=""user:[partridge.work.v31]cmtstup"":schedule=""0 0:0:2"""
	q
minigd	s x="^%"
	w !
	f  s x=$o(@x) q:x=""  s r=$v("region",x) w !,x,?15,r,?35,$v("gvfile",r)
	q
