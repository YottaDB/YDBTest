repeol(lit1,lit2)
	;
	; Mimics one use of awk/gawk, corresponding to
	; '{ sub(/lit1.*/,"lit2"); print; }'
	; In each line, replaces any occurrence of lit1 through the end of the line with lit2.
	; Since Read and Write are to the same IO device, limited to STDIN input & STDOUT output.
	;
	; Typical usage:
	;    mumps -run %XCMD 'do repeol^awk(lit1,lit2)' <FILE
	;    PROG | mumps -run %XCMD 'do repeol^awk(lit1,lit2)'
	;
	
	for  read line quit:$zeof  do
	. write $zpiece(line,lit1,1)
	. write:$zfind(line,lit1) lit2
	. write !
	quit
