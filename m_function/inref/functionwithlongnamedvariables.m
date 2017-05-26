functionwithlongnamedvariables	; test M functions
	set seperator="##############################################################"
init	; set some globals
	set ^longglobalnameformfunctiontesta="a"
	set ^longglobalnameformfunctiontesta(1)="a1"
	set ^(2)="a2"
	set ^(2,3)="a23"
	set ^(2,4)="a24"
	set ^longglobalnameformfunctiontesta("B")="ab"
	set ^("B",2)="ab2"
	set ^longglobalnameformfunctiontestb="b"
	set ^longglobalnameformfunctiontestc(1)="c1"
	set ^(1,1)="c11"
	set ^longglobalnameformfunctiontestc(2)="c2"
	set ^(2,1)="c21"
	set ^(2,2)="c22"
	set ^longglobalnameformfunctiontestc(2,2,3)="c223"
	set ^(2,2,4)="c224"
	set ^("C",1)="cc1"
	set ^("C","cc",234,"aa")="clevel4"
	set ^longglobalnameformfunctiontestc("C",2,"third")="cc23"
	set ^longglobalnameformfunctiontestc("D",23,2)="cd23"
	set ^longglobalnameformfunctiontestc("E","thisisE")="ce"
	set ^longglobalnameformfunctiontestc("F","thisisF")="cf"
	;set some locals
	set longlocalnameformfunctiontesta="a"
	set longlocalnameformfunctiontesta(1)="a1"
	set longlocalnameformfunctiontesta(2)="a2"
	set longlocalnameformfunctiontesta(2,3)="a23"
	set longlocalnameformfunctiontesta(2,4)="a24"
	set longlocalnameformfunctiontesta("B")="ab"
	set longlocalnameformfunctiontesta("B",2)="ab2"
	set longlocalnameformfunctiontestb="b"
	set longlocalnameformfunctiontestc(1)="c1"
	set longlocalnameformfunctiontestc(1,1)="c11"
	set longlocalnameformfunctiontestc(2)="c2"
	set longlocalnameformfunctiontestc(2,1)="c21"
	set longlocalnameformfunctiontestc(2,2)="c22"
	set longlocalnameformfunctiontestc(2,2,3)="c223"
	set longlocalnameformfunctiontestc(2,2,4)="c224"
	set longlocalnameformfunctiontestc("C",1)="cc1"
	set longlocalnameformfunctiontestc("C","cc",234,"aa")="clevel4"
	set longlocalnameformfunctiontestc("C",2,"third")="cc23"
	set longlocalnameformfunctiontestc("D",23,2)="cd23"
	set longlocalnameformfunctiontestc("E","thisisE")="ce"
	set longlocalnameformfunctiontestc("F","thisisF")="cf"
data	; test $data
	write seperator,!
	write "Test $DATA",!
	do ^examine($data(^longglobalnameformfunctiontesta),11,$zpos)
	do ^examine($data(^longglobalnameformfunctiontestb),1,$zpos)
	do ^examine($data(^longglobalnameformfunctiontestc),10,$zpos)
	do ^examine($data(^longglobalnameformfunctiontestd),0,$zpos)
	do ^examine($data(^longglobalnameformfunctiontesta(1)),1,$zpos)
	do ^examine($data(^longglobalnameformfunctiontestb(1)),0,$zpos)
	do ^examine($data(^longglobalnameformfunctiontestc(1)),11,$zpos)
	do ^examine($data(^longglobalnameformfunctiontestc("C")),10,$zpos)
	; locals
	do ^examine($data(longlocalnameformfunctiontesta),11,$zpos)
	do ^examine($data(longlocalnameformfunctiontestb),1,$zpos)
	do ^examine($data(longlocalnameformfunctiontestc),10,$zpos)
	do ^examine($data(longlocalnameformfunctiontestd),0,$zpos)
	do ^examine($data(longlocalnameformfunctiontesta(1)),1,$zpos)
	do ^examine($data(longlocalnameformfunctiontestb(1)),0,$zpos)
	do ^examine($data(longlocalnameformfunctiontestc(1)),11,$zpos)
	do ^examine($data(longlocalnameformfunctiontestc("C")),10,$zpos)
get	; test $get
	write seperator,!
	write "Test $GET",!
	do ^examine($get(^longglobalnameformfunctiontesta),"a",$zpos)
	do ^examine($get(^longglobalnameformfunctiontestb),"b",$zpos)
	do ^examine($get(^longglobalnameformfunctiontestc),"",$zpos)
	do ^examine($get(^longglobalnameformfunctiontestd),"",$zpos)
	do ^examine($get(^longglobalnameformfunctiontesta(1)),"a1",$zpos)
	do ^examine($get(^longglobalnameformfunctiontestb(1)),"",$zpos)
	do ^examine($get(^longglobalnameformfunctiontestc(1)),"c1",$zpos)
	do ^examine($get(^longglobalnameformfunctiontestc("C")),"",$zpos)
	; locals
	do ^examine($get(longlocalnameformfunctiontesta),"a",$zpos)
	do ^examine($get(longlocalnameformfunctiontestb),"b",$zpos)
	do ^examine($get(longlocalnameformfunctiontestc),"",$zpos)
	do ^examine($get(longlocalnameformfunctiontestd),"",$zpos)
	do ^examine($get(longlocalnameformfunctiontesta(1)),"a1",$zpos)
	do ^examine($get(longlocalnameformfunctiontestb(1)),"",$zpos)
	do ^examine($get(longlocalnameformfunctiontestc(1)),"c1",$zpos)
	do ^examine($get(longlocalnameformfunctiontestc("C")),"",$zpos)
name	; test $name
	write seperator,!
	write "Test $NAME",!
	set x="A""B",y=1,z="somestr",^longglobalnamefornamefunctiontestsa(x,y,z)=5
	set x="A""B",y=1,z="somestr",^longglobalnamefornamefunctiontestsb(x,y,z,1,"abc",5)=5
	set x=$name(^(3)) write x,!
	write $qlength(x),!
	write $qsubscript(x,10),!
	write $qsubscript(x,5),!
	write $qsubscript(x,0),!
	write $name(^(3),1),!
	write $name(^(3),2),!
	write $name(^(3),5),!
order	; $order
	write seperator,!
	write "Test $ORDER",!
        set x="" for  s x=$order(^longglobalnameformfunctiontesta(x)) q:x=""  write x,!
        set x="" for  s x=$order(^longglobalnameformfunctiontestc(x)) q:x=""  write x,!
        set x="" for  s x=$order(longlocalnameformfunctiontesta(x)) q:x=""  write x,!
        set x="" for  s x=$order(longlocalnameformfunctiontestc(x)) q:x=""  write x,!
        set x="" for  s x=$order(longlocalnameformfunctiontestc("C",x)) q:x=""  write x,!
zprev	; $zprevious
	write seperator,!
	write "Test $ZPREVIOUS",!
        write "Output will be in the reverse order of $order() output",!
        set x="" for  s x=$zprevious(^longglobalnameformfunctiontesta(x)) q:x=""  write x,!
        set x="" for  s x=$zprevious(^longglobalnameformfunctiontestc(x)) q:x=""  write x,!
        set x="" for  s x=$zprevious(longlocalnameformfunctiontesta(x)) q:x=""  write x,!
        set x="" for  s x=$zprevious(longlocalnameformfunctiontestc(x)) q:x=""  write x,!
next	; $next
	write seperator,!
	write "Test $NEXT",!
        ;; $next() is obsolete in favor of $order()
        set x="" for  s x=$next(^longglobalnameformfunctiontesta(x)) q:x="-1"  write x,!
        set x="" for  s x=$next(^longglobalnameformfunctiontestc(x)) q:x="-1"  write x,!
        set x="" for  s x=$next(longlocalnameformfunctiontesta(x)) q:x="-1"  write x,!
        set x="" for  s x=$next(longlocalnameformfunctiontestc(x)) q:x="-1"  write x,!
query	; $query
	write seperator,!
	write "Test $QUERY",!
        set y="^longglobalnameformfunctiontesta" for  set y=$query(@y) quit:y=""  write y,"=",@y,!
        set y="^longglobalnameformfunctiontestc" for  set y=$query(@y) quit:y=""  write y,"=",@y,!
        set y="longlocalnameformfunctiontesta" for  set y=$query(@y) quit:y=""  write y,"=",@y,!
        set y="longlocalnameformfunctiontestc" for  set y=$query(@y) quit:y=""  write y,"=",@y,!
qleng	; $qlength
	write seperator,!
	write "Test $QLENGTH",!
	write $QLENGTH("a234567890123456789012345678901(""a1"",""b2"",3000,4444,""d5"")"),!
        write $QLENGTH("a234567890123456789012345678901(1,""b2"",3000,4444,""d5"")"),! 
        write $QLENGTH("a234567890123456789012345678901(1,22,333,4444,55,66,7)"),!
        write $QLENGTH("a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")"),!
	; from the manual
	write $data(^|"xxx"|ABC(1,2,3,4)),!
	s x=$name(^(5,6))
	write $qlength(x),!
qsubs	; $qsubscript
	write seperator,!
	write "Test $QSUBSCRIPT",!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",-1),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",0),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",1),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",2),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",3),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",4),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",5),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",6),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",7),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",8),!
	write $QSUBSCRIPT("^|""xxx.gld""|a234567890123456789012345678901(1,22,333,4444,55,66,7,""eight"")",9),!
	; from the manual, the x is from $qlength test earlier
	;write $qsubscript(x,-2),!
	write $qsubscript(x,-1),!
	write $qsubscript(x,0),!
	write $qsubscript(x,1),!
	write $qsubscript(x,2),!
	write $qsubscript(x,4),!
	write $qsubscript(x,7),!
stack	; $stack
	write seperator,!
	write "Test $STACK",!
	write $stack,!
	xecute "write $stack,!"
	do label1forstackwithlongnamedlabels
	write $$label1forstackwithlongnamedElabels,!
	write $stack,!
textforlongnamedentryandlabels	; $text
	write seperator,!
	write "Test $TEXT",!
	write $text(+0),!
	write $text(+1),!
	write $text(textforlongnamedentryandlabels),!
	write $text(textforlongnamedentryandlabels+4^functionwithlongnamedvariables),!
	set dollartextvariable=$ZPOSITION
	set dollartextdummyvar="dummy"
	write $text(@dollartextvariable),!
	quit
label1forstackwithlongnamedlabels	; label1 for $stack
	write "in label1forstackwithlongnamedlabels:  ",$stack,!
	do label1forstackwithlongnamedDlabels
	quit
label1forstackwithlongnamedDlabels	; Dlabel1 for $stack
	write "in label1forstackwithlongnamedDlabels: ",$stack,!
	quit
label1forstackwithlongnamedElabels()	; Elabel1 for $stack
	quit $stack
