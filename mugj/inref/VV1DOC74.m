VV1DOC74	;VV1DOC V.7.1 -74-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;IO control ( OPEN, USE, $X, $Y, $IO, $JOB )
	;     (V1IO)
	;
	;     (V1IO is overlaid with V1IO1 and V1IO2.)
	;
	;     I-532. OPEN command syntax
	;     I-535. operation of OPEN command
	;       I-532/535  OPEN command syntax and operation
	;     I-533. USE command syntax
	;     I-536. operation of USE command
	;       I-533/536  USE command syntax and operation
	;     I-534. CLOSE command syntax
	;     I-537. operation of CLOSE command
	;       I-534/537  CLOSE command syntax and operation
	;     I-538. postconditional of OPEN command
	;     I-539. postconditional of USE command
	;     I-540. postconditional of CLOSE command
	;     I-541. timeout of OPEN command
	;     I-542. effect on $X by output of graphics
	;     I-543. effect on $Y by output of graphics
	;     I-544. effect on $X by output of format parameter
	;     I-545. effect on $Y by output of format parameter
	;     I-546. $X in executing USE command
	;     I-547. $Y in executing USE command
	;     I-548. $IO and OPEN command
	;     I-549. $IO and USE command
	;     I-550. $IO and CLOSE command
	;     I-551. $JOB and OPEN command
	;     I-552. $JOB and USE command
	;     I-553. $JOB and CLOSE command
	;     I-554. $JOB and current IO device
	;
	;
	;Multi job ( LOCK, OPEN, CLOSE, $JOB, $IO, $TEST ) -1-
	;     (V1MJA)
	;
	;     I-628. LOCK the same name in two partitions
	;     I-629. update or refer the variable which is LOCKed in another partition
	;     I-630. LOCK with timeout and its effect on $TEST
	;     I-631. postconditional of LOCK command
	;     I-632. LOCK more than one name at the same time
	;     I-633. effect of unLOCK on another partition
	;     I-634. argument list of LOCK
	;     I-635. indirection of LOCK argument
	;     I-636. effect of LOCK on naked indicator
