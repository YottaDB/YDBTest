; DZSPLIT3 - requires a database with a block size of 1024
; Create a zero-level directory block under TP and continue
; adding records to the beginning of the block until it 
; splits.
; in v3.1-6 this assert failed in tp_get_cw
dzsplit3:
	n (act)
	i '$d(act) n act s act="w var,"" = "",@var,!"
	s cnt=0
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s zeros="0000000"
	ts
	if $TRESTART>0 w "$TRESTART=",$TRESTART,!
	f i=100:-1:1 Do
	. s var="^A"_$E(zeros,$L(i),6)_i
	. s @var="A"_i_" "_X
	tc
	f i=1:1:100 Do
	. s var="^A"_$E(zeros,$L(i),6)_i
	. s cmp="A"_i_" "_X
	. i @var'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
