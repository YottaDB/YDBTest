c003412	;
	; C9L05-003412 Test that the GVIS secondary error (as part of GVSUBOFLOW error) does not print garbage
	;
	set $ztrap="do ztr"
	;
	set str1=$C(0,2)_"."_$C(0,0,0,0,0,0,0,2)
	set str2=".."_$C(0,0,0,0,0,0,3)_"lost+found"
	set str3=$C(0,0,0)_" var"_$C(0,0,0,0,0,0)
	set str4="@tmp"_$C(0,0,0,0,0)_"@home"
	set str5="nconfigassist.l"_$C(0,8)
	set str6="usr"_$C(0,0,0,0,0,9)_"lib"_$C(0,0,0,0,0,0)
	set str7="",$piece(str7,$c(1)_$c(0)_$c(2),128)=1
	;
	set num1=-123456789.123456789
	set num2=+1234567899.87654321
	set num3=+987654321.987654321
	set num4=-987654321.123456789
	;
	kill ^ZGBL
	set ^ZGBL(1,str1,2,str2,3,num1,3,str3,4,str4,num2,5,str6,6,str6,num3,7,num4,8,str7,9,str6,10,str5,$j(11,11),str4,12,str3,13,str2)=""
	zwrite ^ZGBL
	;
	quit
	;
ztr	;
	; $ZSTATUS will be a long line composed of the string concatenation of the below 3 lines
	;	150372986,c003412+18^c003412,
	;	%GTM-E-GVSUBOFLOW, Maximum combined length of subscripts exceeded,
	;	%GTM-I-GVIS, 		Global variable: ^ZGBL(1,$C(0,2)_"."_$C(0,0,0,0,0,0,0,2))
	; Out of this, we are only interested in the gvn starting with ^ZGBL as that is what will change with different keysizes
	; So print just that below.
	write $piece($zstatus,"Global variable: ",2),!
	halt
