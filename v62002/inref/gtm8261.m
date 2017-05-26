;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8261	; code grabbed from a randomly generated example that exposed an issue with a doubly linked list used in compiling Boolean expressions
	; only compiled by the test, although it could run; also an expression (Expr#99999) derived from a case caught by a VistA compile
	do init
	Write "Expr#250:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",(($Test&($ZAHandle(@iTRUE)]$ZAHandle(@iTRUE@(1)))!$Test)&^TRUE&($$RetNot(((((@iFALSE@($$Always1)[(1'>$Order(^TRUE(1),-1)))[$$RetNot($$Always0))>$$Always0)'>1))'[(0']]$$Always1))!$$RetNot(@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE))))),"/",$Reference
	If (($Test&($ZAHandle(@iTRUE)]$ZAHandle(@iTRUE@(1)))!$Test)&^TRUE&($$RetNot(((((@iFALSE@($$Always1)[(1'>$Order(^TRUE(1),-1)))[$$RetNot($$Always0))>$$Always0)'>1))'[(0']]$$Always1))!$$RetNot(@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE))))) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	ZGoto zl:Lbl250A:(($Test&($ZAHandle(@iTRUE)]$ZAHandle(@iTRUE@(1)))!$Test)&^TRUE&($$RetNot(((((@iFALSE@($$Always1)[(1'>$Order(^TRUE(1),-1)))[$$RetNot($$Always0))>$$Always0)'>1))'[(0']]$$Always1))!$$RetNot(@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE))))),zl:Lbl250B:('(($Test&($ZAHandle(@iTRUE)]$ZAHandle(@iTRUE@(1)))!$Test)&^TRUE&($$RetNot(((((@iFALSE@($$Always1)[(1'>$Order(^TRUE(1),-1)))[$$RetNot($$Always0))>$$Always0)'>1))'[(0']]$$Always1))!$$RetNot(@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE))))))
	Write "FAIL - neither condition tripped",!
	Goto Lbl250Done
Lbl250A Write 1
	Goto Lbl250Done
Lbl250B Write 0
Lbl250Done
	Write "/",$Reference
	Write:(($Test&($ZAHandle(@iTRUE)]$ZAHandle(@iTRUE@(1)))!$Test)&^TRUE&($$RetNot(((((@iFALSE@($$Always1)[(1'>$Order(^TRUE(1),-1)))[$$RetNot($$Always0))>$$Always0)'>1))'[(0']]$$Always1))!$$RetNot(@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE))))) ?72," CPC:1/",$Reference
	Write:('(($Test&($ZAHandle(@iTRUE)]$ZAHandle(@iTRUE@(1)))!$Test)&^TRUE&($$RetNot(((((@iFALSE@($$Always1)[(1'>$Order(^TRUE(1),-1)))[$$RetNot($$Always0))>$$Always0)'>1))'[(0']]$$Always1))!$$RetNot(@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE)))))) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#544:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",(($Test!(1']]($$RetNot($Test)<0))!$Test)&^FALSE(($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE)))),"/",$Reference
	If (($Test!(1']]($$RetNot($Test)<0))!$Test)&^FALSE(($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE)))) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	ZGoto zl:Lbl544A:(($Test!(1']]($$RetNot($Test)<0))!$Test)&^FALSE(($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE)))),zl:Lbl544B:('(($Test!(1']]($$RetNot($Test)<0))!$Test)&^FALSE(($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE)))))
	Write "FAIL - neither condition tripped",!
	Goto Lbl544Done
Lbl544A Write 1
	Goto Lbl544Done
Lbl544B Write 0
Lbl544Done
	Write "/",$Reference
	Write:(($Test!(1']]($$RetNot($Test)<0))!$Test)&^FALSE(($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE)))) ?72," CPC:1/",$Reference
	Write:('(($Test!(1']]($$RetNot($Test)<0))!$Test)&^FALSE(($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))))) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#611:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",((FALSE($Test)&@($Query(TRUE(-1)))!($Order(@iTRUE@(-1),1)']]$ZQGblmod(@^iFALSE)))&$$Always1&FALSE&1&@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE)))!1),"/",$Reference
	If ((FALSE($Test)&@($Query(TRUE(-1)))!($Order(@iTRUE@(-1),1)']]$ZQGblmod(@^iFALSE)))&$$Always1&FALSE&1&@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE)))!1) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	Goto Lbl611A:((FALSE($Test)&@($Query(TRUE(-1)))!($Order(@iTRUE@(-1),1)']]$ZQGblmod(@^iFALSE)))&$$Always1&FALSE&1&@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE)))!1),Lbl611B:('((FALSE($Test)&@($Query(TRUE(-1)))!($Order(@iTRUE@(-1),1)']]$ZQGblmod(@^iFALSE)))&$$Always1&FALSE&1&@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE)))!1))
	Write "FAIL - neither condition tripped",!
	Goto Lbl611Done
Lbl611A Write 1
	Goto Lbl611Done
Lbl611B Write 0
Lbl611Done
	Write "/",$Reference
	Write:((FALSE($Test)&@($Query(TRUE(-1)))!($Order(@iTRUE@(-1),1)']]$ZQGblmod(@^iFALSE)))&$$Always1&FALSE&1&@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE)))!1) ?72," CPC:1/",$Reference
	Write:('((FALSE($Test)&@($Query(TRUE(-1)))!($Order(@iTRUE@(-1),1)']]$ZQGblmod(@^iFALSE)))&$$Always1&FALSE&1&@^iTRUE@(($ZAHandle(FALSE)]$ZAHandle(TRUE)))!1)) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#692:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",((($ZAHandle(FALSE(0))]$ZAHandle(TRUE(1)))&$$Always1!($ZAHandle(FALSE)]$ZAHandle(TRUE))&^TRUE($$Always0)!((0<1)'=$Test)&1)),"/",$Reference
	If ((($ZAHandle(FALSE(0))]$ZAHandle(TRUE(1)))&$$Always1!($ZAHandle(FALSE)]$ZAHandle(TRUE))&^TRUE($$Always0)!((0<1)'=$Test)&1)) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	Goto Lbl692A:((($ZAHandle(FALSE(0))]$ZAHandle(TRUE(1)))&$$Always1!($ZAHandle(FALSE)]$ZAHandle(TRUE))&^TRUE($$Always0)!((0<1)'=$Test)&1)),Lbl692B:('((($ZAHandle(FALSE(0))]$ZAHandle(TRUE(1)))&$$Always1!($ZAHandle(FALSE)]$ZAHandle(TRUE))&^TRUE($$Always0)!((0<1)'=$Test)&1)))
	Write "FAIL - neither condition tripped",!
	Goto Lbl692Done
Lbl692A Write 1
	Goto Lbl692Done
Lbl692B Write 0
Lbl692Done
	Write "/",$Reference
	Write:((($ZAHandle(FALSE(0))]$ZAHandle(TRUE(1)))&$$Always1!($ZAHandle(FALSE)]$ZAHandle(TRUE))&^TRUE($$Always0)!((0<1)'=$Test)&1)) ?72," CPC:1/",$Reference
	Write:('((($ZAHandle(FALSE(0))]$ZAHandle(TRUE(1)))&$$Always1!($ZAHandle(FALSE)]$ZAHandle(TRUE))&^TRUE($$Always0)!((0<1)'=$Test)&1))) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#1063:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",(($$RetNot(0)&$Next(@iFALSE@(-1))&$$Always0)&@^iTRUE@($Get(@^bogus,1))!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))),"/",$Reference
	If (($$RetNot(0)&$Next(@iFALSE@(-1))&$$Always0)&@^iTRUE@($Get(@^bogus,1))!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	Do Write1:(($$RetNot(0)&$Next(@iFALSE@(-1))&$$Always0)&@^iTRUE@($Get(@^bogus,1))!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))),Write0:('(($$RetNot(0)&$Next(@iFALSE@(-1))&$$Always0)&@^iTRUE@($Get(@^bogus,1))!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))))
	Write "/",$Reference
	Write:(($$RetNot(0)&$Next(@iFALSE@(-1))&$$Always0)&@^iTRUE@($Get(@^bogus,1))!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))) ?72," CPC:1/",$Reference
	Write:('(($$RetNot(0)&$Next(@iFALSE@(-1))&$$Always0)&@^iTRUE@($Get(@^bogus,1))!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE)))) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#1064:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",((1!$Test!$ZQGblmod(^FALSE))!$$Always0!$$Always0!$Test&$Test),"/",$Reference
	If ((1!$Test!$ZQGblmod(^FALSE))!$$Always0!$$Always0!$Test&$Test) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	ZGoto zl:Lbl1064A:((1!$Test!$ZQGblmod(^FALSE))!$$Always0!$$Always0!$Test&$Test),zl:Lbl1064B:('((1!$Test!$ZQGblmod(^FALSE))!$$Always0!$$Always0!$Test&$Test))
	Write "FAIL - neither condition tripped",!
	Goto Lbl1064Done
Lbl1064A Write 1
	Goto Lbl1064Done
Lbl1064B Write 0
Lbl1064Done
	Write "/",$Reference
	Write:((1!$Test!$ZQGblmod(^FALSE))!$$Always0!$$Always0!$Test&$Test) ?72," CPC:1/",$Reference
	Write:('((1!$Test!$ZQGblmod(^FALSE))!$$Always0!$$Always0!$Test&$Test)) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#4495:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",(($Test&($$Always1'[$Test)!($Test'[@^iFALSE))!@iFALSE@($Test)!($ZAHandle(@iTRUE)]$ZAHandle(@iFALSE))),"/",$Reference
	If (($Test&($$Always1'[$Test)!($Test'[@^iFALSE))!@iFALSE@($Test)!($ZAHandle(@iTRUE)]$ZAHandle(@iFALSE))) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	ZGoto zl:Lbl4495A:(($Test&($$Always1'[$Test)!($Test'[@^iFALSE))!@iFALSE@($Test)!($ZAHandle(@iTRUE)]$ZAHandle(@iFALSE))),zl:Lbl4495B:('(($Test&($$Always1'[$Test)!($Test'[@^iFALSE))!@iFALSE@($Test)!($ZAHandle(@iTRUE)]$ZAHandle(@iFALSE))))
	Write "FAIL - neither condition tripped",!
	Goto Lbl4495Done
Lbl4495A Write 1
	Goto Lbl4495Done
Lbl4495B Write 0
Lbl4495Done
	Write "/",$Reference
	Write:(($Test&($$Always1'[$Test)!($Test'[@^iFALSE))!@iFALSE@($Test)!($ZAHandle(@iTRUE)]$ZAHandle(@iFALSE))) ?72," CPC:1/",$Reference
	Write:('(($Test&($$Always1'[$Test)!($Test'[@^iFALSE))!@iFALSE@($Test)!($ZAHandle(@iTRUE)]$ZAHandle(@iFALSE)))) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#4673:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",(($Test!(1'=($Test'=^TRUE))!$Test)!$Test!$$RetNot($Order(@^iTRUE@(2),-1))!(0'>0)&$$Always0!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))),"/",$Reference
	If (($Test!(1'=($Test'=^TRUE))!$Test)!$Test!$$RetNot($Order(@^iTRUE@(2),-1))!(0'>0)&$$Always0!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	Xecute "Do Write1":(($Test!(1'=($Test'=^TRUE))!$Test)!$Test!$$RetNot($Order(@^iTRUE@(2),-1))!(0'>0)&$$Always0!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))),"Do Write0":('(($Test!(1'=($Test'=^TRUE))!$Test)!$Test!$$RetNot($Order(@^iTRUE@(2),-1))!(0'>0)&$$Always0!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))))
	Write "/",$Reference
	Write:(($Test!(1'=($Test'=^TRUE))!$Test)!$Test!$$RetNot($Order(@^iTRUE@(2),-1))!(0'>0)&$$Always0!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE))) ?72," CPC:1/",$Reference
	Write:('(($Test!(1'=($Test'=^TRUE))!$Test)!$Test!$$RetNot($Order(@^iTRUE@(2),-1))!(0'>0)&$$Always0!($ZAHandle(@iFALSE)]$ZAHandle(@iTRUE)))) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#4674:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",(($$Always1&@^iFALSE&$$Always1&$Test)!$$Always0!0!$Test&$$Always1),"/",$Reference
	If (($$Always1&@^iFALSE&$$Always1&$Test)!$$Always0!0!$Test&$$Always1) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	Goto Lbl4674A:(($$Always1&@^iFALSE&$$Always1&$Test)!$$Always0!0!$Test&$$Always1),Lbl4674B:('(($$Always1&@^iFALSE&$$Always1&$Test)!$$Always0!0!$Test&$$Always1))
	Write "FAIL - neither condition tripped",!
	Goto Lbl4674Done
Lbl4674A Write 1
	Goto Lbl4674Done
Lbl4674B Write 0
Lbl4674Done
	Write "/",$Reference
	Write:(($$Always1&@^iFALSE&$$Always1&$Test)!$$Always0!0!$Test&$$Always1) ?72," CPC:1/",$Reference
	Write:('(($$Always1&@^iFALSE&$$Always1&$Test)!$$Always0!0!$Test&$$Always1)) ?72," CPC:0/",$Reference
	Write !

	Write "Expr#99999:"
	If nextt                     ; Set $TEST to next progressive value
	Set t=$TEST                  ; Save so usage in each expression usage is repeatable
	Write ?12," Exp:",$Data(TRUE)&($Select($Data(FALSE)#2:'$Data(@iFALSE@("R")),1:1)),"/",$Reference
	if ($Data(TRUE)&($Select($Data(FALSE)#2:'$Data(@iFALSE@("R")),1:1))) Write ?32," If:1/",$Reference
	Else  Write ?32," If:0/",$Reference
	Set nextt=$TEST              ; Save for restore next test so don't have same $TEST for all exprs
	If t                         ; Restore initial $TEST value
	Write ?52," APC:"
	ZGoto zl:Lbl99999A:($Data(TRUE)&($Select($Data(FALSE)#2:'$Data(@iFALSE@("R")),1:1))),zl:Lbl99999B:('($Data(TRUE)&($Select($Data(FALSE)#2:'$Data(@iFALSE@("R")),1:1))))
	Write "FAIL - neither condition tripped",!
	Goto Lbl99999Done
Lbl99999A Write 1
	Goto Lbl99999Done
Lbl99999B Write 0
Lbl99999Done
	Write "/",$Reference
	Write:($Data(TRUE)&($Select($Data(FALSE)#2:'$Data(@iFALSE@("R")),1:1))) ?72," CPC:1/",$Reference
	Write:('($Data(TRUE)&($Select($Data(FALSE)#2:'$Data(@iFALSE@("R")),1:1)))) ?72," CPC:0/",$Reference
	Write !
	quit

init	Set $ETrap="Set $ETrap="""" Write $ZStatus,! ZShow ""*"" ZHalt 1"
	Set iTRUE="TRUE",TRUE=1,TRUE(-1)=1,TRUE(0)=1,TRUE(1)=1,TRUE(2)=1
	Set ^iTRUE="^TRUE",^TRUE=1,^TRUE(-1)=1,^TRUE(0)=1,^TRUE(1)=1,^TRUE(2)=1
	Set iFALSE="FALSE",FALSE=0,FALSE(-1)=0,FALSE(0)=0,FALSE(1)=0,FALSE(2)=0
	Set ^iFALSE="^FALSE",^FALSE=0,^FALSE(-1)=0,^FALSE(0)=0,^FALSE(1)=0,^FALSE(2)=0
	Set bogus="unknwn",^bogus="^unknwn",^dummy=0
	Set incrvar=0,indincrvar="incrvar",zl=$ZLevel-1
	Set nextt=1    ; Preload for $TEST with either 0 or 1 generated randomly
	quit

Always0()
	Quit 0
Always1()
	Quit 1
RetSame(x)
	Quit x
RetNot(x)
	Quit '(x)
Write0	Write 0
	Quit
Write1	Write 1
	Quit
