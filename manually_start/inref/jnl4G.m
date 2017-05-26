jnl4G;
	s unix=$zv'["VMS"
	if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time0.txt"
	else  zsy "pipe show time > time0.txt"
	f j=1:1:40 do
	  . ts ():(serial:transaction="BA")
	  . f i=1:1:4000  s num=i*j s ^a=$j(num,8000)
	  . tc
	f j=1:1:40 do
	  . ts ():(serial:transaction="BA")
	  . f i=1:1:4000 s num=i*j s ^b=$j(num,8000)
	  . tc
	f j=1:1:40 do
	  . ts ():(serial:transaction="BA")
	  . f i=1:1:4000 s num=i*j s ^c=$j(num,8000)
	  . tc
	f j=1:1:10 do
	  . ts ():(serial:transaction="BA")
	  . f i=1:1:4000 s num=i*j s ^d=$j(num,8000)
	  . tc
	if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time1.txt"
	else  zsy "pipe show time > time1.txt"
	h 2
	; the journal file will reach 4G in following part, so much smaller TP trans are used. - zhouc - 08/22/03
	f j=101:1:109 do
	  . ts ():(serial:transaction="BA")
	  . f i=1:1:400 s num=i*j s ^d=$j(num,8000)
	  . tc
        f j=1:1:1110 do
	  . ts ():(serial:transaction="BA")
	  . ;f i=1:1:40 s num=i*j s ^d=$j(num,8000)
	  . s ^d=$j(j,8000)
	  . tc
	q
dverify(replic);
	set error=0
	set num=40*4000
	set val=$j(num,8000)
	i ^a'=val w "** FAIL ",!,"^a = ",^a,! set error=1 q
	i ^b'=val w "** FAIL ",!,"^b = ",^b,! set error=1 q
	i ^c'=val w "** FAIL ",!,"^c = ",^c,! set error=1 q
	if 'replic do
	.	set val=$j(1110,8000)
	.	i ^d'=val w "** FAIL ",!,"^d = ",^d,! set error=1 q
	else  do
	.	set num=9*4000
	.	set val=$j(num,8000)
	.	i ^d'=val w "** FAIL ",!,"^d = ",^d,! set error=1 q
	if 'error w "VERIFICATION PASSED",!
	else  w "VERIFICATION FAILED",!
	quit
