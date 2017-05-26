c001824	;
	;
        for i=1:1:10  do
        .	tstart ():serial
        .	set ^x(i)=i
        .	tcommit
        quit
