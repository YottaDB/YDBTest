zsubstr ;
		write !,"******* Testing ZSUBSTR *******",!
		for strx="abcd","ａｂｃｄ"  do
		. do ^examine($ZSUBSTR(strx,-100,-1),"","ERROR 1 from zsubstr")
		. do ^examine($ZSUBSTR(strx,-1,-1),"","ERROR 2 from zsubstr")
		. do ^examine($ZSUBSTR(strx,-1,-2),"","ERROR 3 from zsubstr")
		. do ^examine($ZSUBSTR(strx,0,-1),"","ERROR 4 from zsubstr")
		. do ^examine($ZSUBSTR(strx,0,0),"","ERROR 5 from zsubstr")
		. do ^examine($ZSUBSTR(strx),strx,"ERROR 6 from zsubstr")
		. do ^examine($ZSUBSTR(strx,1,-1),"","ERROR 7 from zsubstr")
		. do ^examine($ZSUBSTR(strx,0),strx,"ERROR 8 from zsubstr")
		. do ^examine($ZSUBSTR(strx,1),$EXTRACT(strx,1,$LENGTH(strx)),"ERROR 9 from zsubstr")
		. do ^examine($ZSUBSTR(strx,2),$EXTRACT(strx,2,$LENGTH(strx)),"ERROR 10 from zsubstr")
		. for ii=1:1:$LENGTH(strx) do ^examine($ZSUBSTR(strx,ii),$EXTRACT(strx,ii,$LENGTH(strx)),"ERROR 11 from zsubstr")
		. ;
		. do multiequal^examine($ZSUBSTR(strx,$LENGTH(strx)+1),$ZSUBSTR(strx,$LENGTH(strx)+100),"","ERROR 12 from zsubstr")
		. do multiequal^examine($ZSUBSTR(strx,1,0),$ZSUBSTR(strx,1,-1),$ZSUBSTR(strx,2,0),"","ERROR 13 from zsubstr")
		. do multiequal^examine($ZSUBSTR(strx,1,$ZLENGTH(strx)+1),$ZSUBSTR(strx,1,$ZLENGTH(strx)+100),strx,"ERROR 14 from zsubstr")
		;
onetwothreefour ;
		write !,"******* Testing ZSUBSTR on one byte,two bytes,three and four bytes char *******",!
		set char1="a"  ; one-byte char
		set char2="ç"  ; two-byte char
		set char3="＃" ; three-byte char
		set char4="󠄀"  ; four-byte char
		do ^examine($ZSUBSTR("a"_char1_"a",2,1),char1,"ERROR 1 from onetwothreefour")
		do ^examine($ZSUBSTR("a"_char2_"a",2,2),char2,"ERROR 2 from onetwothreefour")
		do ^examine($ZSUBSTR("a"_char3_"a",2,3),char3,"ERROR 3 from onetwothreefour")
		do ^examine($ZSUBSTR("a"_char4_"a",2,4),char4,"ERROR 4 from onetwothreefour")
		if ("UTF-8"=$ZCHSET) do
		. for charx=char2,char3,char4 do ^examine($ZSUBSTR("a"_charx_"a",2,1),"","ERROR 5 UTF-8 from onetwothreefour")
		. for charx=char3,char4 do ^examine($ZSUBSTR("a"_charx_"a",2,2),"","ERROR UTF-8 M from onetwothreefour")
		. for charx=char4 do ^examine($ZSUBSTR("a"_charx_"a",2,3),"","ERROR 7 UTF-8 from onetwothreefour")
		if ("M"=$ZCHSET) do
		. do ^examine($ZSUBSTR("a"_char2_"a",2,1),$ZCHAR(195),"ERROR 5 M from onetwothreefour")
		. do ^examine($ZSUBSTR("a"_char3_"a",2,2),$ZCHAR(239,188),"ERROR 6 M from onetwothreefour")
		. do ^examine($ZSUBSTR("a"_char4_"a",2,3),$ZCHAR(243,160,132),"ERROR 7 M from onetwothreefour")
		;
combining ;
		write !,"******* Testing ZSUBSTR on combining chars *******",!
		; combining characters:
		set strn="Türkçe" ; normalized chars
		set strnsubstr(1)="T"
		if ("M"=$ZCHSET) set strnsubstr(2)="T"_$ZCHAR(195)
		else  set strnsubstr(2)="T"
		set strnsubstr(3)="Tü"
		set strnsubstr(4)="Tür"
		set strnsubstr(5)="Türk"
		if ("M"=$ZCHSET) set strnsubstr(6)="Türk"_$ZCHAR(195)
		else  set strnsubstr(6)="Türk"
		set strnsubstr(7)="Türkç"
		set strnsubstr(8)="Türkçe"
		set strnsubstr(9)="Türkçe"
		set strc="Türkçe" ; using combination marks
		set strcsubstr(1)="T"
		set strcsubstr(2)="Tu"
		if ("M"=$ZCHSET) set strcsubstr(3)="Tu"_$ZCHAR(204)
		else  set strcsubstr(3)="Tu"
		set strcsubstr(4)="Tü"
		set strcsubstr(5)="Tür"
		set strcsubstr(6)="Türk"
		set strcsubstr(7)="Türkc"
		if ("M"=$ZCHSET) set strcsubstr(8)="Türkc"_$ZCHAR(204)
		else  set strcsubstr(8)="Türkc"
		set strcsubstr(9)="Türkç"
		set strcsubstr(10)="Türkçe"
		set strcsubstr(11)="Türkçe"
		for ii=1:1:$ZLENGTH(strn)+1 do ^examine($ZSUBSTR(strn,1,ii),strnsubstr(ii),"ERROR 1 from combining on "_ii_" subscript")
		for ii=1:1:$ZLENGTH(strc)+1 do ^examine($ZSUBSTR(strc,1,ii),strcsubstr(ii),"ERROR 2 from combining on "_ii_" subscript")
		;multiple combining characters on u, a cedilla, and a diaresis
		set strcmulti="ü̧"
		if ("M"=$ZCHSET) do
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-5,1),"u","ERROR 3 M from combining")
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-5,2),"u"_$ZCHAR(204),"ERROR 4 M from combining")
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-5,3),"ü","ERROR  5 M from combining")
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-5,4),"ü"_$ZCHAR(204),"ERROR 6 M from combining")
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-5,5),"ü̧","ERROR 7 M from combining") ; "u"_$CHAR(776,807) ;(0x0308, 0x0327)
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-3,1),"u","ERROR 3 UTF-8 from combining")
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-3,2),"u","ERROR 4 UTF-8 from combining")
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-3,3),"ü","ERROR 5 UTF-8 from combining")
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-3,4),"ü","ERROR 6 UTF-8 from combining")
		. do ^examine($ZSUBSTR(strcmulti,$LENGTH(strcmulti)-3,5),"ü̧","ERROR 7 UTF-8 from combining") ; "u"_$CHAR(776,807) ;(0x0308, 0x0327)
		;
somechinese ;
		write !,"******* Testing ZSUBSTR on some chinese chars *******",!
		set strch="我能吞下玻璃而不伤身体"
		if ("UTF-8"=$ZCHSET) set cnt=7
		else  set cnt=19
		set strchsubstr(1)="而"
		set strchsubstr(2)="而不"
		set strchsubstr(3)="而不伤"
		set strchsubstr(4)="而不伤身"
		set strchsubstr(5)="而不伤身体"
		set strchsubstr(6)="而不伤身体"
		set strchsubstr(7)="而不伤身体"
		set strchsubstr(8)="而不伤身体"
		set strchsubstr(9)="而不伤身体"
		set strchsubstr(10)="而不伤身体"
		set strchsubstr(11)="而不伤身体"
		for ii=1:1:11 do ^examine($ZSUBSTR(strch,cnt,3*ii),strchsubstr(ii),"ERROR from chinese characters, subscript "_ii_" failed")
		;
longoneMBstr ;
		write !,"******* Testing ZSUBSTR on a long one MB string *******",!
		set strlong="ａｂｃ"_$$^longstr(1048558)_"ａｂｃ" ; a 1MB string ==> 1048558 = 1024*1024-18
		do ^examine($ZSUBSTR(strlong,1,3),"ａ","the first character is a 3 byte ａ")
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($ZSUBSTR(strlong,1,2),"","the first character is a 3 byte ａ so a 2 byte substr will be null")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,1),"","the third last character is three bytes long 1")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,2),"","the third last character is three bytes long 2")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,3),"ａ","the third last character is three bytes long, it is ａ")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,4),"ａ","4 bytes, but only ａ can fit")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,5),"ａ","5 bytes, but only ａ can fit")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,6),"ａｂ","6 bytes, ａｂ can fit")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,7),"ａｂ","7 bytes, only ａｂ can fit")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,8),"ａｂ","8 bytes, only ａｂ can fit")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,9),"ａｂｃ","9 bytes, ａｂｃ can fit")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,10),"ａｂｃ","10 bytes, ａｂｃ can fit")
		if ("M"=$ZCHSET) do
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,2),$ZCHAR(239,189),"the third last byte is three bytes long 1")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,3),"ｃ","the third last byte is three bytes long, it is ａ")
		. do ^examine($ZSUBSTR(strlong,$LENGTH(strlong)-2,4),"ｃ","the third last byte is three bytes long, it is ａ")
		;
invalidmix ;
		; since we have byte by byte processing below we need to turn BADCHAR off
		if $VIEW("BADCHAR") do
		. set bch=1
		. view "NOBADCHAR"
		write !,"******* Testing ZSUBSTR on an invalid mix of bytes *******",!
		set strx=$ZCHAR(0,0,10,15,20,126,127,150,230,250,250,145) ; no valid multi-byte characters
		for ii=1:1:$ZLENGTH(strx) do ^examine($ZSUBSTR(strx,1,ii),$EXTRACT(strx,1,ii),"ERROR 1 from invalidmix on subscript "_ii)
		;
		set a=1114110,b=1114111
		set strx=$CHAR(1114100,1114105,a,b)
		for ii=1:1:$ZLENGTH(strx) do ^examine($ZSUBSTR(strx,1,ii),$EXTRACT(strx,1,ii\4),"ERROR 2 from invalidmix")
		for ii=1:1:$LENGTH(strx) do ^examine($ZSUBSTR(strx,ii,1),"","ERROR 3 from invalidmix")
		for ii=1:1:$LENGTH(strx) do ^examine($ZSUBSTR(strx,ii,3),"","ERROR 4 from invalidmix")
		for ii=1:1:$LENGTH(strx) do ^examine($ZSUBSTR(strx,ii,4),$EXTRACT(strx,ii),"ERROR 5 from invalidmix")
		;
		if $data(bch) view "BADCHAR"
		quit
