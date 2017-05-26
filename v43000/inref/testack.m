testack	;
	; test nesting/newing of $estack
	
	Write "testack starting",!

	Write "Ground zero level:",!
	Write " .. $stack: ",$Stack,"  $estack: ",$estack,!
	do A
	Write "Back in main - zero level:",!
	Write " .. $stack: ",$Stack,"  $estack: ",$estack,!
	Q

A	;
	Write "Entering Routine A",!
	Write " .. $stack: ",$Stack,"  $estack: ",$estack,!
	New $ESTACK
	Write "Newing $ESTACK in A",!
	Write " .. $stack: ",$Stack,"  $estack: ",$estack,!
	Do B
	Write "Back from B in A:",!
	Write " .. $stack: ",$Stack,"  $estack: ",$estack,!
	Q

B
	Write "Entering Routine B",!
	Write " .. $stack: ",$Stack,"  $estack: ",$estack,!
	New $ESTACK
	Write "Newing $ESTACK in B",!
	Write " .. $stack: ",$Stack,"  $estack: ",$estack,!
	Q
