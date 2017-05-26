stringbad	;
	s v1="ab",v2="def"
	d CAT
	q
;
;
;
CAT	;
	w !,"Testing strcat",!
	S INPUT1=v1
	s INPUT2=v2
	S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
	d wcscat(INPUT1,INPUT2,.RETDATA)
	w "concat done by M : ",INPUT2_INPUT1,!
	w "concat done by C : ",RETDATA,!
	q

