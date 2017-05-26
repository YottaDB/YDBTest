stringtst	; 
	s v1="aβ3私c",v2="dはf"
	d CAT
	q
;
;
;
CAT	;
	w !,"Testing strcat",!
	w "concat by M before extcall : ",v2_v1,!
	S INPUT1=v1
	s INPUT2=v2
	S RETDATA=" "
        F I=1:1:256 S RETDATA=RETDATA_" "
	d &wcscat(INPUT1,INPUT2,.RETDATA)
	w "concat done by M : ",INPUT2_INPUT1,!
	w "concat done by C : ",RETDATA,!
	q

