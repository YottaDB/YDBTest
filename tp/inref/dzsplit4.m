DZSPLIT4 ; ; ; test for GETFAIL IIII
	;
; requires a database with a block size of 2048
; Split a zero-level directory block with the new data going
; into the pre-existing (right-hand) block.  There is one
; TP record immediately before the split and immediately
; afterwards.
; in V3.1-6 this GETFAILed with IIII
	n (act)
	i '$d(act) n act s act="w var,"" = "",@var,!"
	s cnt=0
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s zeros="0000000"
	s top=202
	f i=top:-1:4 Do
	. s var="^A"_$E(zeros,$L(i),6)_i
	. s @var="A"_i_" "_X
	s ^A0000002="A2 "_X
	ts
	s ^A0000003="A3 "_X
	s ^A0000001="A1 "_X
	tc
	f i=1:1:top Do
	. s var="^A"_$E(zeros,$L(i),6)_i
	. s cmp="A"_i_" "_X 
	. i @var'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
