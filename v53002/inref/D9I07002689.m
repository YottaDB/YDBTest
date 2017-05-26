D9I07002689	; test optional QUIT agnostic behavior
	;
	Write !,"$ZQUIT = ",$ZQUIT
	Set $ZQUIT='$ZQUIT
	Write !,"$ZQUIT = ",$ZQUIT
	Set $ZQUIT='$ZQUIT
	Write !,"$ZQUIT = ",$ZQUIT
	New (act),$ESTACK
	If '$D(act) New act Set act="Set EC=$ECODE ZSHOW ""*"""
	Set ZQUIT=0,cnt=0,(EC,$ECODE)=""
	New $ETRAP
	Set $ETRAP="DO error"
	Do label
	Do flabeldo("DO")
	Do funk1
	Do indrq("DO")
	Do correct1("DO")
	Do correct2("DO")
	Do correct3("DO")
	Write $$extrin("$$")
	Write $$flabeldo("$$"),"<"
	Write $$indrq("$$")
	Write $$correct1("$$")
	Write $$correct2("$$")
	Write $$correct3("$$")
	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$T(+0)," with $ZQUIT=",$ZQUIT,!
	Quit
error	If $ZQUIT,$Increment(cnt) Xecute:EC'=$ECODE act
	ELSE  If '$Quit,$ZSTATUS["NOTEXTRINSIC" Set (EC,$ECODE)=""
	Else  If $ZSTATUS["QUITARGREQD",1=$ESTACK Do  Goto @targ
	. Set (EC,$ECODE)="",targ=$Piece($ZSTATUS,",",2),$P(targ,"^",1)=$Piece(targ,"+",1)_"+"_($Piece(targ,"+",2)+1)
	Else  If $Increment(cnt) Xecute:EC'=$ECODE act 
	Quit

label	Write !,"DO of a plain label"
	Xecute "Write "" and an XECUTE with it"""_" Quit"
	Quit
	If $Increment(cnt) Write !,"QUIT failed"
	Quit:$Quit x Quit
flabeldo(x)
	Write !,"formallist label with plain QUIT; x = ",x
	Quit
	If $Increment(cnt) Write !,"QUIT failed"
	Quit:$Quit x Quit
extrin(x)
funk1	Write !,"extrinsic label with argument on QUIT; x = ",$Get(x,"no x defined")
	Quit $Get(x)+1
	If $Increment(cnt) Write !,"QUIT failed"
	Quit:$Quit x Quit
indrq(x)
	Write !,"extrinsic label with indirect QUIT argument; x = ",x
	Set a="x"
	Quit @a
	If $Increment(cnt) Write !,"QUIT failed"
	Quit:$Quit x Quit
correct1(x)
	Write !,"Q:$Q arg Q; x = ",x
	Quit:$Quit x Quit
	If $Increment(cnt) Write !,"QUIT failed"
	Quit:$Quit x Quit
correct2(x)
	Write !,"Q:'$Q  Q arg; x = ",x
	Quit:'$Quit  Quit x
	If $Increment(cnt) Write !,"QUIT failed"
	Quit:$Quit x Quit
correct3(x)
	Write !,"Q ^a(x)"
	Set ^a(x)=x
	Quit ^a(x)
badcode	
	Quit x,x		; this line should give a compilation error
	set x=1 quit set x=2 	; this line should give a compilation error
