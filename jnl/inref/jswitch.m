in(act);;; wait for ^in4 to become 1, then start the first part of the fill
	
	W "PID: ",$J,!
	f i=1:1:100  D
	.	i act="set"  s (^a(i))=i
	.	i act="set"  s (^b(i))=i
	.	i act="set"  s (^c(i))=i
	.	i act="set"  s (^d(i))=i
	l ^lock
	s ^in4=^in4+1
	l -^lock
	;;; Database activity above should go to the first journal file.
	;;; Set ^in4 to 2 to tell the other process to start switching. 
	l ^test1($J)
	f i=101:1:200  D
	.	i act="set"  s (^a(i))=i
	.	i act="set"  s (^b(i))=i
	.	i act="set"  s (^c(i))=i
	.	i act="set"  s (^d(i))=i
	;;; the following activity should definitely go to the second journal file.
	l ^test2($J)
        f i=201:1:300  D
	.	i act="set"  s (^a(i))=i
	.	i act="set"  s (^b(i))=i
	.	i act="set"  s (^c(i))=i
	.	i act="set"  s (^d(i))=i
	l ^lock
	s ^in4=^in4+1
	l -^lock
	;;; Database activity above should go to the second journal file.
	;;; the following activity should definitely go to the third journal file.
	l ^test3($J)
	f i=301:1:400  D
	.	i act="set"  s (^a(i))=i
	.	i act="set"  s (^b(i))=i
	.	i act="set"  s (^c(i))=i
	.	i act="set"  s (^d(i))=i
	l ^lock
	s ^in4=^in4+1
	l -^lock
	;;; Database activity above should go to the third journal file.
	;;; the following activity should definitely go to the fourth journal file.
	l ^test4($J)
	f i=401:1:500  D
	.	i act="set"  s (^a(i))=i
	.	i act="set"  s (^b(i))=i
	.	i act="set"  s (^c(i))=i
	.	i act="set"  s (^d(i))=i
	l ^lock
	s ^in4=^in4+1
	l -^lock
	q
