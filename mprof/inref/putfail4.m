; GVPUTFAIL regression test	7/9/93
;
; Requirements:
; These tests (putfail1 - putfail8) require the block size to be 2048 and the
; record size must be at least 1900.
;
; This test creates a nearly full block, then attempts to insert a large 
; record.  This should cause a three way block split (B0 containing
; R0-R3, B1 containing the new record, and B2 containing R4-R5).
;
;    -------------------------+------------------------
;    | |      |      |      |      |      |      |xxxx|
;    |B|  R0  |  R1  |  R2  |  R3  |  R4  |  R5  |xxxx|
;    |H|      |      |      |      |      |      |xxxx|
;    | |      |      |      |      |      |      |xxxx|
;    -------------------------+------------------------
;      ^
;      |
;      ----------------------------------------
;      |                                      |
;      |          New record                  |
;      |                                      |
;      |                                      |
;      ----------------------------------------
;
; The test verifys a change made to gvcst_put() to allow it to handle
; this kind of block split.
;
; A fix was made to gvcst_put.c on 7/6/93.
;
putfail4
	New (errcnt)
	New $ZTRAP

	Set $ZTRAP="Do err  Quit"
	Kill ^PF
	Set X="1234567890"
	Set X100=X_X_X_X_X_X_X_X_X_X
	Set X300=X100_X100_X100
	Set X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	Set ^PF("A10")="X10"_X300
	Set ^PF("A20")="X20"_X300
	Set ^PF("A30")="X30"_X300
	Set ^PF("A40")="X40"_X300
	Set ^PF("A50")="X50"_X300
	Set ^PF("A60")="X60"_X300

	Set ^PF("A15")="X15"_X1000_X300_X300

	Set PASS=1
	For i=10:10:60 If ^PF("A"_i)'=("X"_i_X300) Set PASS=0 Write "^PF(""A"_i_""") not stored properly",!
	If ^PF("A15")'=("X15"_X1000_X300_X300) Set PASS=0 Write "^PF(""A15"") not stored properly",!
	If PASS Write "   PASS - putfail4",!
	Else  Write "** FAIL - putfail4",!  Set errcnt=errcnt+1
	Quit

err
	Set $ZTRAP="Break"
	Write "** FAIL - putfail4",!
	Write $PIECE($ZSTATUS,",",3),",",$PIECE($ZSTATUS,",",4),!
	Write $CHAR(9),$CHAR(9),"At MUMPS source location ",$PIECE($ZSTATUS,",",2),!
	Set errcnt=errcnt+1
	Quit
