locksub1; test that local subscripted variables are restored after an error and trap to parent level
	; and that the cleanup is not pathological
	k ^Fail
	s ^Fail=0
	s cnt=0
	s $zt="zg "_$zl_":onn"
	s a(1)=1
	d new
onn	w !,$zpos i $d(a(1)),a(1)=1
	e  s cnt=cnt+1,^Fail=^Fail+1
	s $zt="zg "_$zl_":onxn"
	s b(1)=1
	d xnew
onxn	w !,$zpos i $d(b(1)),b(1)=1
	e  s cnt=cnt+1,^Fail=^Fail+1
	s $zt="zg "_$zl_":ondoprm"
	s c(1)=1
	d parm(3)
ondoprm	w !,$zpos i $d(c(1)),c(1)=1
	e  s cnt=cnt+1,^Fail=^Fail+1
	s $zt="g onk"
	s d(1)=1
	k d
	w 1/0
onk	w !,$zpos s $zt="g onzw"
	s e(1)=1
	zwithdraw e(1)
	w 1/0
onzw	w !,$zpos s $zt="g onxk"
	s (f(1),g(1),h(1),k(1),j(1))=1
	k (cnt)
	w 1/0
onxk	w !,$zpos s $zt="g end"
	s l(1)=x
end	i $d(l) s cnt=cnt+1,^Fail=^Fail+1
	if ^Fail'=cnt w "^Fail and count mismatch. cnt was no restored properly",!
	w !,$s(cnt:"BAD",1:"OK")," from lsubtst"
	q
new	n a
	w 1/0
	q
xnew	n (cnt)
	w 1/0
	q
parm(c)
	w 1/0
	q
