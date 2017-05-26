readwrit	; test read/write/zwrite for long names
	write !,"######## test read/write/zwrite for long names ####### ",!!
	set maxlen=31
	do init^lotsvar
	set file="forread.txt"
	open file:(readonly)
	for len=7,8,9,31 do
	. use $principal
	. write "----------------- len = ",len," -------------",!
	. do onevar^lotsvar(len,1)
	. set var=strnosub
	. set gbl="^"_var
	. ; read from the file
	. use file
	. read @var
	. read @var@(1)
	. read @var@(1,var)
	. read *@var@(2)
	. read @var@(2,var)#2
	. read @gbl
	. read @gbl@(1)
	. read @gbl@(1,var)
	. read *@gbl@(1,2)
	. read ^("naked")
	. ; write
	. use $principal
	. write @var,!
	. write @var@(1),!
	. write @var@(1,var),!
	. write @var@(2),!
	. write @var@(2,var),!
	. write @gbl,!
	. write @gbl@(1),!
	. write @gbl@(1,var),!
	. write @gbl@(1,2),!
	. write ^("naked"),! 
	. ; zwrite
	. zwrite @var
	. zwrite @var@(1)
	. zwrite @gbl
	. zwrite @gbl@(1)
	. zwrite @gbl@(1,2)
	. zwrite ^("naked")
	close file
	new  ;to get rid of locals from the above test
	write !,"########## test more with set and zwrite for long names ########",!!
	set postconditional=0
	set postcond=1
	set:postconditional ^n234567890123456789012345678901="a1"
	set:'postconditional ^y234567890123456789012345678901="a2"
	do ^examine($data(^n234567890123456789012345678901)_$DATA(^y234567890123456789012345678901),"01","post-conditional set at"_$ZPOSITION)
	set ^jhfdb97531ZXVTRPNLJH("jhfdb97531ZXVTRPNLJH",20)="jhfdb97531ZXVTRPNLJH"
	set ^ahgdbkdfgpaogdjgksjfdgsogjlkjdg(1,"jh",2)="random12"
	set ^("naked")="random naked"
	set ^(3,4)="random 34"
	set ^(5)="random 5"
	set ^%AB3456789012345678901234567890(1,2)=12
	set ^%BC3456789012345678901234567890(1,"March")=12
	set ^%CD3456789012345678901234567890(1,"april")=12
	set ^%DE3456789012345678901234567890(1,"June")=12
	set ^%EF3456789012345678901234567890(1,"may",3)=12
	set B234567890123456789012345678901("x123")="x123"
	set B234567890123456789012345678901("x234")="x234"
	set B234567890123456789012345678901("x345")="x345"
	set B234567890123456789012345678901("xy123","ss",3)="x123"
	set B234567890123456789012345678901("xy123","rr",3)="x123"
	set xstr="zwrite ^ahgdbkdfgpaogdjgksjfdgsogjlkjdg"
	write !,"---- ",xstr," ----",!  xecute xstr
	set xstr="zwrite ^?1""%""2U.E(,""A"":""z"")"
	write !,"---- ",xstr," ----",!  xecute xstr
	set xstr="zwrite ?1""B"".E(?1""x""3N)"
	write !,"---- ",xstr," ----",!  xecute xstr
	set xstr="zwrite ?.E(,:,3)"
	write !,"---- ",xstr," ----",!  xecute xstr
	set xstr="zwrite ^ahgdbkdfgpaogdjgksjfdgsogjlkjdg(1,*)"
	write !,"---- ",xstr," ----",!  xecute xstr
	write !,"ZWRITE output",!
	zwrite
	set xstr="zshow ""V"":zshowvariable"
	write !,"---- ",xstr," ----",!  xecute xstr
	do ^examine($DATA(zshowvariable),"10","ZSHOW:""V"" at "_$ZPOSITION)
	set xstr="zwrite zshowvariable"
	write !,"---- ",xstr," ----",!  xecute xstr
	quit
