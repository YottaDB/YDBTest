	; This test case is a result of a bug found where the trigger for ^A(2)
	; was fired for updates to ^A(1) until a non-trigger update to ^A(2)
	; was made. The first two test cases had the trigger for ^A(2) chained
	; after the udpate to ^A(1)
chainVnest
	; load the trigger file before doing the test
	do text^dollarztrigger("tfile^chainVnest","chainVnest.trg")
	do file^dollarztrigger("chainVnest.trg",1)

	do ^echoline
	write !,?10,"Should see two triggers fire",!
	kill ^A set ^A(1)=1
	write "Stacking=",^stacks,!
	if ^stacks=2 write "PASS",!
	else  write "FAIL",!
	kill ^stacks
	
	do ^echoline
	write !,?10,"Should again see two triggers fire",!
	set ^A(1)=11
	write "Stacking=",^stacks,!
	if ^stacks=2 write "PASS",!
	else  write "FAIL",!
	kill ^stacks
	
	do ^echoline
	write !,?10,"Should see one trigger fire",!
	set ^A(2)=22
	write "Stacking=",^stacks,!
	if ^stacks=1 write "PASS",!
	else  write "FAIL",!
	kill ^stacks
	
	do ^echoline
	write !,?10,"Should yet again see two triggers fire",!
	set ^A(1)=111
	write "Stacking=",^stacks,!
	if ^stacks=2 write "PASS",!
	else  write "FAIL",!
	kill ^stacks
	
	do ^echoline
	write !,?10,"Kill ^A and we should still see two trigger fire",!
	kill ^A set ^A(1)=1
	write "Stacking=",^stacks,!
	if ^stacks=2 write "PASS",!
	else  write "FAIL",!
	kill ^stacks

	do ^echoline
	quit

abc
	write "ABC Executed!",!
	zshow "s"
	set x=$increment(^stacks)
	quit

tfile
	;;trigger name: A#1#  cycle: 2
	;+^A(1) -commands=S -xecute="do abc^chainVnest set ^A(2)=2"
	;;trigger name: A#2#  cycle: 2
	;+^A(2) -commands=S -xecute="do abc^chainVnest"

