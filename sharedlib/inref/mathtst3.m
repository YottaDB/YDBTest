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
	Q
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
	Q

LOGB10L  S INPUT=value
         S RETDATA=" "
         F I=1:1:256 S RETDATA=RETDATA_" "
         S INPUT=+INPUT
	 W !,"Doing LOGB10LongName for ",value,!
         D &logb10l(INPUT,$LENGTH(INPUT),.RETDATA)
         W !,"LOGB10Longname of ",value," = ",RETDATA,!
	 Q
