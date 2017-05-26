ztpnest;;
ztp1;
	zsy "$gtm_tst/com/abs_time.csh time1.txt"        
	F i=1:1:10 S ^z1(i)=i
	Q
ztp2;
	zsy "$gtm_tst/com/abs_time.csh time2.txt"        
	ZTS
		F i=1:1:10 S ^z21(i)=i
		zsy "$gtm_dist/dse all -buff" ; this will write an epoch record into all regions
		H 2
		zsy "$gtm_tst/com/abs_time.csh time21.txt"        
		ZTS
			F i=1:1:10 S ^z22(i)=i
			zsy "$gtm_dist/dse all -buff" ; this will write an EPOCH record in all regions
			H 2
			zsy "$gtm_tst/com/abs_time.csh time22.txt"        
		ZTC
		F i=1:1:10 S ^z23(i)=i
		ZTS
			F i=1:1:10 S ^z24(i)=i
		ZTC
	ZTC
	Q
ztp3;
	F i=1:1:10 S ^z3(i)=i
	zsy "$gtm_tst/com/abs_time.csh time3.txt"        
	Q



