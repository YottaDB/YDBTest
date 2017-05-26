;       M sample routine to test for LongLabels.
;	To raise power of given two numbers
;
IAMLONGL(C,D)
        write "TEST-E-INCORRECT LABEL SELECTION ERROR in LONGFILENAME ROUTINE",!
        SET X=1
        IF B<0 SET B=-B
        FOR B=1:1:B S X=X*A
        QUIT X
;
IAMLONGLABELTOOLONGOFLENGTH31CH(C,D)
        write "Iam to raise power to long label numbers inside long filename",!
        SET X=1
        IF D<0 SET D=-D
        FOR D=1:1:D S X=X*C
        QUIT X
;
