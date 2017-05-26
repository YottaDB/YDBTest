endtp3; endtp3.m is now seperate because of know problem in AIX
	w "S ^endloop3=1",!
	S ^endloop3=1
	f i=1:1:10 s ^lasttr(i)=i
	L ^permit3:1800
	if $t=1 w "Got lock on ^permit3, All processes have exited now",!
	else  w "TEST FAILED! Timed out in endtp3.csh for ^permit3 lock!"
	q
