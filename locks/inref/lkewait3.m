lkewait3; third process to lock on ^a,^b,^c (^a owned by parenti, ^b by 2nd job)
	SET $ZT="s $ZT="""" g ERROR"
	new unix,i
        s unix=$zv'["VMS"
        if unix set ^pid3=$JOB
        else  set ^pid3=$$FUNC^%DH($JOB,0)
	lock (^a,^b,^c):240
	if $t=0 w "TEST-E-lkewait3 Time out, waited too long for ^a",!  q

	set ^flag3=^pid3_" got ^a,^b"

	; Do not quit immediately
	; Wait for response from main process
	; Main needs do some processing at current status

	for i=1:1:240 q:$data(^q3)  h 1
	if i=240 w "TEST-E-lkewait3 Time out, waited too long for parent to signal ^q3",!  q
	if $GET(^q3)'="quit3"  w !,"TEST-E-lkewait3 Parent did not set ^q3",!
	q 
ERROR   ;
	ZSHOW "*"
	q

