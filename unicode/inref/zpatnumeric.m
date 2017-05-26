zpatnumeric ;
		;do lnumeric^unicodesampledata
		for i=^cntstrnumerics:1:^cntstrnumerice do
		. if ("UTF-8"=$ZCHSET) do
		. . if ("UTF-8"=$ZPATNUMERIC) do
		. . . do ^examine(^str(i)?1N,1,"$ZPATNUMERIC should match "_^str(i)_" "_^comments(i))
		. . if ("M"=$ZPATNUMERIC) do
		. . . do ^examine(^str(i)?1N,0,"$ZPATNUMERIC should not match "_^str(i)_" "_^comments(i))
		. if ("M"=$ZCHSET) do
		. . ; when ZCHSET evaluates to "M" ZPATNUMERIC holds no relevance
		. . do ^examine(^str(i)?1N,0,"$ZPATNUMERIC should not match "_^str(i)_" "_^comments(i))
		;
		set noerror($ZPATNUMERIC)="I should be set with あさきゆめみじ"
		zwrite noerror ; # should display the unicode string set above
		;
		if ("UTF-8"=$ZCHSET) do basic
		quit
basic ;
		if ("UTF-8"=$ZCHSET) do
		set samplestr(1)="०१२" ; # devanagari numerals
		set samplestr(2)="३४५small" ; # devanagari samll numerals
		set samplestr(3)="٤٦'೫೧" ; # Arabic and Kannada numerals
		set samplestr(4)="Ok match all of me ÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß ƠơƢƣƤƥƦƧƨƩƪƫƬƭƮ a mｉxＴuＲe В чащах юга жил-был цитрус ፴፮፸⑥⒇➊➋➌₁₂₃" ; # contains subsricpts and circled numerals
		set samplestr(5)="AnythingBeforeARomanTenThousand१unicodeあさきゆめみじ　ゑひもせず,१२३" ; # contains all devanagari numerals combined with a unicode string
		;
		set store(1)="1 0 0 1 0"
		set store(2)="0 1 0 1 0"
		set store(3)="0 0 1 1 0"
		set store(4)="0 0 0 1 0"
		set store(5)="0 0 0 1 1"
		if ("UTF-8"=$ZPATNUMERIC) do
		. for i=1:1:5 do
		. set j=0
		. . for pattern="3N","3N1""small""","1.3N1P.2N",".E.11N","1.AN1""unicodeあさきゆめみじ　ゑひもせず""1P.N" do ^examine(samplestr(i)?@pattern,$PIECE(store(i)," ",j+1),"pattern match incorrect for "_samplestr(i)_"in piece "_i_" for pattern "_pattern)
		if ("M"=$ZPATNUMERIC) do
		. for i=1:1:5 do
		. . for pattern="3N","3N1""small""","1.3N1P.2N","1.AN1""unicodeあさきゆめみじ　ゑひもせず""1P.N" do ^examine(samplestr(i)?@pattern,0,"pattern match incorrect for "_samplestr(i)_"in piece "_i_" for pattern "_pattern)
		quit
