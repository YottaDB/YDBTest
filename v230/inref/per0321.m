per0321	;per0321 - compiler assert fails after multiple errors
	;
	W !,GID=",GID," "
	S ^BSC(JOB,"END")=$H
	F I=1:1:10 S S X="ABC"
