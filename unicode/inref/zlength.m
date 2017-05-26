zlength ;
		; Identify the $ZCHSET value and set corresponding local vars to proceed appropriately
		; since the steps and the M-arrays used from unicodesampledata.m will vary based on that
		if ("UTF-8"=$ZCHSET) set len="^ucplen"
		else  set len="^utf8len"
		write !,"Testing ZLENGTH,LENGTH for the entire unicode sample data range",!
		for i=1:1:^cntstr do ^examine($ZLENGTH(^str(i)),^utf8len(i),"$ZLENGTH of "_^str(i)_" "_^comments(i)_"should be equal to its utf8length "_^utf8len(i))
		for i=1:1:^cntstr do ^examine($LENGTH(^str(i)),@len@(i),"$LENGTH of "_^str(i)_"should be equal to its "_len_" "_^comments(i)_" "_@len@(i))
		;;;
		write !,"Testing ZLENGTH,LENGTH with sample arabic literals as delimeters",!
		for i=1:1:^cntstr do
		. set strcombined(i)=^str(i)_"۩"_^str(i)_"۩"_"۝"_"۩"_^str(i)_"۝"
		. do multiequal^examine($ZLENGTH(strcombined(i),"۩"),$LENGTH(strcombined(i),"۩"),4,"$LENGTH with ۩ as delimeter should give 4 for "_strcombined(i))
		. do multiequal^examine($ZLENGTH(strcombined(i),"۝"),$LENGTH(strcombined(i),"۝"),3,"$LENGTH with ۝ as delimeter should give 3 for "_strcombined(i))
basic ;
		; since we have byte by byte processing below we need to turn BADCHAR off
		if $VIEW("BADCHAR") do
		. set bch=1
		. view "NOBADCHAR"
		write !,"Testing ZLENGTH,LENGTH on a sample unicode literal",!
		set str="A"_$ZCHAR(132)_"Ä"
		do ^examine($ZLENGTH(str),4,"$ZLENGTH on Ä")
		do ^examine($ZLENGTH(str,$ZCHAR(132)),3,"$ZLENGTH on Ä")
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($LENGTH(str),3,"$LENGTH on Ä")
		. do ^examine($LENGTH(str,$ZCHAR(132)),2,"$LENGTH on Ä")
		if ("M"=$ZCHSET) do
		. do ^examine($LENGTH(str),4,"$LENGTH on Ä")
		. do ^examine($LENGTH(str,$ZCHAR(132)),3,"$LENGTH on Ä")
invalidmix;
		;
		write !,"Testing ZLENGTH,LENGTH with only invalid mix of bytes",!
		set strinvalid1=$ZCHAR(199,199,199)
		do multiequal^examine($ZLENGTH(strinvalid1),$LENGTH(strinvalid1),3,"$ZLENGTH and $LENGTH should give 3 for "_strinvalid1)
		;
		;
		write !,"Testing ZLENGTH,LENGTH with valid and invalid mix of bytes",!
		; do not use ^str(cnti) here because the invalid mix used here might interfere
		; instead define an array of 10 unciode strings that will not contain $C(199) and make use of them for the below logic
		set local(1)="௯ஙச",local(2)="ஞடண",local(3)="தநப",local(4)="யரற",local(5)="வஷஸ",local(6)="ァアィ",local(7)="グコザ",local(8)="ッツテ",local(9)="〘〙〓",local(10)="〚〛〓"
		for j=1:1:10 set localutf8len(j)=9
		for j=1:1:10 set localucplen(j)=3
		for i=1:1:10 do
		. set strinvalid2(i)=local(i)_"۩"_$ZCHAR(199,199,199)_"۝"_$ZCHAR(199,199,199)
		. do multiequal^examine($ZLENGTH(strinvalid2(i),"۩"),$LENGTH(strinvalid2(i),"۩"),2,"$LENGTH with ۩ as delimeter should give 2 for "_strinvalid2(i))
		. do multiequal^examine($ZLENGTH(strinvalid2(i),$ZCHAR(199,199,199)),$LENGTH(strinvalid2(i),$ZCHAR(199,199,199)),3,"$LENGTH and $ZLENGTH with $ZCHAR(199,199,199) as delimter should give 3 for "_strinvalid2(i))
		. if ("UTF-8"=$ZCHSET) do
		. . do ^examine($ZLENGTH(strinvalid2(i)),localutf8len(i)+10,"$ZLENGTH should be 10 plus the utf8length of the string "_strinvalid2(i))
		. . do ^examine($LENGTH(strinvalid2(i)),localucplen(i)+8,"$LENGTH should be 8 plus the ucplength of the string "_strinvalid2(i))
		. else  do multiequal^examine($ZLENGTH(strinvalid2(i)),$LENGTH(strinvalid2(i)),localutf8len(i)+10,"$ZLENGTH and $LENGTH should be 10 plus the utf8length of the string in M"_strinvalid2(i))
		. ;
		. set strinvalid3(i)=local(i)_"۩"_$ZCHAR(1999,2299,199)_"۝"_$ZCHAR(199,2299,199)
		. do multiequal^examine($ZLENGTH(strinvalid3(i),"۩"),$LENGTH(strinvalid3(i),"۩"),2,"$ZLENGTH and $LENGTH should return 2 for ۩ in "_strinvalid3(i))
		. do multiequal^examine($ZLENGTH(strinvalid3(i),$ZCHAR(2299)),$LENGTH(strinvalid3(i),$ZCHAR(2299)),0,"$ZLENGTH and $LENGTH should return 0 for $C(2299) in "_strinvalid3(i))
		. do multiequal^examine($ZLENGTH(strinvalid3(i),$ZCHAR(199)),$LENGTH(strinvalid3(i),$ZCHAR(199)),4,"$ZLENGTH and $LENGTH should return 4 for $C(199) in "_strinvalid3(i))
		. if ("UTF-8"=$ZCHSET) do
		. . do ^examine($ZLENGTH(strinvalid3(i)),localutf8len(i)+7,"$ZLENGTH should be 7 plus the utf8length of the string "_strinvalid3(i))
		. . do ^examine($LENGTH(strinvalid3(i)),localucplen(i)+5,"$LENGTH should be 5 plus the ucplength of the string "_strinvalid3(i))
		. else  do multiequal^examine($ZLENGTH(strinvalid3(i)),$LENGTH(strinvalid3(i)),localutf8len(i)+7,"$ZLENGTH and $LENGTH should be 7 plus the utf8length of the string "_strinvalid3(i))
indirection ;
		write !,"Testing ZLENGTH,LENGTH for indirection",!
		set str="A"_$ZCHAR(132)_"Ä"
		set instr="str"
		set store=$ZCHAR(132)
		set inzchar132="store"
		do ^examine($ZLENGTH(@instr),4,"$ZLENGTH with Ä delim and indirection should give 4 for "_@instr)
		do ^examine($ZLENGTH(@instr,@inzchar132),3,"$ZLENGTH with $ZC(132) delim and indirection should give 3 for "_@instr)
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($LENGTH(@instr),3,"$LENGTH with indirection should give 3 for "_@instr)
		. do ^examine($LENGTH(@instr,@inzchar132),2,"$LENGTH with $ZC(132) delim and indirection should give 2 for "_@instr)
		if ("M"=$ZCHSET) do
		. do ^examine($LENGTH(@instr),4,"$LENGTH with indirection should give 4 for "_@instr)
		. do ^examine($LENGTH(@instr,@inzchar132),3,"$LENGTH with $ZC(132) delim and indirection should give 3 for "_@instr)
		if $data(bch) view "BADCHAR"
		quit
