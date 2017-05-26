ztrap	; Test of $ZTRAP set to invalid text - This test should "fail".
	Set $ZTRAP="junk"
	Write "Before fail",!
	Do fail
	Write "After fail",!
	Quit

fail	Write $DATA(@"1")	; Should fail due to invalid argument.
	Quit
