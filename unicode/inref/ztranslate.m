ztranslate ;
		; since we have byte by byte processing below we need to turn BADCHAR off
		if $VIEW("BADCHAR") do
		. set bch=1
		. view "NOBADCHAR"
		write !,"Testing ZTRANSLATE",!
		set fullwidthA=$ZCHAR(239,188,161)
		set hiraganaA="あ" ; # $ZCHAR(227,129,130)
		set tamilA="அ" ; # $ZCHAR(224,174,133)
		set teluguE="ఎ" ; # $ZCHAR(224,176,142)
		;;;
		set temp1=$ZCHAR(161,239,188)
		set temp2=$ZCHAR(130,227,129)
		set temp3=$ZCHAR(174,133,174)
		set temp4=$ZCHAR(176,142,224)
		;;;
		; also use literals for the same examine statements and check as th code path is very different for variables
		; and literals
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($TRANSLATE(fullwidthA,temp1,temp2),fullwidthA,"ERROR 1 from translate") ; # should not get translated
		. do ^examine($TRANSLATE("Ａ",temp1,temp2),fullwidthA,"ERROR 1 on literal from translate") ; # should not get translated
		. do ^examine($TRANSLATE(tamilA,temp3,temp4),tamilA,"ERROR 2 from translate") ; # should not get translated
		. do ^examine($TRANSLATE("அ",temp3,temp4),tamilA,"ERROR 2 on literal from translate") ; # should not get translated
		if ("M"=$ZCHSET) do
		. do ^examine($TRANSLATE(fullwidthA,temp1,temp2),hiraganaA,"ERROR 3 from ztranslate")
		. do ^examine($TRANSLATE("Ａ",temp1,temp2),hiraganaA,"ERROR 3 on literal from ztranslate")
		. do ^examine($TRANSLATE(tamilA,temp3,temp4),teluguE,"ERROR 4 from ztranslate")
		. do ^examine($TRANSLATE("அ",temp3,temp4),teluguE,"ERROR 4 on literal from ztranslate")
		do ^examine($ZTRANSLATE(fullwidthA,temp1,temp2),hiraganaA,"ERROR 5 from ztranslate")
		do ^examine($ZTRANSLATE("Ａ",temp1,temp2),hiraganaA,"ERROR 5 on literal from ztranslate")
		do ^examine($ZTRANSLATE(tamilA,temp3,temp4),teluguE,"ERROR 6 from ztranslate")
		do ^examine($ZTRANSLATE("அ",temp3,temp4),teluguE,"ERROR 6 on literal from ztranslate")
indirection ;
		write !,"Testing ZTRANSLATE for indirection",!
		set infullwidthA="fullwidthA"
		set intamilA="tamilA"
		set intemp1="temp1"
		set intemp4="temp4"
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($TRANSLATE(@infullwidthA,@intemp1,temp2),@infullwidthA,"ERROR 1 from indirection") ; # should not get translated
		. do ^examine($TRANSLATE(@intamilA,temp3,@intemp4),@intamilA,"ERROR 2 from indirection") ; # should not get translated
		if ("M"=$ZCHSET) do
		. do ^examine($TRANSLATE(@infullwidthA,@intemp1,temp2),hiraganaA,"ERROR 3 from indirection")
		. do ^examine($TRANSLATE(@intamilA,temp3,@intemp4),teluguE,"ERROR 4 from indirection")
		do ^examine($ZTRANSLATE(@infullwidthA,@intemp1,temp2),hiraganaA,"ERROR 5 from indirection")
		do ^examine($ZTRANSLATE(@intamilA,temp3,@intemp4),teluguE,"ERROR 6 from indirection")
sampleset ;
		write !,"Testing ZTRANSLATE on some sample unicode literals",!
		; results should be the same for both utf-8 and M since none of the bytes
		; are repeated in the strings strx,stry,strz.
		set strx="ĂȑƋっ" ; # hex values: c4 82 c8 91 c6 8b e3 81 a3
		set stry="ڦAΨמ" ;  # hex values: da a6 41 ce a8 d7 9e
		set strz="ẙ۩Ÿ" ;  # hex values: e1 ba 99 db a9 c5 b8
		set strchange=$Reverse(strx)
		do multiequal^examine($TRANSLATE(strx,strx,strchange),$ZTRANSLATE(strx,strx,strchange),strchange,"ERROR 1 from sampleset")
		set strappend=strx_stry_strz
		set strchange=stry_stry_strz
		do multiequal^examine($ZTRANSLATE(strappend,strx,stry),$TRANSLATE(strappend,strx,stry),strchange,"ERROR 2 from sampleset")
replace ;
		write !,"Testing ZTRANSLATE for character by character replacement",!
		set varx="abcde"
		set vary="ａｂｃｄｅ"
		set str1="alphabet"
		set str2="ａｌｐｈａｂｅｔ"
		set varq=$ZCHAR(300,200,499)_$ZCHAR(999,999)_$ZCHAR(567,623,789)
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($TRANSLATE(str1,varx,vary),"ａlphａｂｅt","ERROR 1 from replace")
		. do ^examine($TRANSLATE("alphabet","abcde","ａｂｃｄｅ"),"ａlphａｂｅt","ERROR 1 on literal from replace")
		. do ^examine($TRANSLATE(str2,vary,varx),"aｌｐｈabeｔ","ERROR 2 from replace")
		. do ^examine($TRANSLATE("ａｌｐｈａｂｅｔ","ａｂｃｄｅ","abcde"),"aｌｐｈabeｔ","ERROR 2 on literal from replace")
		if ("M"=$ZCHSET) do
		. do ^examine($TRANSLATE(str1,varx,vary),$ZCHAR(239)_"lphｽt","ERROR 3 from replace")
		. do ^examine($TRANSLATE("alphabet","abcde","ａｂｃｄｅ"),$ZCHAR(239)_"lphｽt","ERROR 3 on literal from replace")
		. do ^examine($TRANSLATE(str2,vary,varx),"abcab"_$ZCHAR(140)_"ab"_$ZCHAR(144)_"ab"_$ZCHAR(136)_"abcababab"_$ZCHAR(148),"ERROR 4 from replace")
		. do ^examine($TRANSLATE("ａｌｐｈａｂｅｔ","ａｂｃｄｅ","abcde"),"abcab"_$ZCHAR(140)_"ab"_$ZCHAR(144)_"ab"_$ZCHAR(136)_"abcababab"_$ZCHAR(148),"ERROR 4 on literal from replace")
		;; test some invalid multi-byte char strings
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($TRANSLATE(str1,varq,vary),str1,"ERROR 5 from replace")
		. do ^examine($TRANSLATE("alphabet",varq,"ａｂｃｄｅ"),str1,"ERROR 5 on literal from replace")
		. do ^examine($TRANSLATE(str1,varx,varq),$ZCHAR(200)_"lph"_$ZCHAR(200)_"t","ERROR 6 from replace")
		. do ^examine($TRANSLATE("alphabet","abcde",varq),$ZCHAR(200)_"lph"_$ZCHAR(200)_"t","ERROR 6 on literal from replace")
		. do ^examine($TRANSLATE(str2,vary,varq),$ZCHAR(200)_"ｌｐｈ"_$ZCHAR(200)_"ｔ","ERROR 7 from replace")
		. do ^examine($TRANSLATE("ａｌｐｈａｂｅｔ","ａｂｃｄｅ",varq),$ZCHAR(200)_"ｌｐｈ"_$ZCHAR(200)_"ｔ","ERROR 7 on literal from replace")
		if ("M"=$ZCHSET) do
		. do ^examine($TRANSLATE(str1,varx,varq),$ZCHAR(200)_"lph"_$ZCHAR(200)_"t","ERROR 8 from replace")
		. do ^examine($TRANSLATE("alphabet","abcde",varq),$ZCHAR(200)_"lph"_$ZCHAR(200)_"t","ERROR 8 on literal from replace")
		. do ^examine($TRANSLATE(str2,vary,varq),$ZCHAR(200)_"ȌȐȈ"_$zchar(200,200,200)_"Ȕ","ERROR 9 from replace")
		. do ^examine($TRANSLATE("ａｌｐｈａｂｅｔ","ａｂｃｄｅ",varq),$ZCHAR(200)_"ȌȐȈ"_$zchar(200,200,200)_"Ȕ","ERROR 9 on literal from replace")
		. do ^examine($TRANSLATE(str2,varq,varx),str2,"ERROR 10 from replace")
		. do ^examine($TRANSLATE("ａｌｐｈａｂｅｔ",varq,"abcde"),str2,"ERROR 10 on literal from replace")
		if $data(bch) view "BADCHAR"
		quit
