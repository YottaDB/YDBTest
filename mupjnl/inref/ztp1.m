ztp1;
        h 2
	s unix=$zv'["VMS"
	if unix zsy "$gtm_tst/com/abs_time.csh time1.txt"
	else  zsy "pipe write sys$output f$time() > time1.txt"
	F i=1:1:10 S ^z1(i)=i
	Q
