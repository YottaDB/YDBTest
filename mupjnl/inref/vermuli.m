vermuli;
	s flag=0
	f i=1:1:10 if ^a(i)'=i*10 s flag=1
 	if flag=1 w "FAILED",!
 	else  w "PASSED",!
