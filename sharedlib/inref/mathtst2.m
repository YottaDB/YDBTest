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
