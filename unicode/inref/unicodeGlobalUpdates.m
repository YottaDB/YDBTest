unicodeGlobalUpdates;
	SET $ZT="g ERROR"
	set verbose=0
	set maxarr=100
	k ^utf8
	write "Start Set unicode Global variable",!
	do main
	write "End Set unicode Global variable",!
	;
	write "Start Test Unicode Order",!
	do unicodeOrder
	write "End Test Unicode Order",!
	;
	write "Start Test Unicode Query Get Data",!
	do unicodeQueryGetData
	write "End Test Unicode Query Get Data",!
	;
	write "Start do killzkill",!
	do killzkill
	write "End do killzkill",!
	;
	write "Start do badcharkill",!
	do badcharkill
	write "End do badcharkill",!
	;
	write "Start do unicodezshowx",!
	do unicodezshowx
	write "End do unicodezshowx",!
	;
	write "Test Completed Successfully",!
	quit
main;
	; Generate Unicode Local
	for I=1:1:maxarr do
	. set subs1=$$^ugenstr(I)
	. set subs2=$$^ulongstr(50)
	. set subs3=$$^ulongstr(70)
	. ;write "$zlengths=",$zlength(subs1)," ",$zlength(subs2)," ",$zlength(subs3),!
	. set ^utf8(subs1)=maxarr*I+I
	. set ^utf8(subs1,subs2)=maxarr*I+I
	. set ^utf8("0",subs2,subs3)=maxarr*I+I
	. set ^utf8(subs1,"0",subs3)=maxarr*I+I
	. set ^utf8(subs1,subs2,"0")=maxarr*I+I
	. set ^utf8(0,subs2,subs3)=maxarr*I+I
	. set ^utf8(subs1,0,subs3)=maxarr*I+I
	. set ^utf8(subs1,subs2,0)=maxarr*I+I
	set ^utf8("чащах юга жил-был цитрус","Hungarian:Árvíztűrő tükörfúrógép.")="nakedinit"
	set ^("чащах юга жил-был цитрус","Příliš žluťoučký")="naked2"
	set ^("чащах юга жил-был цитрус","豈羅爛來祿屢讀數")="naked3"
	set ^("чащах юга жил-был цитрус","綴縢纓缇罾翺翿"_$C(127,255,0,1,5,32,65,66)_"我能吞下玻璃而傷")="naked5"
	w "$reference=",$r,!
	quit

unicodeOrder;
	; test $order
	set subs1=""
	set label1=1
	set numeric=1
	for  do  q:label1=0
	. set lastsubs1=subs1
	. set subs1=$order(^utf8(subs1))
	. if verbose=1 zwr subs1
	. if subs1="" do				; Possible last subscript 
	. . if $data(^utf8(subs1))=0 set label1=0	; Make sure this is not last subscript. We allow null subscript
	. . else  do
	. . . if numeric=0 set label1=0			; Done with scanning
	. . . else  set subs1=$C(0) set numeric=0	; Find next string of same level
	. else  do					; Found next different subscript value of 1st level
	. . if subs1']]lastsubs1 write "Fail $order in level 1",! zwr  halt
	. if (subs1'="")!(numeric=0) do			; Found a subscript
	. . set subs2=$C(0)				; Let's scan only string subs
	. . for  do  q:subs2=""
	. . . set lastsubs2=subs2
	. . . set subs2=$order(^utf8(subs1,subs2))
	. . . if subs2'="" do				; Found a subscript of level 2
	. . . . if verbose=1 zwr subs2
	. . . . if subs2']]lastsubs2 write "Fail $order in level 2",!  zwr  halt
	. . . . set subs3=$C(0)
	. . . . for  do  q:subs3=""
	. . . . . set lastsubs3=subs3
	. . . . . set subs3=$order(^utf8(subs1,subs2,subs3))
	. . . . . if subs3'="" do			; Found a subscript of level 3
	. . . . . . if verbose=1 zwr subs3
	. . . . . . if subs3']]lastsubs3 write "Fail $order in level 3",!  zwr  halt
	quit

unicodeQueryGetData
	set varname="^utf8"
	for  do  quit:varname=""
	. set varname=$query(@varname)
	. if varname'="" do
	. . if ($data(varname)=0) write "Fail: $data(",varname,")",!
	. . if ($get(varname)="") write "Fail: $get(",varname,")",!
	. . if verbose=1 write "Variable=",varname,!
	;
	; This tests $data and $get for utf-8
	write "$data(^utf8)=",$data(^utf8),!
	write "$data(^utf8(0))=",$data(^utf8(0)),!
	write "$data(^utf8(0,0))=",$data(^utf8(0,0)),!
	write "$data(^utf8("""","""")=",$data(^utf8("","")),!
	write "$data(^utf8(0,0,0))=",$data(^utf8(0,0,0)),!
	write "$data(^utf8("""","""","""")=",$data(^utf8("","","")),!
	write "$get(^utf8)=",$get(^utf8),!
	write "$get(^utf8(0))=",$get(^utf8(0)),!
	write "$get(^utf8(0,0))=",$get(^utf8(0,0)),!
	write "$get(^utf8("""","""")=",$get(^utf8("","")),!
	write "$get(^utf8(0,0,0))=",$data(^utf8(0,0,0)),!
	write "$get(^utf8("""","""","""")=",$get(^utf8("","","")),!
	quit

killzkill;
	; Test kill, zkill
	for I=1:1:maxarr do
	. set subs1=$$^ugenstr(I)
	. set subs2=$$^ulongstr(50)
	. set subs3=$$^ulongstr(70)
	. zkill ^utf8(subs1,"",subs3)
	. zwithdraw ^utf8(0,subs2)
	. write "$data(^utf8(subs1))=",$data(^utf8(subs1)),!
	. write "$data(^utf8(0,subs2))=",$data(^utf8(0,subs2)),!
	quit

badcharkill;
	; This covers illegal utf-8 char with valid ones.
	; This make sures there is no boundary condition bug.
	; When a binary key is a subset of another key, it does not kill incorrect data
	; TODO :: view ("BADCHAR":0)	; Disable bad utf-8 char check
	set ^utf8($CHAR($$FUNC^%HD("FF10")))=1 	; set ^utf8(efbc90)=1
	kill ^utf8($ZCHAR($$FUNC^%HD("bc")))  	; kill ^utf8(bc)
	kill ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc"))) ; kill ^utf8(efbc) 
	kill ^utf8($ZCHAR($$FUNC^%HD("90")))		; kill ^utf8(90)  
	kill ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc")),$ZCHAR($$FUNC^%HD("90"))) ; kill ^utf8(efbc,90)
	kill ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc")),"",$ZCHAR($$FUNC^%HD("90"))) ; kill ^utf8(efbc,"",90)
	kill ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc")),0,$ZCHAR($$FUNC^%HD("90"))) ; kill ^utf8(efbc,0,90)
	write "$data(^utf8(efbc90))=",$data(^utf8($CHAR($$FUNC^%HD("FF10")))),!
	write "$GET(^utf8(efbc90))=",$GET(^utf8($CHAR($$FUNC^%HD("FF10")))),!
	;
	set ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc")),$ZCHAR($$FUNC^%HD("90")))=1 ; set ^utf8(efbc,90)=1
	zkill ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc"))) ; zkill ^utf8(efbc)
	kill ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc"),$$FUNC^%HD("90"))) ; kill ^utf8(efbc90)
	kill ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc")),"",$ZCHAR($$FUNC^%HD("90"))) ; kill ^utf8(efbc,"",90)
	kill ^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc")),0,$ZCHAR($$FUNC^%HD("90"))) ; kill ^utf8(efbc,0,90)
	write "$data(^utf8(efbc,90))=",$data(^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc")),$ZCHAR($$FUNC^%HD("90")))),!
	write "$get(^utf8(efbc,90))=",$get(^utf8($ZCHAR($$FUNC^%HD("ef"),$$FUNC^%HD("bc")),$ZCHAR($$FUNC^%HD("90")))),!
	quit

unicodezshowx;
	;This test zshow with unicode data
	;
	set xec1="set xecvar1=""Falsches Üben von Xylophonmusik quält jeden größeren Zwerg."""
	set xec2="set xecvar1(""Falsches Üben von Xylophonmusik quält jeden größeren Zwerg."")=100"
	set xec3="adir(""ＡＤＩＲ"")=""αβγδε"""
	set xec4="set xecvar4(""Příliš žluťoučký kůň úpěl ďábelské kódy."")=200"
	set xec5="kill xecvar4(""Příliš žluťoučký kůň úpěl ďábelské kódy."")"
	xecute xec1
	xecute xec2
	set @xec3
	xecute xec4
	xecute xec5
	lock litfn1("লায়েক")
	lock litfn2("αβγδε")
	lock litfn3("我能吞下玻璃而不伤身体")
	;
	zshow "V":zshowvar("Falsches Üben von Xylophonmusik quält jeden größeren Zwerg.")
	zshow "B":zshowvar("Pchnąć w tę łódź jeża lub ośm skrzyń fig.")
	zshow "C":zshowvar("Příliš žluťoučký kůň úpěl ďábelské kódy.")
			; Externa Call table is done by code "C": Ask Steve for its test. TODO
	zshow "D":zshowvar("В чащах юга жил-был цитрус? Да, но фальшивый экземпляр! ёъ.")
	zshow "L":zshowvar("いろはにほへど　ちりぬるを")
	zshow "I":zshowvar("あさきゆめみじ　ゑひもせず")
	zshow "S":zshowvar("①②③④⑤⑥⑦⑧")
	zshow "*":zshowvar("लोकांना मराठी का बोलता येत नाही?")
	quit

ERROR   ;	
	SET $ZT=""
        ZSHOW "*"
	halt
