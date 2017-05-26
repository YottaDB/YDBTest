c002736	;
	; Test that the source server logs periodic messages only every 1000 transactions even if it is idle 
	; This is needed to ensure the logfile does not grow to a huge size.
	;
	for i=1:1:500  do
	.	for j=1:1:10  do
	.	.	set ^x(i,j)=$j(i,200)
	.	hang 0.01
	quit
