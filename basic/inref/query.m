query	; Test of $QUERY function
	New
	Do begin^header($TEXT(+0))

; Test for PER 001897:
; Test that $QUERY properly returns names that include quotes in subscripts
	Set errstep=errcnt
	Kill x
	Set x("a""b")=1
	Do ^examine($QUERY(x),"x(""a""""b"")","PER 001897 - x(""a""""b"")")

	Kill a
	Set a("\^AGCOM","]\""G""","IDATE_TASK","]\""A""","\IDATE_TASK")="x"
	Do ^examine($QUERY(a),"a(""\^AGCOM"",""]\""""G"""""",""IDATE_TASK"",""]\""""A"""""",""\IDATE_TASK"")","PER 001897")
	If errstep=errcnt Write "   PASS - PER 001897",!

	Do end^header($TEXT(+0))
	Quit
