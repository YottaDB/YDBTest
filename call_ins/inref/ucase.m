ucase(word)
	set uppercase=$$FUNC^%UCASE(word)
	use 0
	write !,"M2(ucase.m) in C->M->C->M",!
	write "In M2:Upper case of '",word,"' is : ",uppercase,!
	quit uppercase
