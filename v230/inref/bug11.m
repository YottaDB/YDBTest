MAIN	S A="when in the course",B="of human events"
	W "TST1",!
	D TST1
	W "TST2",!
	D TST2
	W "FINI",!
	H 2
	Q
TST1	N (A)
	D TST2
	Q
TST2	W "A=",$D(A) W:$D(A) ?20,A
	W !
	W "B=",$D(B) W:$D(B) ?20,B
	W !
	Q
