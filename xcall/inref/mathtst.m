mathtst	; Test C math package
	For value=1:1:5 D SQRT
	For value=1:1:5 D LOGB10
	For value=1:1:5 D LOGNAT
	For value=1:1:5 D EXP 
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
;
; Test EXP
;
EXP    S INPUT=value
        S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
        S INPUT=+INPUT
	W !,"Doing EXP for ",value,!
        D &xexp(INPUT,$LENGTH(INPUT),.RETDATA)
        W !,"EXP of ",value," = ",RETDATA,!
;
;
; Test LOG natural
;
LOGNAT  S INPUT=value
        S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
        S INPUT=+INPUT
	W !,"Doing natural LOG for ",value,!
        D &lognat(INPUT,$LENGTH(INPUT),.RETDATA)
        W !,"Natural LOG of ",value," = ",RETDATA,!
;
;
; Test LOG Base 10
;
LOGB10  S INPUT=value
        S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
        S INPUT=+INPUT
	W !,"Doing LOGB10 for ",value,!
        D &logb10(INPUT,$LENGTH(INPUT),.RETDATA)
        W !,"LOGB10 of ",value," = ",RETDATA,!

LOGB10L  S INPUT=value
         S RETDATA=" "
         F I=1:1:256 S RETDATA=RETDATA_" "
         S INPUT=+INPUT
	 W !,"Doing LOGB10LongName for ",value,!
         D &logb10l(INPUT,$LENGTH(INPUT),.RETDATA)
         W !,"LOGB10Longname of ",value," = ",RETDATA,!
;
; Test sqrt for long entryref
;
SQRTlONG    S INPUT=value
            S RETDATA=" "
            F I=1:1:256 S RETDATA=RETDATA_" "
            S INPUT=+INPUT
	    W !,"Doing SQRT under label SQRTLONG calling ref:xsqrtlonglabelforsqaurerootchk",value,!
            D &xsqrtlonglabelforsqaurerootchk(INPUT,$LENGTH(INPUT),.RETDATA)
            W !,"SQRT of ",value," = ",RETDATA,!
;
	 
 
