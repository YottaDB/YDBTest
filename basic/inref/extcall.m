extcall	; Test calling of external subroutine
	D ^extcall2,LAB1,A^extcall2 G ^extcall2 W "IMPOSSIBLE1",! Q
LAB1	W "ENTERED LAB1^extcall1",!
	Q
