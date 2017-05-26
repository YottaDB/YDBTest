;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  External call: M -> C                  ;
;  C program must not successfully invoke ;
;  gtm_exit if M is the base caller.      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	Quit
