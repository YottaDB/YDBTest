	; The error handler that sets ZERROR appropriately by looking at
 	; the value of ZSTATUS

lab	w "done(lab^zeleaf)",! goto lab+2; Don't add/delete any lines till here
	w "done(lab+1^zeleaf)",!
	do report
	q
	
report	w "ZSTATUS = ",$zstatus,"  "
	s $zerror=$piece($zstatus,"%",2)
	w "ZERROR = ",$ze,!
	q

