test;
	new $ZT
	set $ZT="set $ZT="""" g ERROR^testmain"
labelcalledbystpmovetest1;
	if $data(cnt)=0 set cnt=1
	if cnt=1 set digits="0123456789"
	if cnt=1 set pi=3.141592
	if cnt=1 set @"qwspace"=wspace
	if cnt=2 set arrv2("alpha")=alpha
	if cnt=2 set arrv2("wspace")=wspace
	if cnt=3 set arrv2("digits")=digits
	if cnt=3 set arrv2("pi")=pi
	if cnt<4 set arrv2("lit1")="This is a literal"
	if cnt<4 set arrv2("lit2")="This is a literal"
	if cnt=5 merge arrv2("fromtest1")=arrv1
	quit
labelcalledbystpmovetest2;
	set lb2var="This is labelcalledbystpmovetest2^test2"
	set var22="This is labelcalledbystpmovetest2^test2"
	quit
functioncalledbystpmovetest2(index);
	if index=1 set fnret2="Literal Ret 1"
	if index=2 set fnret2="Literal Ret"
	if index=3 set fnret2="Literal Ret 3"
	if index=4 set fnret2="Literal Ret"
	set index=fnret2
	set fun2ret=index
	quit fnret2
