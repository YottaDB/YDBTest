mnset	; set many globals
	Set unix=$ZVersion'["VMS"
	w "Will set many globals,",!
	s file="job.txt"
	o file
	u file
	if unix w $J,!
	e  w $$FUNC^%DH($J)
	c file
	f i=1:1:100000000 s ^a(i)=i,^b(i)=i
	q
