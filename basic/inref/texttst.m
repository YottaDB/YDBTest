STS	W "$TEXT TEST",!,!
IN	W $T(OUT+1),!,!
	W $T(STS+2),!,!
	W $T(STS+-1),!,!
OUT
	W $T(OUT+-1),!,!
	W $T(+5),!,!
	W $T(+0),!,!
	W $T(STS),!,!
	W $T(IN),!,!
	W $T(+3),!,!
	W "FINISHED",!
	D ST^text1
	D IN^text2
	D ^text3
	D ^text1
