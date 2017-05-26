BUG97	;MUST HAVE 512 BYTE BLOCKS TO CHECK THIS BUG
	;MUST HAVE EMPTY DATA BASE TOO
	F I=1:1:4 S ^A(1,I)=$J("",100)
	S ^A(2,0)="$"
	S ^A(2,1)=$J("",100)
	K ^A(2,0)
	W "$O=",$O(^A(2,"")),!
	W "$D=",$D(^A(2)),!
	W "$D=",$D(^A(2,1)),!
