d002016;
	w $zv,!
	view "NOISOLATION":"+^ZNOISO"
	s curr=100
	s ^ZNOISO($j)=curr
	f i=1:1:100  d 
	.	tstart (curr):serial
	.	f j=1:1:100  d
	.	.	s old=^ZNOISO($j)
	.	.	i old'=curr w !,"Test failed... Zshow 'V' dump follows",! zsh "V"  h
	.	.	s ^ZNOISO($j)=old+1
	.	.	s curr=old+1
	.	h 1
	.	tcommit
	q
