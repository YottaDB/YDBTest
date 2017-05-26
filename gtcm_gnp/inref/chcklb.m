chcklb	;
	F i=1:1:120 L ^b:0 Q:'$T  L -^b h 2
	if i=120 w "client side process did not lock ^b (or did exit). FAIL. Will not continue testing",!
	e  w "client side process did get the lock.It's OK to go on testing.",!
	q

