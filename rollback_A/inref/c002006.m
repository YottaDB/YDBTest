c002006 ;
	q
dverify ;
	f i=1:1:5000  d  q
	. s tmp="val"_i
	. i ^newval(i)'=tmp w "** FAIL ",!,"^newval(",i,")=",^newval(i),! q
	q
