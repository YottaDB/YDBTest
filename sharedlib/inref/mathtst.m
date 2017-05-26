mathtst	; Test C math package
	For value=1:1:5 D SQRT
	q
;
;
; Test sqrt
;
SQRT    S INPUT=value
        S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
        S INPUT=+INPUT
	W !,"Doing SQRT for ",value,!
        D &xsqrt(INPUT,$LENGTH(INPUT),.RETDATA)
        W !,"SQRT of ",value," = ",RETDATA,!
;
