	; ztrigio
	; This test does io from within triggers.
	; The diskio test creates a file called dfile.out of 10 lines of text.  It then
	; closes the file, reopens it for read, and writes each line to $p.  It is
	; invoked by setting ^a.
	; 
	; The fifoio test creates a fifo called fifo1 and uses a zsystem call to cat the
	; dfile.out to the fifo.  It then reads the 10 lines from the fifo and writes
	; each line to $p.  It is invoked by setting ^b.
	; 
	; The pipeio test sets up a read only pipe to cat the dfile.out back to the pipe
	; device.  It reads lines until end of file is seen and writes each line to $p.
	; It is invoked by setting ^c.
	;
	; The relay test does the four steps of file io - open, use, write and close - in
	; four different triggers. It also copies the main part of the diskio test
ztrigio
	do ^echoline
	do setup
	do ^echoline
	set ^a=$increment(i)
	set ^b=$increment(i)
	set ^c=$increment(i)
	write !,"Outside of the triggers:",!
	write "Expect ^inp3 to be null as we let it read to end of file",!
	write "^inp=",^inp,!,"^inp2=",^inp2,!,"^inp3=",^inp3,!
	do ^echoline
	ztrigger ^relay("open")
	do ^echoline
	quit

setup
	do text^dollarztrigger("tfile^ztrigio","ztrigio.trg")
	do file^dollarztrigger("ztrigio.trg",1)
	do selectall^dollarztrigger
	quit

tfile
	;; diskio test
	;+^a -commands=SET -xecute=<<
	;diskio
	;	do ^echoline
	;	write !,"DISK TEST",!!
	;	set a="dfile.out"
	;	open a:newfile
	;	use a
	;	set string=":23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
	;	for i=0:1:9 write i,string,!
	;	use $p		
	;	use a:rewind
	;	for i=0:1:9 read ^inp use $p write ^inp,! use a
	;	close a
	;	do ^echoline
	;	quit
	;>>
	;; fifoio test
	;+^b -commands=SET -xecute=<<
	;fifoio
	;	do ^echoline
	;	write !,"FIFO TEST",!!
	;	set fif="fifo1"
	;	open fif:(fifo:newversion)
	;	zsystem "cat ./dfile.out > fifo1"
	;	use fif
	;	for i=0:1:9 read ^inp2 use $p write ^inp2,! use fif
	;	close fif
	;	do ^echoline
	;	quit
	;>>
	;; pipeio test
	;+^c -commands=SET -xecute=<<
	;pipeio
	;	do ^echoline
	;	write !,"PIPE TEST",!!
	;	set pdev="pipe1"
	;	open pdev:(command="cat ./dfile.out":readonly)::"pipe"
	;	use pdev
	;	for i=0:1:10 read ^inp3 quit:$zeof  use $p write ^inp3,! use pdev
	;	close pdev
	;	do ^echoline
	;	quit
	;>>
	;; diskio test split across multiple triggers
	;+^relay("open") -commands=ZTR -xecute=<<
	;	do ^echoline
	;	set file="relay.outx"
	;	open file:newversion
	;	ztrigger ^relay("use")
	;	zwrite ^relay
	;	do ^echoline
	;>>
	;+^relay("use") -commands=ZTR -xecute=<<
	;	set file="relay.outx"
	;	use file
	;	ztrigger ^relay("write")
	;>>
	;+^relay("write") -commands=ZTR -xecute=<<
	;	set file="relay.outx"
	;	set string=":23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
	;	write file,!
	;	for i=0:1:9 write i,string,!
	;	ztrigger ^relay("rewind")
	;	ztrigger ^relay("close")
	;>>
	;+^relay("rewind") -commands=ZTR -xecute=<<
	;	set file="relay.outx"
	;	use file:rewind
	;	ztrigger ^relay("read")
	;>>
	;+^relay("read") -commands=ZTR -xecute=<<
	;	set file="relay.outx"
	;	for i=0:1:9 read ^relay(i)
	;	quit
	;>>
	;+^relay("close") -commands=ZTR -xecute=<<
	;	set file="relay.outx"
	;	close file
	;>>

