;       M sample routine to test for LongLabels.
;	To raise power of given two numbers
;
IAMLONGV()
        write "TEST-E-INCORRECT LABEL SELECTION ERROR in LONGFILENAME ROUTINE",!
	set X="ERROR"
        QUIT X
;
IAMlONGVARTOOLONGOFLENGTH31CHAR()
        write "Iam the long label for extvar check inside long filename",!
        QUIT $ZD($h,"MON,DAY,YEAR")
;
