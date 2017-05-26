lnkrtn; 
	w "in lnkrtn2",!
	quit
entry1; 
	w "in entry1^lnkrtn2",!
	set data2("digits")="0123456789"
	set data2("alpha")="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set data2("wspace")="!@#$%^&*(){}[]|\,./<>?`~;:"
	set data2("special")=$C(0,1,2,3,4,5,6,7,8,9,128,129,255)
	set data2("mixed")=data2("alpha")_data2("wspace")_data2("special")
	set data2("percent")="%"_data2("alpha")
	set data2("numeric")=123456789
	set data2("float")=123456789.123456789
	if cnt=1 set data2("cnt5")="This is literal number 5"
	if cnt=2 set x="data2(""cnt6"")" set @x="This is literal number 6"
	quit
entry2; 
	w "in entry2^lnkrtn2",!
	set newdata2(data2("digits"))="digits"
	set newdata2(data2("alpha"))="alpha"
	set newdata2(data2("wspace"))="wspace"
	set newdata2(data2("special"))="special"
	set newdata2(data2("mixed"))="mixed"
	set newdata2(data2("percent"))="percent"
	set newdata2(data2("numeric"))="numeric"
	set newdata2(data2("float"))="float"
	quit
entry3; 
	w "in entry3^lnkrtn2",!
	merge mrgdata2=data2
	quit
entry4; 
	w "in entry4^lnkrtn2",!
	do entry4^lnkrtn0
	quit
entry5; 
	w "in entry5^lnkrtn2",!
	merge lnkrtn1Tolnkrtn2Merge=data1
	quit
half(num)
	new halfnum
	set halfnum=num\2
	set half="half of "_num_" is "_halfnum
	quit half
