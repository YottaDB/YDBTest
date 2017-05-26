zgbltst	;
	s $zgbldir="a.gld"
	s ^a=1
	s x=^a
	d sub
	write "We ",$Select($data(^a):"can",1:"cannot")," see ^a",!
	write "We ",$Select($data(^b):"can",1:"cannot")," see ^b",!
	Quit

sub	new $zgbldir
	w "Inside sub: Global Directory ",$zgbldir,!
	s $zgbldir="b.gld"
	w "Now Global directory ",$zgbldir,!
	s ^b=1
	s x=^b
	q

