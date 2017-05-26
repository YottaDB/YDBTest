per02276 ; This test should be the first to run on a newly created database.
	New
	Do begin^header($TEXT(+0))

; Test for PER 002276:
; Test for PER 002416:
	Set ^["mumps.gld"]I=1
	Lock ^A	       ; Would have crashed due to %SYSTEM-F-ACCVIO at this lock
	Write "   PASS - PER 002276,002416",!
	Lock

	Do end^header($TEXT(+0))
	Quit
