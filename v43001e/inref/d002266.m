d002266	;
        set ^stop=0
        set jmaxwait=0
        do ^job("start^d002266",2,"""""")
        quit
start	;
	; the d ^job done above will set the local variable "jobindex" to 1, 2, ... depending on the job number
	;
        if jobindex=1  do
        .       for i=1:1  quit:^stop>1  set ^x($j,i)=$j(i,470)  hang 1
        if jobindex=2  do
        .       for i=1:1  quit:^stop>0  set ^x($j,i)=$j(i,470)  hang 1
        .       for i=1:1  quit:^stop>1  set ^x($j,i)=$j(i,470)
        quit
wait	;
	do wait^job
	quit
