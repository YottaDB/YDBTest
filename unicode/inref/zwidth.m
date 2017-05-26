zwidth ;
		; this test doesn't make sense on M mode as zwidth will treat every character byte/byte
		; and if it comes across an unprintable one byte wise the whole expression will yield a -1
		; so run this routine on UTF-8 only
		if ("UTF-8"'=$ZCHSET) quit
		write "******* Testing ZWIDTH on multibyte strings *******",!
		set strx(1)="1234567890123456789"
		set strx(2)="abcａｄｆｒｊqwerty"
		set strx(3)="我能吞下玻璃而不伤_"
		set strx(4)="ＡＢＣＤＥＦＧＨＩ_"
		set strx(5)="Greek ΒΑΕΖ_23456789"
		set strx(6)="Türkçe_890123456789" ; normalized form
		set strx(7)="Tȗrkçe_890123456789" ; with combining characters
		set strx(8)="u wth uml and ced ȗ̧" ; multiple combining characters on one word
		set strx(9)="aͣ is an a on an a_9" ; combining characters
		set strx(10)="aͣaͤaͨͪͣͨͪaͫͫ ͬa²²²_123456789" ; more combining characters
		set strx(11)="Ææ☼☼☼☼ ☎☎☎☎ ☃☃☃☃⅛_9"
		set strx(12)="u+D801: �_123456789"
		set strx(13)="U+FF00: ！_23456789"
		set strx(14)="Pchnąćtęłódźjeżaośm" ; Polish
		set strx(15)="Вчащахюгажил-былцит" ; Russian
		set strx(16)="ВЧАЩАХЮГАЖИЛ-БЫЛЦИТ" ; Russian
		set strx(17)="いろはにほへど　ち_" ; Japanese Hiragana
		set strx(18)="色は匂へど散りぬる_" ; Japanes Katakana
		set strx(19)="four byte char1 󠄀_89" ; this is because the variation selector character has zero width
		set strx(20)="four byte char2 𐄀_9"
		set strx(21)="full width:！＂＃_9"
		set strx(22)="alef:א,alef-etnah:א֑" ; Hebrew accents
		set strx(23)="בִגֹדְךכלםֽ_90123456789" ; Hebrew accents and points
		set strx(24)="1͏2⃝_4567890123456789"
		;set strx(25)="அவர்கள் ஏன் தமிழில் பேசக்கூடாது"
		; all of the above strings should give 19 as $ZWIDTH
		for i=1:1:24 do
		. do ^examine($ZWIDTH(strx(i)),19,"ZWIDTH of "_strx(i)_" should be 19") write "$LENGTH(strx("_i_"))=",$LENGTH(strx(i)),", $ZLENGTH(strx("_i_"))=",$ZLENGTH(strx(i)),!
		;;;
		for i=1:1:^cntstr if (^width(i)'=-1) do ^examine($ZWIDTH(^str(i)),^width(i),"ZWIDTH of "_^str(i)_" "_^comments(i)_"should be "_^width(i))
		;;;
spaces ;
		write "******* Testing ZWIDTH for different space characters *******",!
		if ("UTF-8"=$ZCHSET) do
		. ; correct examine statement accordingly then
		. do ^examine($ZWIDTH($CHAR(32)),1,"ZWIDTH of SPACE should be 1") ; SPACE
		. do ^examine($ZWIDTH($CHAR(160)),1,"ZWIDTH of NO-BREAK SPACE should be 1") ; NO-BREAK SPACE
		. do ^examine($ZWIDTH($CHAR(4961)),1,"ZWIDTH of ETHIOPIC WORDSPACE should be 1") ; ETHIOPIC WORDSPACE
		. do ^examine($ZWIDTH($CHAR(5760)),1,"ZWIDTH of OGHAM SPACE MARK should be 1") ; OGHAM SPACE MARK
		. do ^examine($ZWIDTH($CHAR(8194)),1,"ZWIDTH of EN SPACE should be 1") ; EN SPACE
		. do ^examine($ZWIDTH($CHAR(8195)),1,"ZWIDTH of EM SPACE should be 1") ; EM SPACE
		. do ^examine($ZWIDTH($CHAR(8196)),1,"ZWIDTH of THREE-PER-EM SPACE should be 1") ; THREE-PER-EM SPACE
		. do ^examine($ZWIDTH($CHAR(8197)),1,"ZWIDTH of FOUR-PER-EM SPACE should be 1") ; FOUR-PER-EM SPACE
		. do ^examine($ZWIDTH($CHAR(8198)),1,"ZWIDTH of SIX-PER-EM SPACE should be 1") ; SIX-PER-EM SPACE
		. do ^examine($ZWIDTH($CHAR(8199)),1,"ZWIDTH of FIGURE SPACE should be 1") ; FIGURE SPACE
		. do ^examine($ZWIDTH($CHAR(8200)),1,"ZWIDTH of PUNCTUATION SPACE should be 1") ; PUNCTUATION SPACE
		. do ^examine($ZWIDTH($CHAR(8201)),1,"ZWIDTH of THIN SPACE should be 1") ; THIN SPACE
		. do ^examine($ZWIDTH($CHAR(8202)),1,"ZWIDTH of HAIR SPACE should be 1") ; HAIR SPACE
		. do ^examine($ZWIDTH($CHAR(8203)),0,"ZWIDTH of ZERO WIDTH SPACE should be 0") ; ZERO WIDTH SPACE
		. do ^examine($ZWIDTH($CHAR(8239)),1,"ZWIDTH of NARROW NO-BREAK SPACE should be 1") ; NARROW NO-BREAK SPACE
		. do ^examine($ZWIDTH($CHAR(8287)),1,"ZWIDTH of MEDIUM MATHEMATICAL SPACE should be 1") ; MEDIUM MATHEMATICAL SPACE
		. do ^examine($ZWIDTH($CHAR(12288)),2,"ZWIDTH of IDEOGRAPHIC SPACE should be 2") ; IDEOGRAPHIC SPACE
		. do ^examine($ZWIDTH($CHAR(12351)),1,"ZWIDTH of IDEOGRAPHIC HALF FILL SPACE should be 1") ; IDEOGRAPHIC HALF FILL SPACE
		. do ^examine($ZWIDTH($CHAR(65279)),0,"ZWIDTH of  BYTE ORDER MARK should be 0") ;  BYTE ORDER MARK
		. do ^examine($ZWIDTH($CHAR(917536)),0,"ZWIDTH of TAG SPACE should be 0") ; TAG SPACE
		. do ^examine($ZWIDTH($CHAR(776)),0,"ZWIDTH of combining diaresis should be 0")
		;
unprintable ;
		write "******* Testing ZWIDTH on unprintable control characters *******",!
		; all control characters below should return -1
		for i=1:1:31 do ^examine($ZWIDTH($CHAR(i)),0,"ZWIDTH of $CHAR("_i_") should be 0")
		for i=127:1:159 do ^examine($ZWIDTH($CHAR(i)),0,"ZWIDTH of $CHAR("_i_") should be 0")
		for i=65024:1:65039 do ^examine($ZWIDTH($CHAR(i)),0,"ZWIDTH of $CHAR("_i_") should be 0")
		set joiner="f"_$CHAR(8205)_"i"
		set nonjoiner="f"_$CHAR(8204)_"i"
		set lnsep=$CHAR(8232)
		set parasep="a"_$CHAR(8233)_"b"
		set grapheme=$CHAR(847)
		set enclosing=$CHAR(8413)
		set formatchar=$CHAR(8206,8207,8234,8235)
		for charx=joiner,nonjoiner,lnsep,parasep,grapheme,enclosing,formatchar do ^examine($ZWIDTH($CHAR(charx)),0,"ZWIDTH of "_charx_" should be 0")
		quit
