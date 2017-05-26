IXUPD1	; ; ; Update an index-level block
	;
;
; This test requires a block size of 2048 and a record size of at least 2000.
;
;   Under TP, add new records to an index block, then delete a record.
;   This originally caused database corruption in V3.2-FT10 where the 
;   second chain record was never updated with an actual block number
;   prior to being committed to a database.
;
;				   before
;            -------------------------------------------------
;            | |     |     |     |     |     |               |
;            | |     |     |     |     |     |               |
;            |b|^B(1)|^B(2)|^B(3)|^B(4)|*-key|               |
;            |h|     |     |     |     |     |               |
;            | |     |     |     |     |     |               |
;            | |     |     |     |     |     |               |
;            | |     |     |     |     |     |               |
;            | |     |     |     |     |     |               |
;            | |     |     |     |     |     |               |
;            -------------------------------------------------
;
;			           during
;            -------------------------------------------------
;            | |     |     |     |     |     |     |     |   |
;            | |     |     |     |     |     |     |     |   |
;            |b|^B(1)|^B(2)|^B(3)|^B(4)|^B(4 |^B(4 |*-key|   |
;            |h|     |     |     |     |   . |   . |     |   |
;            | |     |     |     |     |   5)|   8)|     |   |
;            | |     |     |     |     |     |     |     |   |
;            | |     |     |     |     |     |     |     |   |
;            | |     |     |     |     |     |     |     |   |
;            | |     |     |     |     |     |     |     |   |
;            -------------------------------------------------
;				   ^  |  ^    xxxxx
;  tp_chain------------------------|  ---|      ^-----to be deleted
;
;
;				   after
;            -------------------------------------------------
;            | |     |     |     |     |     |     |         |
;            | |     |     |     |     |     |     |         |
;            |b|^B(1)|^B(2)|^B(3)|^B(4)|^B(4 |*-key|         |
;            |h|     |     |     |     |   . |     |         |
;            | |     |     |     |     |   5)|     |         |
;            | |     |     |     |     |     |     |         |
;            | |     |     |     |     |     |     |         |
;            | |     |     |     |     |     |     |         |
;            | |     |     |     |     |     |     |         |
;            -------------------------------------------------
;

	n (act)
	i '$d(act) n act s act="w ""^B("",i,"") = "",$g(^B(i),""**UNDEF**""),!"
	s cnt=0
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	f i=1:1:5  s ^B(i)="B"_i_" "_X1900
	view "GDSCERT":1
	ts ():serial
	s ^B(4.5)="B4.5 "_X1900
	s ^B(4.8)="B4.8 "_X1900
	k ^B(4.8)
	tc
	f i=1:1:5,4.5 d
	. s cmp="B"_i_" "_X1900
	. i ^B(i)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
