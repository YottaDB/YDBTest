	; The error handler that sets ZERROR appropriately by looking at
 	; the value of ZSTATUS

labelinanothermoduleforzyerror	w "done(labelinanothermoduleforzyerror^zeleaf)",! goto labelinanothermoduleforzyerror+2; Don't add/delete any lines till here
	w "done(labelinanothermoduleforzyerror+1^zeleaf)",!
	do report
	q
	
report	w "ZSTATUS = ",$zstatus,"  "
	s $zerror=$piece($zstatus,"%",2)
	w "ZERROR = ",$zerror,!
	q

