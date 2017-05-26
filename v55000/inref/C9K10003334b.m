;
; C9K10-003334 test 2
;
; Drive a job interrupt while in an external routine with the job
; interrupt handler pointing to a local routine in the main. This causes
; an error and our purpose is to make sure the error is properly handled.
;
	Set SeenInt=0
	Set $ZInterrupt="Do JobintHandler^"_$Text(+0)
	Set $ETrap="Goto EtrapHandler^"_$Text(+0)
	Do ^C9K10003334c
	Write:SeenInt "Pass",!
	Write:'SeenInt "Fail: Interrupt was not seen",!
	Quit

JobintHandler
	Write "In jobint handler",!
	Set SeenInt=1
	Set x=1/0
	Quit

EtrapHandler
	;Set $ETrap=""
	Write "Error received: ",$ZStatus,!
	Quit
