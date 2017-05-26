; GVPUTFAIL regression test
;
; Requirements:
; This test requires the block size to be 2048, record size 1900, and
; reserved bytes set at 128
;
; This test creates a block which is nearly full, then attempts
; to add a record which should cause a block split.
;
; sizeof(r1) + sizeof(r2) + sizeof(bh) <= block size
;
; sizeof(r1) + sizeof(r2) + sizeof(bh) > block size - reserved bytes
;
;	-----------------------------------
;	| |				|x|
;	|B|				|x|
;	|H|		r1		|x|
;	| |				|x|
;	| |				|x|
;	-----------------------------------
;         ^
;         |
;
;        ----
;        |  |
;        |  |           
;        |r2| new record
;        |  |
;        |  |
;        ----
;
	New $ZTRAP
;
	Set $ZTRAP="Do err  Quit"
putfail9
	New (errcnt)

	Set PASS=1
	Kill ^PF
	Set X="1234567890"
	Set X100=X_X_X_X_X_X_X_X_X_X
	Set X800=X100_X100_X100_X100_X100_X100_X100_X100
	Set X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	Set ^PF("A10")="X10"_X1000_X800_X_X_X_X_X_X_X_X
; This line used to cause a GVPUTFAIL, failure code HHHH
	Set ^PF("A05")="X05"_X_X_X_X_X_X_X_X

	If ^PF("A10")'=("X10"_X1000_X800_X_X_X_X_X_X_X_X) Set PASS=0 Write "^PF(""A10"") not stored properly",!
	If ^PF("A05")'=("X05"_X_X_X_X_X_X_X_X) Set PASS=0 Write "^PF(""A05"") not stored properly",!
	If PASS Write "   PASS - putfail9",!
	Else  Write "** FAIL - putfail9",!  Set errcnt=errcnt+1
	Quit

err
	Set $ZTRAP="Break"
	Write "** FAIL - putfail9",!
	Write $PIECE($ZSTATUS,",",3),",",$PIECE($ZSTATUS,",",4),!
	Write $CHAR(9),$CHAR(9),"At MUMPS source location ",$PIECE($ZSTATUS,",",2),!
	Set errcnt=errcnt+1
	Quit
