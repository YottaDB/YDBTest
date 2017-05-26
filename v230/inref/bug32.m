main	d setup
	d proc
	d chk
	q
proc	;
	n (z,@z(z(0)))
	d chk
	q
chk	w !,$d(z),!,$d(def),!,$d(hij),!
	q
setup	S Z(0)="abc",Z("abc")="def",def="hij",hij="qwe"
	q
