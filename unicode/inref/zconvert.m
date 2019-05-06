;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2006-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zconvert ;
		write "******* Testing ZCONVERT two argument form*******",!
		set cnti=0
		set ^case="T" ; "T" case to be used in terms of this variable to avoid compilation errors
		; Construct some strings using special cases and other interesting unicode chars
		; organize them as non-unicode followed by unicode as the routine runs for both modes of CHSET
		set cnti=cnti+1,testarorg(cnti)="a",testarl(cnti)="a",testaru(cnti)="A",testart(cnti)="A",comments(cnti)="simple a"
		set cnti=cnti+1,testarorg(cnti)="a sample",testarl(cnti)="a sample",testaru(cnti)="A SAMPLE",testart(cnti)="A Sample",comments(cnti)="sample string"
		set cnti=cnti+1,testarorg(cnti)="!@#% = @ # ## . punctuation",testarl(cnti)="!@#% = @ # ## . punctuation",testaru(cnti)="!@#% = @ # ## . PUNCTUATION",testart(cnti)="!@#% = @ # ## . Punctuation",comments(cnti)="punctutation string"
		set cnti=cnti+1,testarorg(cnti)="what aBoUt mANy .maNY MANy words",testarl(cnti)="what about many .many many words",testaru(cnti)="WHAT ABOUT MANY .MANY MANY WORDS",testart(cnti)="What About Many .Many Many Words",comments(cnti)="many word string"
		set cnti=cnti+1,testarorg(cnti)="W0w",testarl(cnti)="w0w",testaru(cnti)="W0W",testart(cnti)="W0w",comments(cnti)="wow with a zeo"
		;
		if ("UTF-8"=$ZCHSET) do
		. ; load all the special_casing characters reported in unicode.org to see the behavior if they are case converted
		. ; Note: To run convert.m convert.awk should have been executed by the test script prior
		. do ^convert
		. set cnti=cnti+1,testarorg(cnti)="ǲ",testarl(cnti)="ǳ",testaru(cnti)="Ǳ",testart(cnti)="ǲ"
		. set comments(cnti)="DZ literal"
		. set cnti=cnti+1,testarorg(cnti)="ｗｈａｔ ａｂｏｕｔ ｗｉｄｅ ｃｈａｒｓ, Ｗｈａｔ Ａｂｏｕｔ Ｗｉｄｅ Ｃｈａｒｓ, ＷＨＡＴ ＡＢＯＵＴ ＷＩＤＥ ＣＨＡＲＳ",testarl(cnti)="ｗｈａｔ ａｂｏｕｔ ｗｉｄｅ ｃｈａｒｓ, ｗｈａｔ ａｂｏｕｔ ｗｉｄｅ ｃｈａｒｓ, ｗｈａｔ ａｂｏｕｔ ｗｉｄｅ ｃｈａｒｓ",testaru(cnti)="ＷＨＡＴ ＡＢＯＵＴ ＷＩＤＥ ＣＨＡＲＳ, ＷＨＡＴ ＡＢＯＵＴ ＷＩＤＥ ＣＨＡＲＳ, ＷＨＡＴ ＡＢＯＵＴ ＷＩＤＥ ＣＨＡＲＳ",testart(cnti)="Ｗｈａｔ Ａｂｏｕｔ Ｗｉｄｅ Ｃｈａｒｓ, Ｗｈａｔ Ａｂｏｕｔ Ｗｉｄｅ Ｃｈａｒｓ, Ｗｈａｔ Ａｂｏｕｔ Ｗｉｄｅ Ｃｈａｒｓ"
		. set comments(cnti)="wide characters"
		. set cnti=cnti+1,testarorg(cnti)="The German sharp S is ß, COmbine it ßßßSSSs",testarl(cnti)="the german sharp s is ß, combine it ßßßssss",testaru(cnti)="THE GERMAN SHARP S IS SS, COMBINE IT SSSSSSSSSS",testart(cnti)="The German Sharp S Is Ss, Combine It Ssßßssss"
		. set comments(cnti)="german sharp s"
		. set cnti=cnti+1,testarorg(cnti)="Chinese chars 实现评论力皮放",testarl(cnti)="chinese chars 实现评论力皮放",testaru(cnti)="CHINESE CHARS 实现评论力皮放",testart(cnti)="Chinese Chars 实现评论力皮放"
		. set comments(cnti)="chinese chars"
		. set cnti=cnti+1,testarorg(cnti)="LaTin CApital Letter Ǳ And repeated ǱǱǳǲ",testarl(cnti)="latin capital letter ǳ and repeated ǳǳǳǳ",testaru(cnti)="LATIN CAPITAL LETTER Ǳ AND REPEATED ǱǱǱǱ",testart(cnti)="Latin Capital Letter ǲ And Repeated ǲǳǳǳ"
		. set comments(cnti)="latin DZ repeated"
		. set cnti=cnti+1,testarorg(cnti)="Mix of characters that has title case property ǇǈǉǊǋǌ",testarl(cnti)="mix of characters that has title case property ǉǉǉǌǌǌ",testaru(cnti)="MIX OF CHARACTERS THAT HAS TITLE CASE PROPERTY ǇǇǇǊǊǊ",testart(cnti)="Mix Of Characters That Has Title Case Property ǈǉǉǌǌǌ"
		. set comments(cnti)="mix of titled cased letters"
		. set cnti=cnti+1,testarorg(cnti)="ChArs witHout tItle caSE œœœŒɶɶ ĳĳĲĳ ǣǣǣǣǢǽǼ",testarl(cnti)="chars without title case œœœœɶɶ ĳĳĳĳ ǣǣǣǣǣǽǽ",testaru(cnti)="CHARS WITHOUT TITLE CASE ŒŒŒŒɶɶ ĲĲĲĲ ǢǢǢǢǢǼǼ",testart(cnti)="Chars Without Title Case Œœœœɶɶ Ĳĳĳĳ Ǣǣǣǣǣǽǽ"
		. set comments(cnti)="chars without title case"
		. set cnti=cnti+1,testarorg(cnti)="character without case ʦʦ ʧʨʩ ʪʫ ʣʤ",testarl(cnti)="character without case ʦʦ ʧʨʩ ʪʫ ʣʤ",testaru(cnti)="CHARACTER WITHOUT CASE ʦʦ ʧʨʩ ʪʫ ʣʤ",testart(cnti)="Character Without Case ʦʦ ʧʨʩ ʪʫ ʣʤ"
		. set comments(cnti)="chars without case"
		. ;
		. set cnti=cnti+1,testarorg(cnti)="Türkçe -- single CodE Point",testarl(cnti)="türkçe -- single code point",testaru(cnti)="TÜRKÇE -- SINGLE CODE POINT",testart(cnti)="Türkçe -- Single Code Point"
		. set comments(cnti)="turkish single code point"
		. set cnti=cnti+1,testarorg(cnti)="Türkçe -- with combining marks",testarl(cnti)="türkçe -- with combining marks",testaru(cnti)="TÜRKÇE -- WITH COMBINING MARKS",testart(cnti)="Türkçe -- With Combining Marks"
		. set comments(cnti)="turkish with combining marks"
		. set cnti=cnti+1,testarorg(cnti)="Tu¨rkc¸e -- huh, non-combining marks",testarl(cnti)="tu¨rkc¸e -- huh, non-combining marks",testaru(cnti)="TU¨RKC¸E -- HUH, NON-COMBINING MARKS",testart(cnti)="Tu¨Rkc¸E -- Huh, Non-Combining Marks"
		. set comments(cnti)="turkish without combining marks"
		. set cnti=cnti+1,testarorg(cnti)="And now the famous Turkish dotless i: ı (L), or I (U), or I (T)",testarl(cnti)="and now the famous turkish dotless i: ı (l), or i (u), or i (t)",testaru(cnti)="AND NOW THE FAMOUS TURKISH DOTLESS I: I (L), OR I (U), OR I (T)",testart(cnti)="And Now The Famous Turkish Dotless I: I (L), Or I (U), Or I (T)"
		. set comments(cnti)="turkish dotless I"
		. set cnti=cnti+1,testarorg(cnti)="Hey, what about the Turkish capital i with dot?: İ (U), i (L),İ (T)",testarl(cnti)="hey, what about the turkish capital i with dot?: i̇ (u), i (l),i̇ (t)",testaru(cnti)="HEY, WHAT ABOUT THE TURKISH CAPITAL I WITH DOT?: İ (U), I (L),İ (T)",testart(cnti)="Hey, What About The Turkish Capital I With Dot?: İ (U), I (L),İ (T)"
		. set comments(cnti)="turkish capital I with dot"
		. set cnti=cnti+1,testarorg(cnti)="Æ æ ΒΑΕΖΜΝΟΤΥΧ 《说文》 《 说 文 》 100℃ km² km³ ０１２３４５６７８９ 0123456789",testarl(cnti)="æ æ βαεζμνοτυχ 《说文》 《 说 文 》 100℃ km² km³ ０１２３４５６７８９ 0123456789",testaru(cnti)="Æ Æ ΒΑΕΖΜΝΟΤΥΧ 《说文》 《 说 文 》 100℃ KM² KM³ ０１２３４５６７８９ 0123456789",testart(cnti)="Æ Æ Βαεζμνοτυχ 《说文》 《 说 文 》 100℃ Km² Km³ ０１２３４５６７８９ 0123456789"
		. set comments(cnti)="greek mixed with full width numbers"
		. set cnti=cnti+1,testarorg(cnti)="ｑｗｅｒｔｙ ｕｉ  ☺ ☻ ☎ ""   ￰ ￱ ",testarl(cnti)="ｑｗｅｒｔｙ ｕｉ  ☺ ☻ ☎ ""   ￰ ￱ ",testaru(cnti)="ＱＷＥＲＴＹ ＵＩ  ☺ ☻ ☎ ""   ￰ ￱ ",testart(cnti)="Ｑｗｅｒｔｙ Ｕｉ  ☺ ☻ ☎ ""   ￰ ￱ "
		. set comments(cnti)="full width chars with special symbols"
		. ; Mathematical BOLD Capital A maps to itself in casing. Thats how unicode describes this character
		. set cnti=cnti+1,testarorg(cnti)=$ZCHAR(240,157,144,128),testarl(cnti)=$ZCHAR(240,157,144,128),testaru(cnti)=$ZCHAR(240,157,144,128),testart(cnti)=$ZCHAR(240,157,144,128)
		. set comments(cnti)="Mathematical BOLD Capital A"
		. set cnti=cnti+1,testarorg(cnti)=$ZCHAR(240,144,128,131),testarl(cnti)=$ZCHAR(240,144,128,131),testaru(cnti)=$ZCHAR(240,144,128,131),testart(cnti)=$ZCHAR(240,144,128,131)
		. set comments(cnti)="four byte linear B syllable"
		. set cnti=cnti+1,testarorg(cnti)="Árvíztűrő tükörfúrógép.",testarl(cnti)="árvíztűrő tükörfúrógép.",testaru(cnti)="ÁRVÍZTŰRŐ TÜKÖRFÚRÓGÉP.",testart(cnti)="Árvíztűrő Tükörfúrógép."
		. set comments(cnti)="greek ordinary and some combining chars"
		. set cnti=cnti+1,testarorg(cnti)="Жълтата дюля беше щастлива (Bulgarian)",testarl(cnti)="жълтата дюля беше щастлива (bulgarian)",testaru(cnti)="ЖЪЛТАТА ДЮЛЯ БЕШЕ ЩАСТЛИВА (BULGARIAN)",testart(cnti)="Жълтата Дюля Беше Щастлива (Bulgarian)"
		. set comments(cnti)="bulgarian chars"
		. set cnti=cnti+1,testarorg(cnti)="В чащах юга жил-был цитрус (Russian)",testarl(cnti)="в чащах юга жил-был цитрус (russian)",testaru(cnti)="В ЧАЩАХ ЮГА ЖИЛ-БЫЛ ЦИТРУС (RUSSIAN)",testart(cnti)="В Чащах Юга Жил-Был Цитрус (Russian)"
		. set comments(cnti)="some russian"
		. set cnti=cnti+1,testarorg(cnti)="Pchnąć w tę łódź jeża (Polish)",testarl(cnti)="pchnąć w tę łódź jeża (polish)",testaru(cnti)="PCHNĄĆ W TĘ ŁÓDŹ JEŻA (POLISH)",testart(cnti)="Pchnąć W Tę Łódź Jeża (Polish)"
		. set comments(cnti)="polish polish"
		. set cnti=cnti+1,testarorg(cnti)="Chezch -- Příliš žluťoučký kůň",testarl(cnti)="chezch -- příliš žluťoučký kůň",testaru(cnti)="CHEZCH -- PŘÍLIŠ ŽLUŤOUČKÝ KŮŇ",testart(cnti)="Chezch -- Příliš Žluťoučký Kůň"
		. set comments(cnti)="chezch writing"
		. set cnti=cnti+1,testarorg(cnti)="Dutch -- Pa's wĳze lynx bezag vroom",testarl(cnti)="dutch -- pa's wĳze lynx bezag vroom",testaru(cnti)="DUTCH -- PA'S WĲZE LYNX BEZAG VROOM",testart(cnti)="Dutch -- Pa's Wĳze Lynx Bezag Vroom"
		. set comments(cnti)="dutch treat"
		. set cnti=cnti+1,testarorg(cnti)="Greek -- Ξεσκεπάζω την ψυχοφθόρα",testarl(cnti)="greek -- ξεσκεπάζω την ψυχοφθόρα",testaru(cnti)="GREEK -- ΞΕΣΚΕΠΆΖΩ ΤΗΝ ΨΥΧΟΦΘΌΡΑ",testart(cnti)="Greek -- Ξεσκεπάζω Την Ψυχοφθόρα"
		. set comments(cnti)="more greek"
		. set cnti=cnti+1,testarorg(cnti)="Turkish -- Şişli'de büyük çöp yığınları",testarl(cnti)="turkish -- şişli'de büyük çöp yığınları",testaru(cnti)="TURKISH -- ŞIŞLI'DE BÜYÜK ÇÖP YIĞINLARI",testart(cnti)="Turkish -- Şişli'de Büyük Çöp Yığınları"
		. set comments(cnti)="And more trukish"
		. set cnti=cnti+1,testarorg(cnti)="Kanji 散りぬるを我 ぬるを我 るを我 ぬを我",testarl(cnti)="kanji 散りぬるを我 ぬるを我 るを我 ぬを我",testaru(cnti)="KANJI 散りぬるを我 ぬるを我 るを我 ぬを我",testart(cnti)="Kanji 散りぬるを我 ぬるを我 るを我 ぬを我"
		. set comments(cnti)="Japanese Kanji"
		. ; disable below as the boundaries are illegal characters generating BADCHAR
		. ;set cnti=cnti+1,testarorg(cnti)=$CHAR(65792,1114111,1114000),testarl(cnti)=$CHAR(65792,1114111,1114000),testaru(cnti)=$CHAR(65792,1114111,1114000),testart(cnti)=$CHAR(65792,1114111,1114000)
		. ;set comments(cnti)="code point boundaries"
		;
		do check
		if ("UTF-8"=$ZCHSET) do
		. ; check for additional convert scenarios in different locale settings
		. ; convert.awk would have created convert.m AND few other language specific convert routines like trurkishconvert.m
		. ; this needs to be run under turkish locale settings for example. Trigger them separately here.
		. ; we will have separate zsystem calls that runs them because we do not want to disturb the overall LC settings of the test flow
		. ;;;
		. ; variables like arrcnt,convertarray and localearray are dynamically set by convert.m generated by convert.awk
		. ; They are all inter-linked.The flow starts from special_casing.txt read by convert.awk and finally
		. ; generating convert.m <language specifc>convert.m routines.
		. for i=1:1:arrcnt do
		. . if ($DATA(localearray(arrcnt))) zsystem "setenv LC_ALL "_localearray(arrcnt)_";$gtm_exe/mumps -run "_convertarray(arrcnt)
longstring ;
		write "******* Testing ZCONVERT on a long string *******",!
		if ("UTF-8"=$ZCHSET) set str="ｕＴｆ８"_$$^longstr(10000)_"ＥＮｄ" set strout=$ZCONVERT($ZCONVERT(str,"U"),^case)
		else  set str=$$^longstr(10000) set strout=$ZCONVERT($ZCONVERT(str,"U"),"L")
		set fname="longstr"_$ZCHSET_".out"
		open fname:(new) use fname write strout close fname
		ZSYSTEM "diff longstr"_$ZCHSET_".{cmp,out}"
threeargs ;
		if ("UTF-8"'=$ZCHSET) quit
		write "******* Testing ZCONVERT three argument form*******",!
		set fileutf8="utf8.txt"
		set fileutf16le="utf16le.txt"
		set fileutf16be="utf16be.txt"
		set osfile16le="a16le"
		set osfile16be="a16be"
		set fullfile16le="fullfile16le.txt"
		set fullfile16be="fullfile16be.txt"
		set osfullfile16le="osfullfile16le.txt"
		set osfullfile16be="osfullfile16be.txt"
		for i=1:1:^cntstr do
		. open fileutf8:(newversion) use fileutf8 write ^str(i),! close fileutf8
		. ;
		. open fileutf16le:(newversion:OCHSET="M") use fileutf16le write $ZCONVERT(^str(i),"UTF-8","UTF-16LE"),!,$c(0) set $x=0 close fileutf16le
		. open fullfile16le:(append:OCHSET="M") use fullfile16le write $ZCONVERT(^str(i),"UTF-8","UTF-16LE"),!,$c(0) set $x=0 close fullfile16le
		. open osfile16le:(newversion:OCHSET="UTF-16LE") use osfile16le write ^str(i),! close osfile16le
		. open osfullfile16le:(append:OCHSET="UTF-16LE") use osfullfile16le write ^str(i),! close osfullfile16le
		. ; it is critical to read the string in FIXED format (raw bytes) to take into account the LF in the text file
		. open osfile16le:(FIXED:ICHSET="M") use osfile16le read utf16strle close osfile16le
		. set utf8str=$ZCONVERT(utf16strle,"UTF-16LE","UTF-8")
		. ;append $C(10) because FIXED format read always reads the whole record which includes LF at the end of the file
		. do ^examine(utf8str,^str(i)_$C(10),"round trip conversion of utf8 to utf16 and then back to utf8 from utf16 should happen for"_^comments(i))
		. ;
		. open fileutf16be:(newversion:OCHSET="M") use fileutf16be write $ZCONVERT(^str(i),"UTF-8","UTF-16BE"),$c(0),! set $x=0 close fileutf16be
		. open fullfile16be:(append:OCHSET="M") use fullfile16be write $ZCONVERT(^str(i),"UTF-8","UTF-16BE"),$c(0),! set $x=0 close fullfile16be
		. open osfile16be:(newversion:OCHSET="UTF-16BE") use osfile16be write ^str(i),! close osfile16be
		. open osfullfile16be:(append:OCHSET="UTF-16BE") use osfullfile16be write ^str(i),! close osfullfile16be
		. open osfile16be:(FIXED:ICHSET="M") use osfile16be read utf16strbe close osfile16be
		. set utf8str=$ZCONVERT(utf16strbe,"UTF-16BE","UTF-8")
		. do ^examine(utf8str,^str(i)_$C(10),"round trip conversion of utf8 to utf16 and then back to utf8 from utf16 should happen for"_^comments(i))
		. ; just a sanity check to ensure we indeed write UTF-16LE and UTF-16BE formats using OCHSET aparameter earlier
		. do notequal^examine(utf16strle,utf16strbe,"trouble with ochset parameter in writing utf-16 formats LE and BE encoding should not be equal for "_^comments(i))
		set diffcmd="diff "_fullfile16le_" "_osfullfile16le
		zsystem diffcmd
		set diffcmd="diff "_fullfile16be_" "_osfullfile16be
		zsystem diffcmd
		quit
check ;
		for x=1:1:cnti do
  		. do ^examine($ZCONVERT(testarorg(x),"l"),testarl(x),"Lowercase (l) conversion of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT(testarorg(x),"L"),testarl(x),"Lowercase (L) conversion of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT(testarorg(x),"u"),testaru(x),"Uppercase (u) conversion of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT(testarorg(x),"U"),testaru(x),"Uppercase (U) conversion of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT($ZCONVERT(testarorg(x),"U"),"u"),testaru(x),"Uppercase of uppercase of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT($ZCONVERT(testarorg(x),"L"),"L"),testarl(x),"Lowercase of lowercase of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT(testarorg(x),^case),testart(x),"Titlecase (t) conversion of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT(testarorg(x),^case),testart(x),"Titlecase (T) conversion of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT($ZCONVERT(testarorg(x),^case),^case),testart(x),"Titlecase of titlecase of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		. do ^examine($ZCONVERT($ZCONVERT(testarorg(x),^case),"U"),testaru(x),"Uppercase of titlecase of testarorg("_x_"): "_testarorg(x)_" "_comments(x))
		quit
