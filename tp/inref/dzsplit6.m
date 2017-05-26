DZSPLIT6 ; ; ; test for assertfail in gvcst_put
	;
; requires a database with a block size of 2048
; Append records to an existing zero-level directory block 
; until it splits.  Force an adjustment to the old block due
; to a compression count change from the insertion.
; in V3.1-6 this assert failed in gvcst_put
dzsplit6:
	n (act)
	i '$d(act) n act s act="w var,"" = "",@var,!"
	s cnt=0
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s zeros="0000000"
	f i=1:1:199 Do
	. s var="^A"_$E(zeros,$L(i),6)_i
	. s @var="A"_i_" "_X
	h 1
	ts
	s ^B=1
	s ^A0000200="A200 "_X
	s ^A0000201="A201 "_X
	tc
	f i=1:1:201 Do
	. s var="^A"_$E(zeros,$L(i),6)_i
	. s cmp="A"_i_" "_X
	. i @var'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
