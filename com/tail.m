tail(n,file,lines)
	;
	; Mimics limited use cases of the tail program
	; tail -n +X where X is very large causes a performance
	; penalty for routines that want to receive the tail'ed
	; data
	;
	; If n is negative, prints the last n lines of the input
	; If n is positive, prints lines starting with the nth line
	; Read from the current IO device, or file if present.
	; Write will be done on the current IO device if 'lines' is
	; not defined. If 'lines' is defined it will store the
	; output in it.
	; Typical Usage:
	;    mumps -run %XCMD 'do ^tail(N)' <FILE
	;    PROG | mumps -run %XCMD 'do ^tail(N)'
	;    from another M program to stdout : 'do ^tail(N,file)'
	;    from another M program to a buffer: 'set lines="" do ^tail(N,file,.lines)'
	;
	new buffer,count,first,infile,outfile
	set first=0

	; Use default n if not supplied
	if '$DATA(n) set n=-10

	; Switch to supplied file, if any
	if $DATA(file) open file:(CHSET="M":readonly)  set infile=file  set outfile=$IO
	else  set infile=$IO  set outfile=$IO

	use infile:width=1048576

	; for +X
	if n>0 do
	. for count=1:1:n-1  read buffer quit:$zeof
	. for count=n:1 use infile  read buffer quit:$zeof  do
	. . if $data(lines) set lines(count)=buffer
	. . else  use outfile:(exception="quit")  write buffer,!
	. if $data(lines) kill lines(count)

	; for -X
	if n'>0 do
	. for count=1:1  read buffer(count) quit:$zeof  kill:n>(first-count) buffer($increment(first))
	. kill buffer(count)
	. if $data(lines) merge lines=buffer quit  ; caller wants the buffer, don't print the lines
	. set count=first
	. use outfile:(exception="quit")
	. for  set count=$order(buffer(count)) quit:'$length(count)  write buffer(count),!

	if $DATA(file) close file

	quit
