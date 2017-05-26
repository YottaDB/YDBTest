basicmm	; Basic test of /ACCESS_TYPE=MM segments.
	Set ^MMVAR="This is the MM segment test."
	For i=0:1:9 Set ^MMARR(i)="single subscript: "_i For j=0:1:(9-i)/2 Set ^MMARR(i,j)="double subscript: "_i_","_j
	ZWRite ^MMVAR,^MMARR
	Quit
