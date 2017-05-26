tpmultireg;
		tstart ();serial
		set ^a(1)=1
		set ^b(1)=1
		tcommit
		tstart ();serial
		set ^b(2)=2
		set ^c(2)=2
		tcommit
		tstart ();serial
		set ^a(3)=3
		set ^b(3)=3
		tcommit
		quit

init; 
		;Sleep for 1 second so that the recovery init time noted,
		;is guaranteed to be atleast a second earlier than the time of first update
		h 1
		quit

inorder;
		tstart ();serial
		set ^b(1)=1
		set ^c(1)=1
		tcommit
		tstart ()
		set ^a(2)=2
		kill ^b(1)
		set ^c(2)=2
		tcommit
		quit
	
updaftrbrkn;
		tstart ()
		set ^b(1)=1
		set ^c(1)=1
		tcommit
		tstart ()
		set ^b(2)=2
		kill ^c(1)
		tcommit
		tstart ()
		set ^a(3)=3
		tcommit
		tstart ()
		set ^a(4)=4
		tcommit
		tstart ()
		set ^b(5)=5
		tcommit
		tstart ()
		set ^b(6)=6
		set ^c(6)=6
		tcommit
		quit

brkntransordr;
		tstart ()
		set ^b(1)=1
		set ^c(1)=1
		tcommit
		tstart ()
		set ^a(2)=1
		set ^c(2)=2
		tcommit
		quit

lostmultireg;
		tstart ()
		set ^b(1)=1
		set ^c(1)=1
		tcommit
		tstart ()
		set ^a(2)=2
		set ^b(2)=2
		tcommit
		tstart ()
		set ^b(3)=3
		set ^c(3)=3
		tcommit
		quit

goodaftrbrkn;
		tstart ()
		set ^b(1)=1
		set ^c(1)=1
		tcommit
		tstart ()
		set ^a(2)=2
		set ^b(2)=2
		tcommit
		h 2
		tstart ()
		set ^c(3)=3
		tcommit
		quit
