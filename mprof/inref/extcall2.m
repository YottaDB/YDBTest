extcall2	; Called by extcall to test calling of external subroutines
	W "ENTERED ^extcall2",! D LAB1^extcall W "ABOUT TO DO A",! D A W "A IS DONE",!
	W "DOING LAB1^extcall AGAIN" G LAB1^extcall
A	W "I AM AT LABEL A",!
