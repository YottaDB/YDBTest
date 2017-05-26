; GVPUTFAIL regression test  7/9/93
;
; Requirements:
; These tests (putfail1 - putfail8) require the block size to be 2048 and the
; record size must be at least 1900.
;
; This test creates a block which is nearly half full, then attempts
; to add a large record which would cause a block split.
;
;    -------------------------+------------------------
;    | |      |      |  |xxxxxxxxxxxxxxxxxxxxxxxxxxxxx|
;    |B|  R0  |  R1  |R2|xxxxxxxxxxxxxxxxxxxxxxxxxxxxx|
;    |H|      |      |  |xxxxxxxxxxxxxxxxxxxxxxxxxxxxx|
;    | |      |      |  |xxxxxxxxxxxxxxxxxxxxxxxxxxxxx|
;    -------------------------+------------------------
;                       ^
;                       |
;      ----------------------------------------
;      |                                      |
;      |          New record                  |
;      |                                      |
;      |                                      |
;      ----------------------------------------
;
; A bug in gvcst_put() caused it to attempt to split the block and place
; the new record in the new left block instead of the empty right block.
;
; A fix was made to gvcst_put.c on 7/6/93.
;
putfail1
	New (errcnt)
	New $ZTRAP

	Set $ZTRAP="Do err  Quit"
	Set PASS=1
	Kill ^PF
	Set X="1234567890"
	Set X100=X_X_X_X_X_X_X_X_X_X
	Set X300=X100_X100_X100
	Set X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	Set ^PF("A10")="X10"_X300
	Set ^PF("A20")="X20"_X300
	Set ^PF("A30")="X30"_X100

; This line used to cause a GVPUTFAIL, failure code HHHH
	Set ^PF("A40")="X40"_X1000_X300_X100

	If ^PF("A10")'=("X10"_X300) Set PASS=0 Write "^PF(""A10"") not stored properly",!
	If ^PF("A20")'=("X20"_X300) Set PASS=0 Write "^PF(""A20"") not stored properly",!
	If ^PF("A30")'=("X30"_X100) Set PASS=0 Write "^PF(""A30"") not stored properly",!
	If ^PF("A40")'=("X40"_X1000_X300_X100) Set PASS=0 Write "^PF(""A40"") not stored properly",!
	If PASS Write "   PASS - putfail1",!
	Else  Write "** FAIL - putfail1",!  Set errcnt=errcnt+1
	Quit

err
	Set $ZTRAP="Break"
	Write "** FAIL - putfail1",!
	Write $PIECE($ZSTATUS,",",3),",",$PIECE($ZSTATUS,",",4),!
	Write $CHAR(9),$CHAR(9),"At MUMPS source location ",$PIECE($ZSTATUS,",",2),!
	Set errcnt=errcnt+1
	Quit
