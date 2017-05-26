;       M sample routine to test for LongLabels.
;
MYLABEL(A,B)
        write "Iam to raise power to the numbers",!
        SET X=1
        IF B<0 SET B=-B
        FOR B=1:1:B S X=X*A
        QUIT X
;
CUBE(X)
        write "Iam to Cube the numbers",!
        set val=X**3
        QUIT val
;
IAMLONGL(C,D)
        write "TEST-E-INCORRECT LABEL SELECTION ERROR",!
        SET X=1
        IF D<0 SET D=-D
        FOR D=1:1:D S X=X*C
        QUIT X
;
IAMLONGLABELTOOLONGOFLENGTH31CH(E,F)
        write "Iam to print average of two numbers",!
        SET X=1
        IF F<0 SET F=-F
        S X=E+F/2
        QUIT X
;
