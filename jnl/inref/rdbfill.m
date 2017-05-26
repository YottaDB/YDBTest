rt	;
	w " Single region TP TESTING"
	f i=1:1:1000  d
	.	ts ():(serial:transaction="BA")  
	.	s ^a(i)=$j(i,200)
	.	tcommit
	q
rn	;
	w " Single region NON_TP TESTING"
	f i=1:1:1000  d
	.	s ^a(i)=$j(i,200)
	q
ert	;
	w " Multi region TP TESTING"
	f i=1:1:5000  d
	.	ts ():(serial:transaction="BA")  
	.	s ^a(i)=$j(i,200)
	.	s ^b(i)=$j(i,200)
	.	s ^c(i)=$j(i,200)
	.	s ^d(i)=$j(i,200)
	.	s ^e(i)=$j(i,200)
	.	s ^f(i)=$j(i,200)
	.	s ^g(i)=$j(i,200)
	.	s ^h(i)=$j(i,200)
	.	s ^x(i)=$j(i,200)
	.	tcommit
	q
ern	;
	w " Multi region NON TP TESTING"
	f i=1:1:5000  d
	.	s ^a(i)=$j(i,200)
	.	s ^b(i)=$j(i,200)
	.	s ^c(i)=$j(i,200)
	.	s ^d(i)=$j(i,200)
	.	s ^e(i)=$j(i,200)
	.	s ^f(i)=$j(i,200)
	.	s ^g(i)=$j(i,200)
	.	s ^h(i)=$j(i,200)
	.	s ^x(i)=$j(i,200)
	q
rtid	;
	w " Single region TP TESTING"
	f i=1:1:100  d
	.	ts ():(serial:transaction="BA")  
	.	s ^x(i)=$j(i,200)
	.	tcommit
	q
