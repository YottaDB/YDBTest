gtm7415 ;
	; $zmessage(errorNumber) can cause seg faults for some values of errorNumber 
	;
	; This test goes through a range of numbers to make sure no input to $ZMESSAGE() causes a SEG-Fault
	; The value of $zmessage(i) is used in the if statement to makes sure it won't be discarded by the compiler altogether

	; RANGE is the range for iteration
	set RANGE=100000000
	; SHORTRANGE iterations should finish in less than a second
	set SHORTRANGE=10000
	set stop=0
	set start=$random((2**31)-RANGE)
	set timeout=30
	write "Iterating through ",RANGE," input values to $ZMESSAGE from a random initial value with increments of 8 (to discard the first three bits). Stopping if ",timeout," seconds pass.",!

	set startTime=$horolog
	for startI=start:SHORTRANGE:start+RANGE quit:(stop!($$^difftime($horolog,startTime)>timeout))  do
	.	for i=startI:8:(startI+SHORTRANGE) quit:stop  do
	..		if $zmessage(i)=""  write "Empty error message from $zmessage at ",i,! set stop=1
	write "Done iterating",!

	write "Making sure undefined errors are recognized as UNKNOWN for a set of test cases",!
	write $zm(134250496),!,$zm(149979144),!,$zm(134250504),!,$zm(150372360),!
	write "Done",!
	quit
