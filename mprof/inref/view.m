view	; Test of $VIEW function.
	New
	Do begin^header($TEXT(+0))

; Test RTNNEXT keyword
; Test for PER 002184:
	Set errstep=errcnt
	Set file="_AAAAAAA.m"
	Open file:NEWVERSION
	Use file  Write "viewtst",!," Quit"  Close file
	ZLINK file
	Do ^examine($VIEW("RTNNEXT",""),"%AAAAAAA","PER 002184 - $VIEW(""RTNNEXT"","""")")
	If errstep=errcnt Write "   PASS - PER 002184",!

; Test for PER 002277:
	Set errstep=errcnt
	Set file1="DUMMY1.m",file2="DUMMY2.m"
	Open file1:NEWVERSION   Open file2:NEWVERSION
	Use file1 Write "viewtst",!," Quit"  Close file1
	Use file2 Write "viewtst",!," Quit"  Close file2
	ZLINK file1,file2
	Do ^examine($VIEW("rtnnext","DUMMY1"),"DUMMY2","PER 002277 - $VIEW(""rtnnext"",""DUMMY1"")")
	If errstep=errcnt Write "   PASS - PER 002277",!

; End RTNNEXT
	Do end^header($TEXT(+0))
	Quit
