ztp2;
	s unix=$zv'["VMS"
	if unix zsy "$gtm_tst/com/abs_time.csh time2.txt"
	else  zsy "pipe write sys$output f$time() > time2.txt"
	ZTSTART
		F i=1:1:10 S ^z21(i)=i
		if unix zsy "$gtm_dist/dse all -buff" ; this will write an epoch record into all regions
		else  zsy "dse all /buff"
		H 2
		if unix zsy "$gtm_tst/com/abs_time.csh time21.txt"
		else  zsy "pipe write sys$output f$time() > time21.txt"
		ZTSTART
			F i=1:1:10 S ^z22(i)=i
			if unix zsy "$gtm_dist/dse all -buff" ; this will write an EPOCH record in all regions
			else  zsy "dse all /buff"
			H 2
			if unix zsy "$gtm_tst/com/abs_time.csh time22.txt"
			else  zsy "pipe write sys$output f$time() > time22.txt"
		ZTCOMMIT
		F i=1:1:10 S ^z23(i)=i
		ZTSTART
			F i=1:1:10 S ^z24(i)=i
		ZTCOMMIT
	ZTCOMMIT
	Q
