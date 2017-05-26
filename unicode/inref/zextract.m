zextract ;
		; Identify the $ZCHSET value and set corresponding local vars to proceed appropriately
		; since the steps and the M-arrays used from unicodesampledata.m will vary based on that
		if ("UTF-8"=$ZCHSET) set len="^ucplen",arr="^ucp"
		else  set len="^utf8len",arr="^utf8"
		write !,"Testing ZEXTRACT,EXTRACT for the entire unicode sample data range",!
		for cnti=1:1:^cntstr do
		. for xi=1:1:@len@(cnti) do
		. . do ^examine($ASCII($EXTRACT(^str(cnti),xi)),$PIECE(@arr@(cnti),",",xi),"EXTRACT'ing one byte/char at a time for byte "_xi_" in string "_^str(cnti)_" "_^comments(cnti));
		. for xi=1:1:^utf8len(cnti) do
		. . do ^examine($ZASCII($ZEXTRACT(^str(cnti),xi)),$PIECE(^utf8(cnti),",",xi),"ZEXTRACT'ing one byte at a time for byte "_xi_" in string "_^str(cnti)_" "_^comments(cnti))
		;;;
		for cnti=1:1:^cntstr do
		. for xi=1:1:^ucplen(cnti) set sss(xi)=$EXTRACT(^str(cnti),xi)
		. set ssstotal="" for xi=1:1:^ucplen(cnti) set ssstotal=ssstotal_sss(xi)
		. if ("UTF-8"=$ZCHSET) do
		. . do ^examine(ssstotal,^str(cnti),"EXTRACT and append the chars one by one should be the same as "_^str(cnti)_" "_^comments(cnti))
		. . do ^examine($EXTRACT(^str(cnti),1,^ucplen(cnti)),^str(cnti),"EXTRACT for the whole length of the string should be equal to "_^str(cnti)_" "_^comments(cnti))
		; For M mode we run only multibyte characters to check what we intended to here
		; because checking against single byte character strings will give us the same result.
		if ("M"=$ZCHSET) do
		. for cnti=^cntstrmbytes:1:^cntstrmbytee do
		. . for xi=1:1:^ucplen(cnti) set sss(xi)=$EXTRACT(^str(cnti),xi)
		. . set ssstotal="" for xi=1:1:^ucplen(cnti) set ssstotal=ssstotal_sss(xi)
		. . do notequal^examine(ssstotal,^str(cnti),"EXTRACT and append the chars cannot be the same as "_^str(cnti)_" "_^comments(cnti)_" under M")
basic;
	write !,"Testing ZEXTRACT,EXTRACT on both left and the right side with a unicode literal",!
	; since we have byte by byte processing below we need to turn BADCHAR off
	if $VIEW("BADCHAR") do
	. set bch=1
	. view "NOBADCHAR"
	set s1="A"_$ZCHAR(132)_"ä"
	set e1=$EXTRACT(s1,2,3)
	set e2=$ZEXTRACT(s1,2,3)
	if ("UTF-8"=$ZCHSET) do
	. do ^examine(e1,$ZCHAR(132)_"ä","ERROR 1 from basic")
	. do ^examine(e2,$ZCHAR(132,195),"ERROR 2 from basic")
	else  do ^examine(e1,e2,"ERROR 3 from basic")
	set $EXTRACT(e1,1)="B"
	set $ZEXTRACT(s1,3,4)="B"
	do ^examine(s1,"A"_$ZCHAR(132)_"B","ERROR 4 from basic")
	if ("UTF-8"=$ZCHSET) do ^examine(e1,"Bä","ERROR 5 from basic")
	else  do ^examine(e1,"B"_$CHAR(195),"ERROR 6 from basic")
	if $data(bch) view "BADCHAR"
replace;
	write !,"Testing ZEXTRACT,EXTRACT as a byte by byte replacement",!
	if ("UTF-8"=$ZCHSET) do
	. set samplestr="ＡＢＣＤＥ"	; five 3-byte characters
	. set $EXTRACT(samplestr,2)="B"	; replace the second 3-byte character with a single byte-char
	. do ^examine(samplestr,"ＡBＣＤＥ","samplestr's wider B is replaced with a regular B")
	. set $EXTRACT(samplestr,2)="媪"
	. do ^examine(samplestr,"Ａ媪ＣＤＥ","samplestr's B is replaced with a longer character")
	. ;
	. set $ZEXTRACT(samplestr,9,9)=$ZCHAR(166) ; 166 is the trailing byte of wide-F, Ｆ.
	. do ^examine(samplestr,"Ａ媪ＦＤＥ","by changing one byte, the three byte character Ｃ was transformed into another character, Ｆ")
	. set samplestra=samplestr
	. set $ZEXTRACT(samplestr,10)="" ; delete one byte
	. do ^examine(samplestr,"Ａ媪Ｆ"_$ZCHAR(188)_$ZCHAR(164)_"Ｅ","delete one byte")
	. set $ZEXTRACT(samplestr,10,11)="" ; delete two more bytes
	. set $EXTRACT(samplestra,4,4)=""  ; delete one character
	. do ^examine(samplestr,"Ａ媪ＦＥ","delete one character, byte by byte")
	. do ^examine(samplestra,"Ａ媪ＦＥ","delete one character")
	. do ^examine(samplestr,samplestra,"the same result, derived in two ways")
	. ;
	. ; maxutf8len is the maximum byte length of any str(cnti). Create an stra() array where stra(x) is a string of "a"s of length x:
	. set stra(0)=""
	. for xi=1:1:^maxutf8len set stra(xi)=stra(xi-1)_"a"
	. ; for all elements of str() array, test that replacing bytes one by one works as expected:
	. for cnti=1:1:^cntstr do
	. . set strbx(cnti)=^str(cnti)
	. . for xi=1:1:^utf8len(cnti) do
	. . . set $ZEXTRACT(strbx(cnti),xi)="a"
	. . . do ^examine(strbx(cnti),stra(xi)_$ZEXTRACT(^str(cnti),xi+1,^maxutf8len),"replacing "_xi_" characters of str("_xi_") with ""a""")
	. . . do ^examine($ZLENGTH(strbx(cnti)),^utf8len(cnti),"$ZLENGTH() of the string should not have changed for "_^comments(cnti)_" "_strbx(cnti))
	; the same test, character by character:
	. for cnti=1:1:^cntstr do
	. . set strcx(cnti)=^str(cnti)
	. . for xi=1:1:^ucplen(cnti) do
	. . . set $EXTRACT(strcx(cnti),xi)="a"
	. . . do ^examine(strcx(cnti),stra(xi)_$EXTRACT(^str(cnti),xi+1,^maxucplen),"replacing "_xi_" characters of str("_xi_") with ""a""")
	. . . do ^examine($LENGTH(strcx(cnti)),^ucplen(cnti),"$LENGTH() of the string should not have changed "_^comments(cnti)_" "_strcx(cnti))
boundary;
	write !,"Testing ZEXTRACT,EXTRACT for boundary limits",!
	set chessstr="♚♝A♞♜"
	if ("UTF-8"=$ZCHSET) do
	. do multiequal^examine("",$EXTRACT(chessstr,6),$EXTRACT(chessstr,6,10),$EXTRACT(chessstr,5,2),$EXTRACT(chessstr,$length(chessstr)+1),"ERROR 1 from boundary")
	. do multiequal^examine("",$ZEXTRACT(chessstr,14),$ZEXTRACT(chessstr,14,24),$ZEXTRACT(chessstr,7,2),$ZEXTRACT(chessstr,$Zlength(chessstr)+1),"ERROR 2 from boundary")
	. do multiequal^examine(chessstr,$EXTRACT(chessstr,0,5),$ZEXTRACT(chessstr,0,13),"ERROR 3 from boundary")
	. do multiequal^examine($EXTRACT(chessstr,1,4),$EXTRACT(chessstr,-9,4),$ZEXTRACT(chessstr,1,10),$ZEXTRACT(chessstr,-9,10),"♚♝A♞","ERROR 4 from boundary")
	. do ^examine($EXTRACT(chessstr),"♚","ERROR 5 from boundary")
	. do multiequal^examine($ZEXTRACT(chessstr),$ZCHAR(226),"ERROR 6 from boundary")
	. do multiequal^examine($EXTRACT(chessstr,2,6),$ZEXTRACT(chessstr,4,20),"♝A♞♜","ERROR 7 from boundary")
	. do multiequal^examine("A",$EXTRACT(chessstr,3),$ZEXTRACT(chessstr,7),"ERROR 8 from boundary")
	if ("M"=$ZCHSET) do
	. do multiequal^examine("",$EXTRACT(chessstr,14,14),$ZEXTRACT(chessstr,14,14),"ERROR 9 from boundary")
	. do multiequal^examine("",$EXTRACT(chessstr,$length(chessstr)+1,13),$ZEXTRACT(chessstr,$length(chessstr)+1,13),"ERROR 10 from boundary")
	. do multiequal^examine(chessstr,$EXTRACT(chessstr,0,13),$ZEXTRACT(chessstr,0,13),"ERROR 11 from boundary")
	. do multiequal^examine($EXTRACT(chessstr,1,10),$EXTRACT(chessstr,-9,10),$ZEXTRACT(chessstr,1,10),$ZEXTRACT(chessstr,-9,10),"♚♝A♞","ERROR 12 from boundary")
	. do multiequal^examine($EXTRACT(chessstr),$ZEXTRACT(chessstr),$ZCHAR(226),"ERROR 13 from boundary")
	. do multiequal^examine($EXTRACT(chessstr,4,2),$ZEXTRACT(chessstr,6,4),"","ERROR 14 from boundary")
	. do multiequal^examine($EXTRACT(chessstr,4,14),$ZEXTRACT(chessstr,4,20),"♝A♞♜","ERROR 15 from boundary")
	. do multiequal^examine("A",$EXTRACT(chessstr,7),$ZEXTRACT(chessstr,7),"ERROR 16 from boundary")
	. do multiequal^examine($ZCHAR(157),$EXTRACT(chessstr,6),$ZEXTRACT(chessstr,6),"ERROR 17 from boundary") ; $EXTRACT and $ZEXTRACT should grab the same byte
	. do multiequal^examine($ZCHAR(156),$EXTRACT(chessstr,13),$ZEXTRACT(chessstr,13),"ERROR 18 from boundary") ; $EXTRACT and $ZEXTRACT should grab the same byte
indirection;
	write !,"Testing ZEXTRACT,EXTRACT for indirection",!
	if ("UTF-8"=$ZCHSET) do
	. set x=1
	. set indir="chessstr"
	. set chessstr(x)=chessstr
	. do multiequal^examine($EXTRACT(@indir),$ZEXTRACT(@indir@(x),-9,3),"♚","ERROR 1 from indirection")
	. do multiequal^examine($EXTRACT(@indir@(x),3,5),$ZEXTRACT(@indir,7,200),"A♞♜","ERROR 2 from indirection")
	quit
