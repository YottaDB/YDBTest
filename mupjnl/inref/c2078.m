c2078;
	h 1
	s unix=$zv'["VMS"
	if unix zsy "$gtm_tst/com/abs_time.csh time1.txt"
	else  zsy "pipe write sys$output f$time() > time1.txt"
	f i=1:1:100 do
	.	ZTSTART
	.	s ^a(i)=$j(i,200)
	.	s ^b(i)=$j(i,200)
	.	s ^x(i)=$j(i,200)
	.	ZTCOMMIT
	Q
