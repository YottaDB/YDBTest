IXSPLIT3 ; ; ; test for GETFAIL IIII
	;
; Split an index-level block
;
;   Under TP, add new records to the end of an existing index block until it
;   splits, leaving one of the new records as the new *-key in the left
;   block and the others as new records in the right block.
;
;   The failure that occurred when this test was run with GT.M V3.2-FT10
;   was that the chain record for the *-key in the left block was not
;   updated correctly.  This caused the following error message:
;
;	%GTM-E-GVGETFAIL, Global variable retrieval failed. Failure code: IIII
;	%GTM-I-GVIS,            Global variable : ^A(183)
;	                At M source location +56^ixsplit3
;
;				      before
;                     ----------------   ------------------
;                     | |     |     |     |       |     | |
;                     | |     |     |     |       |     | |
;                     |b|^A(1)|^A(2)| ... |^A(181)|*-key| |
;                     |h|     |     |     |       |     | |
;                     | |     |     |     |       |     | |
;                     | |     |     |     |       |     | |
;                     | |     |     |     |       |     | |
;                     | |     |     |     |       |     | |
;                     | |     |     |     |       |     | |
;                     ----------------   ------------------
;
;
;				      after
;			       xxxxx           xxxxxx  xxxxx
; ----------------   ------------------     --------------------------------
; | |     |     |     |       |     | |     | |       |     |              |
; | |     |     |     |       |     | |     | |       |     |              |
; |b|^A(1)|^A(2)| ... |^A(182)|*-key| |     |b|^A(184)|*-key|              |
; |h|     |     |     |       |     | |     |h|       |     |              |
; | |     |     |     |       |     | |     | |       |     |              |
; | |     |     |     |       |     | |     | |       |     |              |
; | |     |     |     |       |     | |     | |       |     |              |
; | |     |     |     |       |     | |     | |       |     |              |
; | |     |     |     |       |     | |     | |       |     |              |
; ----------------   ------------------     --------------------------------
;			 |  |   ^	        ^  
;  TP chain---------------  ----|     TP chain'-|  
;
	n (act)
	i '$d(act) n act s act="w ""^A("",i,"") = "",^A(i),!"
	s cnt=0
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	view "GDSCERT":1
	f i=1:1:182 s ^A(i)="A"_i_" "_X1900
	ts ():serial
	f i=i+1:1:185 s ^A(i)="A"_i_" "_X1900
	tc
	f i=1:1:185 d
	. s cmp="A"_i_" "_X1900 
	. i ^A(i)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
