; mnset "set"s large number of globals so that when they are kill by mnkill it results into freeing of block(s) 
; in the database
mnset   ; set many globals
	for i=1:1:10 do
	. for j=1:1:10 do
	.. for k=1:1:10 do
	... set ^a(i,j,k)=$justify("a",200),^b(i,j,k)=$justify("b",200)
	quit
mnkill
	Set unix=$ZVersion'["VMS"
	; Randonmly select TP or NON-TP
	set ttype=$random(2)
	if ttype write "TP",!
	else  write "NON-TP",!
	set file="job.txt"
	open file
	use file
	if unix write $JOB,!
	else  write $$FUNC^%DH($JOB)
	close file
	for i=1:1:10 do
	. for j=1:1:10 do
	.. if ttype=1 tstart ():(serial:transaction="ONLINE")
	.. kill ^a(i,j),^b(i,j)
	.. if ttype=1 tcommit
	write "Finished killing",!
	quit
