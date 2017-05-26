toolong	; test what happens if the label names are more than 31 chars
x23456789012345678901234567890a
	write "label1",!,$zposition,!  quit
x23456789012345678901234567890b
	write "label2",!,$zposition,!  quit
x23456789012345678901234567890c
	write "label3",!,$zposition,!  quit
	quit
