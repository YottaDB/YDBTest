utf2hex ;
		;for i=1:1:^cntstr+1 do
		for i=1:1:^cntstr do
		. if (^utf8(i)'=-1) do
		. . set hexstr(i)=""
		. . set %S=^str(i)
		. . do ^%UTF2HEX
		. . ;write %U,!
		. . f j=1:1:$length(^utf8(i),",") do
		. . . set decstr(i)=$PIECE(^utf8(i),",",j)
		. . . ; for consistency as it is used in _utf2hex.m we will pass "2" to DH utility as well
		. . . set hexstr(i)=hexstr(i)_$$FUNC^%DH(decstr(i),2)
		. . do ^examine(%U,hexstr(i),"UTF2HEX of "_^str(i)_" "_^comments(i))
		. . set %S=""
		. . do ^%HEX2UTF
		. . do ^examine(%S,^str(i),"HEX2UTF of "_hexstr(i)_" "_^str(i)_^comments(i))
		. . ;write %S,!
		. . do ^examine($$FUNC^%UTF2HEX(^str(i)),hexstr(i),"$$FUNC^%UTF2HEX for "_^str(i)_^comments(i))
		. . do ^examine($$FUNC^%HEX2UTF(hexstr(i)),^str(i),"$$FUNC^%HEX2UTF for "_hexstr(i)_" "_^str(i)_^comments(i))
		do convertulongstr
		quit
convertulongstr;
		set %S=$$^ulongstr(1024*10)
        	set string=%S
        	write "do ^%UTF2HEX on 1024*10 bytes of unicode str",!
        	do ^%UTF2HEX
        	set hexdump=%U
        	set hexdump1="",hexdump2=""
        	for i=1:1:$length(string) do
        	. set %S=$e(string,i,i)
        	. do ^%UTF2HEX
        	. set hexdump1=hexdump1_%U
        	. set hexdump2=hexdump2_%U_","
        	if hexdump'=hexdump1 write "FAIL ^%UTF2HEX",!
        	else  write "PASS ^%UTF2HEX",!
		set %U=hexdump
        	write "do ^%HEX2UTF on 1024*10 bytes of unicode str",!
        	do ^%HEX2UTF
		set strdump=%S
		set strdump1=""
        	for i=1:1:$length(hexdump2,",")-1 do
        	. set %U=$piece(hexdump2,",",i)
        	. do ^%HEX2UTF
        	. set strdump1=strdump1_%S
        	if strdump'=strdump1 write "FAIL ^%HEX2UTF",!
        	else  write "PASS ^%HEX2UTF",!
misc;
		view "NOBADCHAR"
		s %U="FF00F01265"
		do ^%HEX2UTF
		zwr %S
		view "BADCHAR"
		s %U="FF00F01265"
		do ^%HEX2UTF
		zwr %S
		quit
oneMB ;
		; we cannot construct a 1MB string as such because UTF2HEX represents every byte read into two characters in the output
		; like if $c(10) is encountered the result is stored as 0A and not as A
		; so (1024*1024)/2 will make room for 1024*1024 1MB string
		; the 36 subtraction is because we have 6 unicode lietrals of 3 bytes each which is 18 bytes and everyone translated into output as 18*2
		; so make room for that as well
		set str="ＡＢＣ"_$$^longstr(((1024*1024)/2)-36)_"ａｂｃ" ; a 1MB %U result string
		set utf8="",hexstr=""
		set %S=str
		do ^%UTF2HEX
		; check the two ends of the string and that should be good enough because setting all the bytes into another tmp string is
		; not possible because of the max str size.
		set hexstr="EFBCA1EFBCA2EFBCA3EFBD81EFBD82EFBD83"
		; the 18 and 17 are number of bytes calculations for the beginning and end full width pieces check
		do ^examine($zextract(%U,1,18)_$zextract(%U,$zlength(%U)-17,$zlength(%U)),hexstr,"UTF2HEX of ONE MB STRING")
		quit
		set %S=""
		do ^%HEX2UTF
		do ^examine(%S,str,"HEX2UTF of ONE MB STRING")
		do ^examine($zextract(%U,1,18)_$zextract(%U,$zlength(%U)-17,$zlength(%U)),hexstr,"$$FUNC^%UTF2HEX for ONE MB STRING")
		do ^examine($$FUNC^%HEX2UTF(%U),str,"$$FUNC^%HEX2UTF for ONE MB STRING")
		quit
