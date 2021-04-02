;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test case for GTM-9181 with various literal boolean expressions evaluated by the compiler cause ASSERT and/or
; GTMASSERT2 errors in versions prior to V63010.
gtm9181
	set null="",error=0
	set false=0,true=1
	set X="x"
	; This first test case came from YDB#502. Do this one manually as it does not fit neatly into the method
	; used below for the other tests since it has a quit at the end.
	write !,"***************************************************************************************",!
	do
	. set stmt="do Foo(""""_X):0 quit"
	. write "Test 1: do Foo(""""_X):0 quit",!
	. do Foo(""_X):0 quit
	; this line has to be here in order to reproduce this issue, even if was empty
	;
	; Create two arrays - one is an array of statements to test and the second is an indicator of whether we
	; should check the resulting value or not. Some statements we're just checking that they are able to compile
	; while others, we also need to get a specific value out of.
	;
	; The following two cases came from YDB#546. V63010 fixed both cases specified in the original issue but
	; a later comment by @nars1 showed an additional half-dozen or so cases that failed using a tool he wrote
	; called "bintest.m" (see YDB#546). These additional cases still fail even with V63010 so not include here.
	set tcnt=1
	set stmt($incr(tcnt))="if (0'&($select((false?1A):0,(0'?1A):(false!0),$select(false:0,false:1,false:1,1:1):1)))"
	set chkrslt(tcnt)=false		; #2
	set stmt($incr(tcnt))="if (null!($select(false:(1&0),false:($select(false:false,1:false)),1:1)))"
	set chkrslt(tcnt)=false		; #3
	; The following test cases came from a modified version of the bintest.m routine noted in YDB#546. The modification was to generate
	; only expressions that results in setting the result field to '1'. These test cases failed in V63009 and earlier but succeed in V63010
	; and later
	set stmt($incr(tcnt))="set:(((false'=0)'!'$test)&($select((true[('true)):(true'[true),('$test!('false)):($select(('true):'$test,$test:('false)))))) result=1"
	set chkrslt(tcnt)=true		; #4
	set stmt($incr(tcnt))="set:(((true'&'$test)?1""0"")[($select((1<'$test):(false>=('false)),('true):(('false)?1""0""),('$test!false):($select(('false):('true),false:true,true:('true),1:('true))),(('false)]false):(false=1)))) result=1"
	set chkrslt(tcnt)=true		; #5
	set stmt($incr(tcnt))="set:(((true!'$test)'?1""1"")'&($select(($test&'$test):'$test,($select(('false):0,false:true,('false):0)):('false),(0']]$test):false))) result=1"
	set chkrslt(tcnt)=true		; #6
	set stmt($incr(tcnt))="set:((('true)'=('true))'!($select(('$test'&('false)):('true),($select($test:'$test)):0,(0<$test):('true)))) result=1"
	set chkrslt(tcnt)=true		; #7
	set stmt($incr(tcnt))="set:((('$test'&$test)]]0)=($select(false:(1'!('true)),0:(0&true),$test:($select(('false):true))))) result=1"
	set chkrslt(tcnt)=true		; #8
	set stmt($incr(tcnt))="set:(((true'!('true))'!('true))>($select(('true):(('false)&false),true:($select(false:0,0:('true),1:0))))) result=1"
	set chkrslt(tcnt)=true		; #9
	set stmt($incr(tcnt))="set:('$test!($select(false:($test'?1""1""),false:(0'!false),1:($select($test:$test,1:$test,$test:$test))))) result=1"
	set chkrslt(tcnt)=true		; #10
	; Drive these tests making sure to set $TEST to 1 before each subtest
	for i=2:1:tcnt do
	. write "***************************************************************************************",!
	. write "Test ",i,": ",stmt(i),!
	. set result=0
	. if 1			; Initialize $TEST to 1 to start with a known value
	. xecute stmt(i)
	. write:(chkrslt(i)&(1'=result)) "Test failed - result not 1 as expected (",result,")",!

	write !,"All tests complete",!
	quit

Foo(z)
	write "Should not be here in Foo",!
	quit
