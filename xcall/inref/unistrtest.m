unistrtest	;Test the multibyte/widechar string operations in C
	s value="1a2b3c4d"
	D LEN
	s value="2β3私4𠞉5"
	D LEN
	s v1="2β3私",v2="3私は_𠞉𠟠_4"  ; 3<2byte><2byte>_<4byte><4byte>_4
	d CAT
	d CPY
	q
;
LEN	;
	w !,"Testing strlen",!
	S INPUT=value
        S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
	w "ZLength of ",value," computed by M = ",$zl(INPUT),!
	w "Length of ",value," computed by M = ",$l(INPUT),!
        D &wcslen(INPUT,.RETDATA)
        W "Length of ",value," computed by C = ",RETDATA,!
	Q
;
CAT	;
	w !,"Testing strcat",!
	S INPUT1=v1,INPUT2=v2
	S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
	d &wcscat(INPUT1,INPUT2,.RETDATA)
	w "concat done by M : ",INPUT2_INPUT1,!
	w "concat done by C : ",RETDATA,!
	q

CPY	;
	w !,"Testing strcpy",!
	S INPUT1=v1
        S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
	d &wcscpy(INPUT1,.RETDATA)
	w "expected output  :",INPUT1,!
	w "strcpy done by C :",RETDATA,!
	q

