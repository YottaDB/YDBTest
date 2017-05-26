head(n,file)
	;
	; Mimics limited use cases of the head program
	; If n is positive, prints the first n lines of the input
	; If n is negative, prints all lines but the last N lines
	; Read from the current IO device, or file if present.
	; Write will be done on the current IO device.
	; Typical Usage:
	;    mumps -run %XCMD 'do ^head(N)' <FILE
	;    PROG | mumps -run %XCMD 'do ^head(N)'
	;    from another M program : 'do ^head(N,file)'
	;
	new buffer,count,last,infile,outfile

	; Use default n if not supplied
	if '$DATA(n) set n=10

	; Switch to supplied file, if any
	if $DATA(file) open file:CHSET="M"  set infile=file  set outfile=$IO
	else  set infile=$IO  set outfile=$IO

	use infile:width=1048576

	; for +1
	if n'<0  do
	. for count=1:1  use infile  read buffer quit:$zeof  use outfile:(exception="quit")  write:count'>n buffer,!  quit:count>n

	; for -1
	if n<0  do
	. for count=1:1  read buffer(count) quit:$zeof
	. set last=count+n
	. use outfile:(exception="quit")
	. if last>0  for count=1:1 quit:count'<last  write buffer(count),!

	if $DATA(file) close file

	quit
