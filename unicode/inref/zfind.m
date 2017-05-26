zfind ;
		; Identify the $ZCHSET value and set corresponding local vars to proceed appropriately
		; since the steps and the M-arrays used from unicodesampledata.m will vary based on that
		if ("UTF-8"=$ZCHSET) set len="^ucplen"
		else  set len="^utf8len"
		write !,"Testing ZFIND,FIND for the entire unicode sample data range",!
		; * match/find the whole string
		for xi=1:1:^cntstr  do
		. set note=" the whole string section failed for "_^str(xi)_" "_^comments(xi)
		. ; we cannot pass any evaluated strings inside $CHAR,$ZCHAR.This is a feature in the language. So we need to use charit calls to pass one
		. set tmpstr=$$zcharit^charit(^utf8(xi))
		. do ^examine($ZFIND(^str(xi),tmpstr),$ZLENGTH(^str(xi))+1,"ZFIND"_note)
		. do ^examine($ZFIND(^str(xi),tmpstr,0),$ZLENGTH(^str(xi))+1,"ZFIND"_note)
		. do ^examine($ZFIND(^str(xi),tmpstr,-9),$ZLENGTH(^str(xi))+1,"ZFIND"_note)
		; * match/find sub-strings
		; for sub-string match avoid badchar samples, and repetitive string samples.It is enough if a use a very small subset of
		; unicodesampledata that will have both ascii and utf8 char mix. cntstrfind{s,e} will hold such strings.
		for xi=^cntstrfinds:1:^cntstrfinde  do
		. for xj=^cntstrfinds:1:^cntstrfinde  do
		. . ; make sure the same string is not appended and avoid null strings
		. . if (^str(xi)'=^str(xj)) do
		. . . set teststr=^str(xi)_^str(xj)_^str(xi)_^str(xj)
		. . . set note=" a sub string section failed for "_teststr_" "_^comments(xj)
		. . . do ^examine($FIND(teststr,^str(xj)),@len@(xi)+@len@(xj)+1,"FIND"_note)
		. . . do ^examine($FIND(teststr,^str(xj),@len@(xi)+@len@(xj)+1),(2*@len@(xi))+(2*@len@(xj))+1,"FIND"_note)
		. . . ;(basically, the same sub-string exists in the teststr twice, try to $FIND both)
		. . . do ^examine($ZFIND(teststr,^str(xj)),^utf8len(xi)+^utf8len(xj)+1,"ZFIND"_note)
		. . . do ^examine($ZFIND(teststr,^str(xj),^utf8len(xi)+^utf8len(xj)+1),(2*^utf8len(xi))+(2*^utf8len(xj))+1,"ZFIND"_note)
samplesets ;
		; since we have byte by byte processing below we need to turn BADCHAR off
		if $VIEW("BADCHAR") do
		. set bch=1
		. view "NOBADCHAR"
		; lets have some sample unicode literals of 2 bytes, 3 bytes and 4 bytes defined in separate arrays
		; other than the generic str(cnti) from unicodesampledata
		; * match/find literals
		write !,"Testing ZFIND,FIND for some sample sets",!
		set char2(1)="Ά",char2(2)="Έ",char2(3)="ΐ",char2(4)="Ψ",char2(5)="Ω",char2(6)="Ю",char2(7)="ф",char2(8)="ђ",char2(9)="Ѫ",char2(10)="ѥ"
		set char3(1)="Ẫ",char3(2)="Ẹ",char3(3)="ị",char3(4)="ỵ",char3(5)="Ẉ",char3(6)="ῆ",char3(7)="ΰ",char3(8)="ῼ",char3(9)="ῷ",char3(10)="ᾯ"
		set char4(1)="𝑨",char4(2)="𝑩",char4(3)="𝑳",char4(4)="𝑹",char4(5)="𝑼",char4(6)="𝒁",char4(7)="𝒉",char4(8)="𝒓",char4(9)="𝒛",char4(10)="𝒠"
		set utf8char4(1)="240,157,145,168",utf8char4(2)="240,157,145,169",utf8char4(3)="240,157,145,179",utf8char4(4)="240,157,145,185",utf8char4(5)="240,157,145,188",utf8char4(6)="240,157,146,129",utf8char4(7)="240,157,146,137",utf8char4(8)="240,157,146,147",utf8char4(9)="240,157,146,155",utf8char4(10)="240,157,146,160"
		set strtest1="" for i=1:1:10 set strtest1=strtest1_char2(i)
		set strtest2="" for i=1:1:10 set strtest2=strtest2_char3(i)
		set strtest3="" for i=1:1:10 set strtest3=strtest3_char4(i)
		set mixed="ΨΈẸẪΆΨῷ"
		if ("UTF-8"=$ZCHSET) do
		. set note=" for char2 array failed for "
		. for i=1:1:10 do ^examine($ZFIND(strtest1,char2(i)),(i*2)+1,"ZFIND "_note_char2(i))
		. for i=1:1:10 do ^examine($FIND(strtest1,char2(i)),i+1,"FIND "_note_char2(i))
		. set note=" for char3 array failed for "
		. for i=1:1:10 do ^examine($ZFIND(strtest2,char3(i)),(i*3)+1,"ZFIND "_note_char3(i))
		. for i=1:1:10 do ^examine($FIND(strtest2,char3(i)),i+1,"FIND "_note_char3(i))
		. set note=" for char4 array failed for "
		. for i=1:1:10 do ^examine($ZFIND(strtest3,char4(i)),(i*4)+1,"ZFIND "_note_char4(i))
		. for i=1:1:10 do ^examine($FIND(strtest3,char4(i)),i+1,"FIND "_note_char4(i))
		. set note=" failed for "_mixed
		. do ^examine($FIND(mixed,"Ẹ"),4,"$FIND "_note_" at Ẹ")
		. do ^examine($ZFIND(mixed,"Ẹ"),8,"$ZFIND "_note_" at Ẹ")
		. do ^examine($ZFIND(mixed,"Ά"),13,"$ZFIND "_note_" at Ά")
		. do multiequal^examine($FIND(mixed,"ῷ"),$length(mixed)+1,8,"FIND "_note_" at ῷ")
		. do ^examine($FIND(mixed,"Ψ"),2,"$FIND "_note_" at Ψ")
		. do ^examine($FIND(mixed,"Ψ",2),7,"$FIND "_note_" at Ψ")
		. do ^examine($ZFIND(mixed,"Ψ"),3,"$ZFIND "_note_" at Ψ")
		. do ^examine($ZFIND(mixed,"Ψ",2),15,"$ZFIND "_note_" at Ψ")
		. ; test a single byte as the search character for $FIND and $ZFIND
		. do ^examine($FIND(strtest1,$ZCHAR(168)),0,"cannot $FIND() only part of Ψ")
		. do ^examine($ZFIND(strtest1,$ZCHAR(168)),9,"should $ZFIND() only part of Ψ")
		. do ^examine($FIND(strtest1,$ZCHAR(206,168)),5,"can $FIND() Ψ")
		. do ^examine($FIND(strtest1,$ZCHAR(206,168,206)),0,"cannot $FIND() Ψ and part of Ω")
		. do ^examine($ZFIND(strtest1,$ZCHAR(206,168,206)),10,"can $ZFIND() Ψ and part of Ω")
		. do ^examine($FIND(strtest2,$ZCHAR(191,183)),0,"cannot $FIND() only part of ῷ")
		. do ^examine($ZFIND(strtest2,$ZCHAR(191,183)),28,"should $ZFIND() only part of ῷ")
		. do ^examine($FIND(strtest2,$ZCHAR(225,191,183)),10,"can $FIND() ῷ")
		. do ^examine($FIND(strtest2,$ZCHAR(225,191,183,225)),0,"cannot $FIND() ῷ and part of ᾯ")
		. do ^examine($ZFIND(strtest2,$ZCHAR(225,191,183,225)),29,"can $ZFIND() ῷ and part of ᾯ")
		. ; test some 4 byte characters
		. set note=" for char4 array failed for "
		. ; we cannot pass any evaluated strings inside $CHAR,$ZCHAR.This is a feature in the language. So we need to use charit calls to pass one
		. for i=1:1:10 do
		. . set tmpstr=$$zcharit^charit(utf8char4(i))
		. . do ^examine($FIND(char4(i),tmpstr),2,"$FIND "_note_char4(i))
		. . do ^examine($ZFIND(char4(i),tmpstr),5,"$ZFIND "_note_char4(i))
		if ("M"=$ZCHSET) do
		. for i=1:1:10 do multiequal^examine($ZFIND(strtest1,char2(i)),$FIND(strtest1,char2(i)),(i*2)+1,"ZFIND/FIND failed for "_char2(i))
		. for i=1:1:10 do multiequal^examine($ZFIND(strtest2,char3(i)),$FIND(strtest2,char3(i)),(i*3)+1,"ZFIND/FIND failed for "_char3(i))
		. for i=1:1:10 do multiequal^examine($ZFIND(strtest3,char4(i)),$FIND(strtest3,char4(i)),(i*4)+1,"ZFIND/FIND failed for "_char4(i))
		. set note=" failed for "_mixed
		. do multiequal^examine($ZFIND(mixed,"Ẫ"),$FIND(mixed,"Ẫ"),11,"$FIND "_note_" at Ẫ")
		. do multiequal^examine($ZFIND(mixed,"ῷ"),$FIND(mixed,"ῷ"),$length(mixed)+1,18,"$ZFIND "_note_" at ῷ")
		. do multiequal^examine($ZFIND(mixed,"Ψ"),$FIND(mixed,"Ψ"),"$FIND "_note_" at Ψ")
		. do multiequal^examine($ZFIND(mixed,"Ψ",2),$FIND(mixed,"Ψ",2),15,"$FIND "_note_" at Ψ")
		. ;
		. do multiequal^examine($ZFIND(strtest1,$ZCHAR(168)),$FIND(strtest1,$ZCHAR(168)),9,"should $ZFIND() and $FIND() only part of Ψ")
		. do multiequal^examine($ZFIND(strtest1,$ZCHAR(206,168,206)),$FIND(strtest1,$ZCHAR(206,168,206)),10,"can $ZFIND() and $FIND() Ψ and part of Ω")
		. do multiequal^examine($ZFIND(strtest2,$ZCHAR(191,183)),$FIND(strtest2,$ZCHAR(191,183)),28,"should $ZFIND() and $FIND() only part of ῷ")
		. do multiequal^examine($ZFIND(strtest2,$ZCHAR(225,191,183,225)),$FIND(strtest2,$ZCHAR(225,191,183,225)),29,"can $ZFIND() and $FIND() ῷ and part of ᾯ")
		. for i=1:1:10 do multiequal^examine($ZFIND(char4(i),$ZCHAR($PIECE(utf8char4(i),",",1,4))),$FIND(char4(i),$ZCHAR($PIECE(utf8char4(i),",",1,4))),5)
		. ;
nonchar ;
		write !,"Testing ZFIND,FIND on some nonchar sets",!
		set strt="ΨΈẸẪΆΨ"_$ZCHAR(206,240,144,128)_"ῷ" ; $ZCHAR(206,168) is "Ψ" U+03A8, and $ZCHAR(240,144,128,128) is U+10000
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($FIND(strt,$ZCHAR(206)),8,"ERROR 1 from nonchar")
		. do ^examine($FIND(strt,$ZCHAR(240)),9,"ERROR 2 from nonchar")
		. do ^examine($FIND(strt,$ZCHAR(206,240)),9,"ERROR 3 from nonchar")
		. do ^examine($FIND(strt,$ZCHAR(240,144)),10,"ERROR 4 from nonchar")
		. do ^examine($FIND(strt,$ZCHAR(240,144,128)),11,"ERROR 5 from nonchar")
		. do ^examine($FIND(strt,$ZCHAR(144,128)),11,"ERROR 6 from nonchar")
		. ;
		. do ^examine($ZFIND(strt,$ZCHAR(206)),2,"ERROR 7 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(206),2),4,"ERROR 8 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(206),4),12,"ERROR 9 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(206),12),14,"ERROR 10 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(240)),17,"ERROR 11 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(206,240)),17,"ERROR 12 from nonchar")
		if ("M"=$ZCHSET) do
		. do ^examine($ZFIND(strt,$ZCHAR(206)),2,"ERROR 13 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(206),2),4,"ERROR 14 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(206),4),12,"ERROR 15 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(206),12),14,"ERROR 16 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(240)),17,"ERROR 17 from nonchar")
		. do ^examine($ZFIND(strt,$ZCHAR(206,240)),17,"ERROR 18 from nonchar")
		if $data(bch) view "BADCHAR"
indirection ;
		write !,"Testing ZFIND,FIND for indirection",!
		set inmixed="mixed"
		set inteststr="teststr"
		set instr="^str"
		set note=" of indirection failed for "_^comments(xi)_" "
		; no need to repeat the below section as "len" variable set at the very beginning will take care of
		; substituting proper vars for proper zchset
		for xi=^cntstrfinds:1:^cntstrfinde  do
		. for xj=^cntstrfinds:1:^cntstrfinde  do
		. . ; make sure the same string is not appended and avoid null strings
		. . if (^str(xi)'=^str(xj)) do
		. . . set teststr=^str(xi)_^str(xj)_^str(xi)_^str(xj)
		. . . do ^examine($FIND(@inteststr,@instr@(xj)),@len@(xi)+@len@(xj)+1,"$FIND "_note_@inteststr)
		. . . do ^examine($FIND(@inteststr,@instr@(xj),@len@(xi)+@len@(xj)+1),(2*@len@(xi))+(2*@len@(xj))+1,"$FIND "_note_@inteststr)
		. . . ;(basically, the same sub-string exists in the teststr twice, try to $FIND both)
		. . . do ^examine($ZFIND(@inteststr,@instr@(xj)),^utf8len(xi)+^utf8len(xj)+1,"$ZFIND "_note_@inteststr)
		. . . do ^examine($ZFIND(@inteststr,@instr@(xj),^utf8len(xi)+^utf8len(xj)+1),(2*^utf8len(xi))+(2*^utf8len(xj))+1,"$ZFIND "_note_@inteststr)
		if ("UTF-8"=$ZCHSET) do
		. do multiequal^examine($FIND(@inmixed,"ῷ"),$length(@inmixed)+1,8,"$FIND "_note_@inmixed)
		. do ^examine($ZFIND(@inmixed,"Ψ",2),15,"$ZFIND "_note_@inmixed)
		. do ^examine($ZFIND(@inmixed,"Ά"),13,"$ZFIND "_note_@inmixed)
		if ("M"=$ZCHSET) do
		. do multiequal^examine($ZFIND(@inmixed,"Ψ",2),$FIND(@inmixed,"Ψ",2),15,"$ZFIND and $FIND "_note_@inmixed)
		. do multiequal^examine($ZFIND(@inmixed,"ῷ"),$FIND(mixed,"ῷ"),$length(@inmixed)+1,18,"$ZFIND and $FIND "_note_@inmixed) ; keep one without indirection here
		quit
