; write an existing block in two separate transactions 
; This program tests a transaction utilizing a clue provided
; by a prior transaction.  With GT.M V3.2-FT11 it failed
; with TP Commit Failure and was reported as an infinite
; retry problem by SCA when they allowed retries.
;
; The problem that occurred was that the concurrency check
; failed on the block that was searched using the clue.  Since
; utilizing a clue does not involve a t_qread, the transaction
; number for the block, as recorded in the history, was never
; changed (i.e. the history is out of date).  The solution is 
; to update the history tn in the gv_target histories in tp_tend().
; This was already done correctly in t_end().
TPCLUE1
	n (act)
	i '$d(act) n act s act="w var,"" = "",$g(@var(sub),""**UNDEF**""),!"
	v "gdscert":1
	s cnt=0
	s ^A(0)=0
	ts
	s ^A(1)=1
	tc
	ts
	s ^A(2)=2
	tc
	f var="^A" f sub=0:1:2 Do
	. s cmp=sub
	. i @var@(sub)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
