TPKILLB	; ; ; Test for GETFAIL IIII
	;
; Create a index block with several chain recs, then delete the right
; side of the block.  The new last record should become a *-key.
; Test that the chain is properly truncated.
; 
; This case differs from tpkilla in that there is only one chain
; record prior to the deleted area, so cse->first_off gets
; adjusted instead of the prior chain record.
; in v3.1=6 this got a GVGETFAIL IIII
;
;		     xxxxxxxxxxxxx
;   ----------------------------------------
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   |b| ^A(1)| ^A(1,| ^A(1,| *-key|        |
;   |h|      |    1)|    1,|      |        |
;   | |      |      |    1)|      |        |
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   ----------------------------------------
;                ^ |           ^
;                | |           |
; ---------------- -------------
;

	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s ^A(1)="A(1) "_X1900
	s ^A(1,1,1)="A(1,1,1) "_X1900
	tstart ():serial
	s ^A(1,1)="A(1,1) "_X1900
	s ^A(1,1,1,1)="A(1,1,1,1) "_X1900
	k ^A(1,1,1)
	i '$trestart trestart
	tcommit
	i $D(^A(1,1,1))=1 w "^A(1,1,1) exists",! s cnt=cnt+1 x act
	i $D(^A(1,1,1,1))=1 w "^A(1,1,1,1) exists",! s cnt=cnt+1 x act
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q

