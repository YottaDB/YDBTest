c2010;;
	s unix=$zv'["VMS"
	s ^a(1)="first"
	if unix zsy "$gtm_tst/com/abs_time.csh sincetime.txt"
	else  zsy "pipe write sys$output f$time() > sincetime.txt"
	h 1
	ZTSTART
		s ^a(2)="second"
	;	if unix zsy "$gtm_dist/mupip set -journal=""enable,on,before"" -reg ""*"""
		if unix zsy "$gtm_dist/mupip set -journal=enable,on,before -file mumps.dat"
		else  zsy "MUPIP set /journal=(enable,on,before) /file mumps.dat"
		s ^a(3)="third"
		k ^a(2)
		s ^a(4)="fourth"
	ZTCOMMIT

