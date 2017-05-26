;       M sample routine to test for LongLabels.
;
EXTLABEL()
        write "Iam extlabel for extvar check",!
        QUIT $ZD($h,"MON,DAY,YEAR")
;
SPLLABEL()
        write "Iam spllabel for extvar check",!
        QUIT $ZD($h,"MON,DAY,YEAR")
;
IAMLONGV()
        write "TEST-E-INCORRECT LABEL SELECTION ERROR",!
        SET X="ERROR"
        QUIT X
;
IAMLONGVARTOOLONGOFLENGTH31CHAR()
        write "Iam the long label for extvar check",!
        QUIT $ZD($h,"MON,DAY,YEAR")
;
