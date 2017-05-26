;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Nested calls : M1 -> C -> M2,          ;
;  with $ET not explicitly set in M1 & M2 ;
;                                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        Write "Nested calls: M1->C->M2",!!
	W "M1:  $ZLEVEL = ",$ZLEVEL,!
	W "M1:  $STACK = ",$STACK,!
	W "M1:  $ESTACK = ",$ESTACK,!
	Write "Passing:",!

	Set afltp=123.349
	Write "    ",afltp,!

	Set adblp=654.321
	Write "    ",adblp,!

	Set achrp="c"
	Write "    """,achrp,"""",!

	Set achrpp="C-style string"
	Write "    """,achrpp,"""",!

	Set astrngp="String structure"
	Write "    """,astrngp,"""",!

	Write "to inmult",!!
	Do &inmult(afltp,adblp,achrp,achrpp,astrngp)

	Write !,"Values returned from inmult:",!!
	Write "    ",afltp,!
	Write "    ",adblp,!
	Write "    """,achrp,"""",!
	Write "    """,achrpp,"""",!
	Write "    """,astrngp,"""",!

	W !,"Value of $ET in M1: ",$ET
	Quit
error
	W !,"Error - $ET value is changed in M1"
	Quit
