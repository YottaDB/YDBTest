TPKILLG	; ; ; test deletions from the middle of a chain in new index blocks
	;
; Create a index block with several chain recs, then delete some 
; records from the middle of the block.  Tests that elements 
; are properly removed from the middle of the chain.
; 
; Deletion of this single key causes the compression count to 
; change on the following key.  This test also verifies 
; the code to adjust the chain record offsets to account
; for a change in compression count.
; this has worked all along
;
;             xxxxxx
;   ------------------------------------------------------
;   | |      |      |      |      |      |      |        |
;   | |      |      |      |      |      |      |        |
;   |b| ^A(1)| ^A(1,| ^A(1,| ^A(1,| ^A(2,| *-key|        |
;   |h|      |    1)|    1,|    1,|    1)|      |        |
;   | |      |      |    1)|    1,|      |      |        |
;   | |      |      |      |    1)|      |      |        |
;   | |      |      |      |      |      |      |        |
;   | |      |      |      |      |      |      |        |
;   | |      |      |      |      |      |      |        |
;   ------------------------------------------------------
;         ^ |    ^ |    ^ |    ^ |    ^ |    ^
;         | |    | |    | |    | |    | |    |
; ----------------------- ------ ------ ------
;

	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	tstart ():serial
	s ^A(1)="A(1) "_X1900
	s ^A(1,1)="A(1,1) "_X1900
	s ^A(1,1,1)="A(1,1,1) "_X1900
	s ^A(1,1,1,1)="A(1,1,1,1) "_X1900
	s ^A(2)="A(2) "_X1900
	s ^A(2,1)="A(2,1) "_X1900
	s ^A(2,1,1)="A(2,1) "_X1900
	zwithdraw ^A(1,1)
	i '$trestart trestart
	tcommit
	i $D(^A(1,1))=1 w "^A(1,1) exists",! s cnt=cnt+1 x act
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
