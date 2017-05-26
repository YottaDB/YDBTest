bug84	s c="x"
main	d ax
	s x=1 d whacko
	q
ax	n (b,c)
	s x=99 d whacko
	q
whacko	w @c,! k x
	q
