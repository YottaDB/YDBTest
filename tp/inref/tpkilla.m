TPKILLA	; ; ;test for GETFAIL IIII
	;
; Create a index block with several chains, then delete the right
; side of the block.  The new last record should become a *-key.
; Test that the chain is properly truncated.
; in v3.1=6 this got a GVGETFAIL IIII
; 
;			    xxxxxx
;   ----------------------------------------
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   |b| ^A(1)| ^A(2)| ^A(3)| *-key|        |
;   |h|      |      |      |      |        |
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   | |      |      |      |      |        |
;   ----------------------------------------
;         ^ |    ^ |    ^ |    ^
;         | |    | |    | |    |
; --------- ------ ------ ------
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
	f i=1:1:4 s ^A(i)="A"_i_" "_X1900
	k ^A(4)
	i '$trestart trestart
	tcommit
	f i=1:1:3 s cmp="A"_i_" "_X1900 i ^A(i)'=cmp s cnt=cnt+1 x act
	i $D(^A(4))=1 w "FAILED:  ^A(4) not deleted",! s cnt=cnt+1 x act
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
