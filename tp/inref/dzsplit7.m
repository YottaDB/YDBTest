DZSPLIT7 ; ; ; test for spurious UNDEF
	;
; requires a database with a block size of 2048
; split a zero-level directory block containing several
; records generated within a transaction.
; in V3.1-6 this gave a spurious undefined error
dzsplit7:
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
	. s var="^B"_$E(zeros,$L(i),6)_i
	. s @var="B"_i_" "_X
	ts
	s ^A0000321="A321 "_X
	s ^A000021="A21 "_X
	s ^A00001="A1 "_X
	tc
	f i=4:1:top Do
	. s var="^B"_$E(zeros,$L(i),6)_i
	. s cmp="B"_i_" "_X 
	. i @var'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
