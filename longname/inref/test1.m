test;
	new $ZT
	set $ZT="set $ZT="""" g ERROR^testmain"
labelcalledbystpmovetest1;
	if $data(cnt)=0 set cnt=1
	if cnt=1 set alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	if cnt=1 set wspace="!@#$%^&*(){}[]|\,./<>?`~;:"
	if cnt=1 set ialpha="main1"
	if cnt=1 set @ialpha=alpha
	if cnt=1 set main2=alpha
	if cnt=1 set main3=wspace
	if cnt=2 set arrv1("digits")=digits
	if cnt=2 set arrv1("pi")=pi
	if cnt=3 set arrv1("main1")=main1
	if cnt=3 set arrv1("main2")=main2
	if cnt=3 set arrv1("main3")=main3
	if cnt=4 set arrv1("alpha")=alpha
	if cnt=4 set arrv1("wspace")=wspace
	if cnt<5 set arrv1("lit1")="This is a literal"
	if cnt<5 set arrv1("lit2")="This is a literal"
	if cnt=5 merge arrv1("fromtest2")=arrv2
	quit
labelcalledbystpmovetest2;
	set lb2var="This is labelcalledbystpmovetest2^test1"
	set var2="Literal one of labelcalledbystpmovetest2^test1"
	quit
functioncalledbystpmovetest1(index);
	if index=1 set fnret1="Literal Ret 1"
	if index=2 set fnret1="Literal Ret"
	if index=3 set fnret1="Literal Ret 3"
	if index=4 set fnret1="Literal Ret"
	set index=fnret1
	set fun1ret=fnret1
	quit fnret1
