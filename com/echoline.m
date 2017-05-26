echoline
	; grab the $echoline as defined by the test system in test/com_u/submit_test.csh
	; if $echoline is not defiend, then this routine is being run outside the test
	; system.  Default to the last know valud of the $echoline
	set testsys=$ztrnlnm("echoline")
	if $length(testsys)>0 write $piece(testsys," ",2),!
	else  write "###################################################################",!
	quit
