unistr
	write "do badcharpiece",!
	do badcharpiece
	write "do litpiece",!
	do litpiece
	write "do extendedpiece",!
	do extendedpiece
	quit
badcharpiece;
	k
	view "NOBADCHAR"
	set target3B=$CHAR($$FUNC^%HD("FF10")) ; set target3B=efbc90
	write "zwrite target3B=",!  set %S=target3B do ^%UTF2HEX zwr %U
	write "set $piece(target3B,$ZCHAR($$FUNC^%HD(""bc"")))=$ZCHAR($$FUNC^%HD(""FF""))",!
	set $piece(target3B,$ZCHAR($$FUNC^%HD("bc")))=$ZCHAR($$FUNC^%HD("FF"))
	write "zwrite target3B=",!  set %S=target3B do ^%UTF2HEX zwr %U
	write !
	k
	set target4B=$CHAR($$FUNC^%HD("1D000")) ; set target4B=f09d8080
	write "zwrite target4B=",!  set %S=target4B do ^%UTF2HEX zwr %U
	set res=$piece(target4B,$ZCHAR($$FUNC^%HD("9D")))
	write "$piece(target4B,$ZCHAR($$FUNC^%HD(""9D"")))=",res,!  
	write "zwrite res=",!  set %S=res do ^%UTF2HEX zwr %U
	;
	set res=$piece(target4B,$ZCHAR($$FUNC^%HD("80")))
	write "$piece(target4B,$ZCHAR($$FUNC^%HD(""80"")))=",res,!  
	write "zwrite res=",!  set %S=res do ^%UTF2HEX zwr %U
	;
	set $piece(target4B,$ZCHAR($$FUNC^%HD("9D")))=$ZCHAR(252)
	write "zwrite target4B=",!  set %S=target4B do ^%UTF2HEX zwr %U
	set $piece(target4B,$ZCHAR($$FUNC^%HD("80")))=$ZCHAR(251)
	write "zwrite target4B=",!  set %S=target4B do ^%UTF2HEX zwr %U
	k
	;
	quit
	
extendedpiece;
	;Following does diffrent $p() tests
	; This covers all possible $piece arguemnt value as unistr data
	SET unistr=$$^getunitemplate()
	set sepcode(1)=$$FUNC^%HD("0")
	set sepcode(2)=$$FUNC^%HD("32")
	set sepcode(3)=$$FUNC^%HD("A8")
	set sepcode(4)=$$FUNC^%HD("645")
	set sepcode(5)=$$FUNC^%HD("986")
	set sepcode(6)=$$FUNC^%HD("2161")
	set sepcode(7)=$$FUNC^%HD("2264")
	set sepcode(8)=$$FUNC^%HD("5901")
	set sepcode(9)=$$FUNC^%HD("1d539")
	; None of the seperator should be present in unistr for the test below to be correct.
	; So replace any seperator from the string unistr with non-sepeator character
	view "NOBADCHAR"
	for charno=1:1:9 DO
	. set unistr=$tr(unistr,sepcode(charno),$char(2439+charno))
	;
	for charno=1:1:9 DO
	. set I=sepcode(charno)
	. ;
	. view "BADCHAR"
	. set delim=$C(I)
	. do piecesubtest0(unistr,delim)
	. do piecesubtest1(unistr,delim)
	. ;
	. view "BADCHAR"
	. set delim=""
	. for cnt=1:1:9 set delim=delim_$C(sepcode(1+$random(9)))
	. do piecesubtest0(unistr,delim)
	. do piecesubtest1(unistr,delim)
	. ;
	. view "NOBADCHAR"
	. set delim=$ZCHAR(128+charno)
	. do piecesubtest0(unistr,delim)
	. do piecesubtest1(unistr,delim)
	. ;
	. view "NOBADCHAR"
	. set delim=$CHAR($random(100000))_$ZCHAR($random(100)+100)_$CHAR($random(10000))_$ZCHAR($random(100)+100)
	. ;set unistr=$tr(unistr,delim,delim_$char(2439+charno))
	. do piecesubtest0(unistr,delim)
	. do piecesubtest1(unistr,delim)
	. ;
	;
	quit
	;
	;
piecesubtest0(unistr,delim)
	new cmpndstr
	set errcnt=0
	set cmpndstr=unistr_delim_unistr_delim_unistr_delim_unistr
	set respieceall=$piece(cmpndstr,delim,1,10)
	do ^examine(respieceall,cmpndstr," $piece(cmpndstr,delim,1,10) ")
	set respiece1=$piece(cmpndstr,delim,1)
	do ^examine(respiece1,unistr," $piece(cmpndstr,delim,1) ")
	set respiecenull=$piece(cmpndstr,delim,100)
	do ^examine(respiecenull,""," $piece(cmpndstr,delim,100) ")
	set respiece12=$piece(cmpndstr,delim,1,2)
	do ^examine(respiece12,(unistr_delim_unistr)," $piece(cmpndstr,delim,1,2) ")
	set respiece23=$piece(cmpndstr,delim,2,3)
	do ^examine(respiece23,(unistr_delim_unistr)," $piece(cmpndstr,delim,2,3) ")
	if errcnt'=0  write "fail from piecesubtest0",!,"zwr=",!  zwr unistr,delim,cmpndstr
	quit
	;
piecesubtest1(unistr,delim)
	new cmpndstr
	set errcnt=0
	set cmpndstr=delim_unistr_delim_unistr_delim_unistr_delim
	set respieceall=$piece(cmpndstr,delim,1,10)
	do ^examine(respieceall,cmpndstr," $piece(cmpndstr,delim,1,10) ")
	set respiece1=$piece(cmpndstr,delim,2)
	do ^examine(respiece1,unistr," $piece(cmpndstr,delim,2) ")
	set respiecenull=$piece(cmpndstr,delim,100)
	do ^examine(respiecenull,""," $piece(cmpndstr,delim,100) ")
	set respiece23=$piece(cmpndstr,delim,2,3)
	do ^examine(respiece23,(unistr_delim_unistr)," $piece(cmpndstr,delim,2,3) ")
	set respiece23=$piece(cmpndstr,delim,3,4)
	do ^examine(respiece23,(unistr_delim_unistr)," $piece(cmpndstr,delim,3,4) ")
	if errcnt'=0  write "fail from piecesubtest1",!,"zwr=",!  zwr unistr,delim,cmpndstr
	q
	;
litpiece;
	view "BADCHAR"
	write $piece("＠＾ＡＢＣ＾ＤＥＦ＾Ｇ＾ ＾","＾",100),!
	write $piece("＠＾ＡＢＣ＾ＤＥＦ＾Ｇ＾ ＾","＾",-1),!
	write $piece("＠＾ＡＢＣ＾ＤＥＦ＾Ｇ＾ ＾","＾",0),!
	write $piece("＠＾ＡＢＣ＾ＤＥＦ＾Ｇ＾ ＾","＾",2,1),!
	write $piece("＠＾ＡＢＣ＾ＤＥＦ＾Ｇ＾ ＾","＾"),!
	write $piece("＠＾ＡＢＣ＾ＤＥＦ＾Ｇ＾ ＾","＾",1),!
	write $piece("＠＾ＡＢＣ＾ＤＥＦ＾Ｇ＾ ＾","＾",1,100),!
	write $piece("＠＾ＡＢＣ＾ＤＥＦ＾Ｇ＾ ＾","＾",1,5),!
	;
	write $piece("＠ ＡＢＣ ＤＥＦ Ｇ   "," "),!
	write $piece("＠ ＡＢＣ ＤＥＦ Ｇ   "," ",1),!
	write $piece("＠ ＡＢＣ ＤＥＦ Ｇ   "," ",1,100),!
	write $piece("＠ ＡＢＣ ＤＥＦ Ｇ   "," ",1,5),!
	quit
	;
