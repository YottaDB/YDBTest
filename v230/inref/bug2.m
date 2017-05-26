	S X="A>B"
	S Y="A<B"
	S A=1,B=2
	I @X W "TRUE1",!
	E  W "FALSE1",!
	I @Y W "TRUE2",!
	E  W "FALSE2",!
	I A>B,@X W "TRUE3",!
	E  W "FALSE3",!
	I A>B,@Y W "TRUE4",!
	E  W "FALSE4",!
	I A<B,@X W "TRUE5",!
	E  W "FALSE5",!
	I A<B,@Y W "TRUE5",!
	E  W "FALSE5",!
	I @X,A>B W "TRUE6",!
	E  W "FALSE6",!
	I @Y,A>B W "TRUE7",!
	E  W "FALSE7",!
	I @X,A<B W "TRUE8",!
	E  W "FALSE8",!
	I @Y,A<B W "TRUE9",!
	E  W "FALSE9",!
