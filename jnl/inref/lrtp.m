	; dbfill5.m
in(act);;; wait for ^in4 to become 1, then start the first part of the fill
	
	W "PID: ",$J,!
	f i=1:1:100  D
	.	ts ():(serial:transaction="BA")
	.	i act="set"  s (^b(i))=i
	.	tc
	l ^lock
	s ^in4=^in4+1
	l
	;;; Database activity above should go to the first journal file.
	;;; Set ^in4 to 2 to tell the other process to start switching. 
	l ^test1($J)
	f i=101:1:200  D
	.	ts ():(serial:transaction="BA")
	.	i act="set"  s (^b(i))=i
	.	tc
	;;; ^in4 == 3 means that the switch has already been done.
	;;; the following activity should definitely go to the second journal file.
	l ^test2($J)
        f i=201:1:300  D
	.	ts ():(serial:transaction="BA")
	.	i act="set"  s (^b(i))=i
	.	tc
	l ^lock
	s ^in4=^in4+1
	l
	q
