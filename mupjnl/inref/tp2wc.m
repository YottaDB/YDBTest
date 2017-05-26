tp2tr;
	S unix=$zv'["VMS"
	if unix zsy "$gtm_tst/com/abs_time.csh time2.txt"
	else  zsy "pipe write sys$output f$time() > time2.txt" 
	TSTART
		F i=1:1:10 S ^z21(i)=i
		if unix zsy "$gtm_dist/dse all -buff" ; this will write an epoch record into all regions
		else  zsy "DSE all /buff"
		H 2
		if unix zsy "$gtm_tst/com/abs_time.csh time21.txt"
		else  zsy "pipe write sys$output f$time() > time21.txt" 
		TSTART
			F i=1:1:10 S ^z22(i)=i
			; following will write an EPOCH record in all regions
			if unix zsy "$gtm_dist/dse all -buff" 
			else  zsy "DSE all /buff"
			H 2
			if unix zsy "$gtm_tst/com/abs_time.csh time22.txt"
			else  zsy "pipe write sys$output f$time() > time22.txt" 
		TCOMMIT
		F i=1:1:10 S ^z23(i)=i
		TSTART
			F i=1:1:10 S ^z24(i)=i
		TROLLBACK 1	
	;TCOMMIT
	Q
