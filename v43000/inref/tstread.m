; Test the dreaded getchar() problem that occurs on some platforms 
; (most notoriously Tru64). If we do a job command while a flat file
; is open and being read, the closure of the files in the forked off
; process prior to running an exec() causes an lseek to be done on 
; the open file resetting it's read pointer to the beginning of the
; file in the main process. A stupid way to run a railroad but we
; supposedly handle that problem now.

tstread	;
	S file="tstread.file"
	S recmax=100000
	S writeinc=10000
	S readinc=7001

	Open file:(new)
	Write "Writing new file",!
	Use file
	for i=1:1:recmax Do
	. If i#writeinc=0 Job doit^tstread
	. Write $j(i,120),!
	Close file

	Open file:(readonly)
	Use $P
	Write "Beginning reading of file",!
	Use file
	for i=1:1:recmax Do
	. If i#readinc=0 Job doit^tstread
	. Read x
	. If x'=$j(i,120) Do  Quit
	. . Use $P
	. . Write "Wrong value read.. i = ",i," value read '",x,"'",!
	. . Write "length ",$Length(x),!
	. . Halt

	Use $P
	Write "Everything worked",!
	Quit

doit	;
	;
	Write "We are doing and have done doit()",!
	Quit

