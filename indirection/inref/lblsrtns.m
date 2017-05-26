LBLSRTNS
	write "Long Name test for label/routines indirection",!
	set longLbl8="label678"
	set longLbl89="label6789"
	set longLbl89012345678901234567890="label6789012345678901234567890"
	set longLbl890123456789012345678901="label67890123456789012345678901"
	set longRtn8="routine8"
	set longRtn89="routine89"
	set longRtn89012345678901234567890="routine89012345678901234567890"
	set longRtn890123456789012345678901="routine890123456789012345678901"
	
	do @longLbl8^@longRtn8,^examine(VCOMP,"Label8-Routine8","8 char label and 8 char routine")
	do @longLbl8^@longRtn89,^examine(VCOMP,"Label8-Routine9","8 char label and 9 char routine ")
	do @longLbl8^@longRtn89012345678901234567890,^examine(VCOMP,"Label8-Routine30","8 char label and 30 char routine ")
	do @longLbl8^@longRtn890123456789012345678901,^examine(VCOMP,"Label8-Routine31","8 char label and 31 char routine ")

	do @longLbl89^@longRtn8,^examine(VCOMP,"Label9-Routine8","9 char label and 8 char routine ")
	do @longLbl89^@longRtn89,^examine(VCOMP,"Label9-Routine9","9 char label and 9 char routine ")
	do @longLbl89^@longRtn89012345678901234567890,^examine(VCOMP,"Label9-Routine30","9 char label and 30 char routine ")
	do @longLbl89^@longRtn890123456789012345678901,^examine(VCOMP,"Label9-Routine31","9 char label and 31 char routine ")

	do @longLbl89012345678901234567890^@longRtn8,^examine(VCOMP,"Label30-Routine8","30 char label and 8 char routine ")
	do @longLbl89012345678901234567890^@longRtn89,^examine(VCOMP,"Label30-Routine9","30 char label and 9 char routine ")
	do @longLbl89012345678901234567890^@longRtn89012345678901234567890,^examine(VCOMP,"Label30-Routine30","30 char label and 30 char routine ")
	do @longLbl89012345678901234567890^@longRtn890123456789012345678901,^examine(VCOMP,"Label30-Routine31","30 char label and 31 char routine ")

	do @longLbl890123456789012345678901^@longRtn8,^examine(VCOMP,"Label31-Routine8","31 char label and 8 char routine ")
	do @longLbl890123456789012345678901^@longRtn89,^examine(VCOMP,"Label31-Routine9","31 char label and 9 char routine ")
	do @longLbl890123456789012345678901^@longRtn89012345678901234567890,^examine(VCOMP,"Label31-Routine30","31 char label and 30 char routine ")
	do @longLbl890123456789012345678901^@longRtn890123456789012345678901,^examine(VCOMP,"Label31-Routine31","31 char label and 31 char routine ")

	if ""=$get(errcnt) write "Long Name test for label/routines indirection PASS ",!
	else  write "Long Name test for label/routines indirection ** FAIL ** ",!
	quit

