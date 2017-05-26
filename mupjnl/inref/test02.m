test02;
	
	set status=1
	f i=1:1:100 if ^val(i)'=i set status=0
	if status=1 w "PASSED",!
	else  w "FAILED",!
