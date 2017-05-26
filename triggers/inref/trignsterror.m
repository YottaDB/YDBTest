;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Nested calls : M1 -> C -> M2,          ;
;  with $ET not explicitly set in M1 & M2 ;
;                                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trignsterror
	if $data(^b) do
	. write "We shouldn't get here because it would have to be via the call in from C"
	. halt
	set ^b=1
	write "Nested calls: M1->C->M2",!!
	write "M1:  $ZLEVEL = ",$ZLEVEL,!
	write "M1:  $STACK = ",$STACK,!
	write "M1:  $ESTACK = ",$ESTACK,!
	write "Passing:",!

	set afltp=123.349
	write "    ",afltp,!

	set adblp=654.321
	write "    ",adblp,!

	set achrp="c"
	write "    """,achrp,"""",!

	set achrpp="C-style string"
	write "    """,achrpp,"""",!

	set astrngp="String structure"
	write "    """,astrngp,"""",!

	write "to inmult",!!
	do &inmult(afltp,adblp,achrp,achrpp,astrngp)

	write !,"Values returned from inmult:",!!
	write "    ",afltp,!
	write "    ",adblp,!
	write "    """,achrp,"""",!
	write "    """,achrpp,"""",!
	write "    """,astrngp,"""",!

	write !,"Value of $ET in M1: ",$ET
	quit
error
	write !,"Error - $ET value is changed in M1"
	quit
