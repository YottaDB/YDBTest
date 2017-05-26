set1;
	s unix=$zv'["VMS"
	f i=1:1:100  d
        . ts ():(serial:transaction="BA")
        . s ^a(i)="a"_i
        . s ^acc(i)="acc"_i
        . tc
        if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time1.txt"
	else  zsy "pipe show time > time1.txt"
        h 1
        q
set2;
	s unix=$zv'["VMS"
	f i=101:1:200 d
        . ts ():(serial:transaction="BA")
        . s ^a(i)="a"_i
        . s ^acc(i)="acc"_i
        . tc
	if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time2.txt"
        else  zsy "pipe show time > time2.txt"
        q
