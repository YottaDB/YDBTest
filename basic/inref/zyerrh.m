	; handler that doesn't contain 'quit'
	
report	w "ZSTATUS = ",$zstatus,"  "
	s $zerror=$piece($zstatus,"%",2)
	w "ZERROR = ",$zerror,!

