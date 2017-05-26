bkgrndset;
	set ^stopbg=0
	set unix=$ZVersion'["VMS"
        if unix set pid=$J
	else  set pid=$$FUNC^%DH($J)
        set file="ver_alternate.out"
        open file:(newversion)
        use file
	write pid,!
	close file
	for i=1:1 quit:^stopbg=1  do switchver
switchver;
	if unix zsy "$gtm_tst/$tst/u_inref/bkgrnd_mupip_set.csh"
	else  zsy "@vinrefdir:bkgrnd_mupip_set.com"
