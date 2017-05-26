begin(title)
	Write "## BEGIN PROGRAM - ",title,!
	Set errcnt=0
	Quit

end(title)
	Write "## END   PROGRAM - ",title
	If errcnt>0  Write "     Error count = ",errcnt
	Write !
	Quit
