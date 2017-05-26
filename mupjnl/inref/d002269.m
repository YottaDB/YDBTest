d002269;
	f i=1:2:2000 s ^x(i)=$j(i,1600)
	f i=2:2:2000 s ^x(i)=$j(i,3200)
	f i=3:4:2000 k ^x(i)
	q
dverify ;
	q
