verify3	;
	write "Application Level Check",!
	set error=0
	f i=1:1:1200 if ^a(i,"STR"_i)'=$j(i,800) W "Restore FAILD",! SET error=error+1
	if error=0 write "PASSED",!
	h
