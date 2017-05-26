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
	Q
;
; Test sqrt for long entryref
;
SQRTlONG    S INPUT=value
            S RETDATA=" "
            F I=1:1:256 S RETDATA=RETDATA_" "
            S INPUT=+INPUT
	    W !,"Doing SQRT under label SQRTLONG calling ref:xsqrtlonglabelforsqaurerootchk ",value,!
            D &xsqrtlonglabelforsqaurerootchk(INPUT,$LENGTH(INPUT),.RETDATA)
            W !,"SQRT of ",value," = ",RETDATA,!
	    Q
;
	 
