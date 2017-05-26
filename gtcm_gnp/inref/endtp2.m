endtp2; endtp2.m is now seperate because of know problem in AIX
	w "S ^endloop2=1",!
	S ^endloop2=1
	f i=1:1:10 s ^lasttr(i)=i
	L ^permit2:1800
	if $t=1 w "Got lock on ^permit2, All processes have exited now",!
	else  w "TEST FAILED! Timed out in endtp2.csh for ^permit2 lock!"
	q
