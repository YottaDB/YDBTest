jnl4G;
	zsy "date +""%d-%b-%Y %H:%M:%S"" > time0.txt"
	f i=1:1:150000 s ^a=$j(i,8000)
	f i=1:1:150000 s ^b=$j(i,8000)
	f i=1:1:150000 s ^c=$j(i,8000)
	f i=1:1:84060 s ^d=$j(i,8000)
	zsy "date +""%d-%b-%Y %H:%M:%S"" > time1.txt"
	f i=84061:1:84500 s ^d=$j(i,8000)
	q
