incrgv1	;
	do ^job("child^incrgv1",10,"""""")
	quit

child	;
	; view "NOUNDEF"	; commented since $I() unconditionally assumes NOUNDEF (C9F03-002703)
	set begtime=$horolog,delta=0
	; after every KILL record the value of ^x starts from 1 and increases by 1 until next KILL
	for i=1:1 quit:delta>6  do
	.	set x=$incr(^xglobalnamechangedto31character)
	.	if $r(2)=1  kill ^xglobalnamechangedto31character
	.	if i#100=0 set curtime=$horolog,delta=$$^difftime(curtime,begtime)
	quit
