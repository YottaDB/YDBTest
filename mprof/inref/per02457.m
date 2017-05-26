; a test of the emergency hashing algorithm
	New
	Do begin^header($TEXT(+0))

; Test for PER 002457:
	Set text=$TEXT(+1^per02457)
	Do ^examine(text,"; a test of the emergency hashing algorithm","PER 002457");
	If errcnt=0 Write "   PASS - PER 002457",!

	Do end^header($TEXT(+0))
	Quit
