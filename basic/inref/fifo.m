fifo	; Test of named pipe.
	New

	Kill ^message,^count,^who
	Set ^errcnt2=0
	If $ZVERSION'["VMS" Do
	. Set trace="($gtm_tst/com/do_dbx_c_stack_trace.csh -instance=fifo "_$job_" $gtm_exe/mumps 1 30 &) >& /dev/null"
	. ZSYSTEM trace
	. ZSYSTEM "echo tracing fifo "_$job_" >>&! dbx_c_stack_trace_fifo.trace"

	Do begin^header($TEXT(+0))
	Write "  ** fifo output **",!

	Set pipe="FIFO.pipe"
	Open pipe:FIFO

; Write all legal characters.  $CHAR(10) terminates one record.
;	Unicode has additional terminators - see below
	Job fifo2(pipe):(GBLDIR="mumps.gld")
	Use pipe:WIDTH=512
	For i=0:1:255 Write $CHAR(i)
	Write !  Use $PRINCIPAL  Hang 2

	If $ZVERSION["CYGWIN" Do
	. Write "FIFO blocks on CYGWIN 1.5-24-2, try again when 1.7 is out",!
	. zgoto $zlevel-1:finish

; Send random messages back and forth between fifo and fifo2.
; ^who determines which process reads and which process writes.
; ^message keeps track of the messages written to the pipe.

	For ii=1:1:5  Set ^who=1  Do  Quit:^who=2
	. Set whichwriter="fifo"
	. Do writer  Set ^who=2
	. For j=1:1:600  Quit:^who=1  Hang 1     ; Wait for fifo2.
	. If ^who'=1  Write "** FAIL  - Timed out waiting for fifo2",!  Set errcnt=errcnt+1  Quit
	. Set whichwriter="fifo2"
	. Do reader

	If errcnt=0 Write "   PASS",!

finish
	Hang 5
	Write "  ** fifo2 output **",!
	ZSYSTEM "cat fifo.mjo fifo.mje"

	Set errcnt=errcnt+^errcnt2
	Do end^header($TEXT(+0))
	; Note that CYGWIN 1.5.24-2 doesn't delete pipes since the inodes are different in iorm_close.c
	Close pipe:DELETE

	Quit

fifo2(pipe)	; Companion process which uses named pipe to talk to fifo.
	New i,n,fail

	If $ZVERSION'["VMS" Do
	. Set trace="($gtm_tst/com/do_dbx_c_stack_trace.csh -instance=fifo2 "_$job_" $gtm_exe/mumps 1 30 &) >& /dev/null"
	. ZSYSTEM trace
	. ZSYSTEM "echo tracing fifo2 "_$job_" >>&! dbx_c_stack_trace_fifo2.trace"

	Set errcnt=0
	Open pipe:FIFO

; Read all legal characters.  $CHAR(10) terminated one record.
;		for Unicode, also $char(12), $char(13), $char(133),
;				$char(8232), and $char(8233)
	Use pipe  Read x:600  Use $PRINCIPAL
	If $TEST=0 Write "Read 1a timed out!",! Set errcnt=1  Goto end
	Do ^examine($LENGTH(x),10,"Read 1a LENGTH")
	For i=1:1:$LENGTH(x) Do ^examine($ASCII($EXTRACT(x,i)),i-1,"Read 1a")
	Use pipe  Read x:600  Use $PRINCIPAL
	If $TEST=0 Write "Read 1b timed out!",! Set errcnt=1  Goto end
	if ($ZCHSET'="UTF-8") do
	. Do ^examine($LENGTH(x),245,"Read 1b LENGTH")
	. For i=1:1:$LENGTH(x) Do ^examine($ASCII($EXTRACT(x,i)),i+10,"Read 1b")
	if ($ZCHSET="UTF-8") do
	. Do ^examine($LENGTH(x),1,"Read 1b LENGTH")
	. For i=1:1:$LENGTH(x) Do ^examine($ASCII($EXTRACT(x,i)),i+10,"Read 1b")
	. Use pipe  Read x:600  Use $PRINCIPAL
	. If $TEST=0 Write "Read 1c timed out!",! Set errcnt=1  Goto end
	. Do ^examine($LENGTH(x),0,"Read 1c LENGTH")
	. For i=1:1:$LENGTH(x) Do ^examine($ASCII($EXTRACT(x,i)),i+12,"Read 1c")
	. Use pipe  Read x:600  Use $PRINCIPAL
	. If $TEST=0 Write "Read 1d timed out!",! Set errcnt=1  Goto end
	. Do ^examine($LENGTH(x),119,"Read 1d LENGTH")
	. For i=1:1:$LENGTH(x) Do ^examine($ASCII($EXTRACT(x,i)),i+13,"Read 1d")
	. Use pipe  Read x:600  Use $PRINCIPAL
	. If $TEST=0 Write "Read 1e timed out!",! Set errcnt=1  Goto end
	. Do ^examine($LENGTH(x),122,"Read 1e LENGTH")
	. For i=1:1:$LENGTH(x) Do ^examine($ASCII($EXTRACT(x,i)),i+133,"Read 1e")

	If $ZVERSION["CYGWIN" Do
	. Write "FIFO blocks on CYGWIN 1.5-24-2, try again when 1.7 is out",!
	. Halt

	Set fail=0
	For ii=1:1:5  Do  Quit:fail
	. For j=1:1:600  Quit:$Get(^who)=2  Hang 1     ; Wait for fifo.
	. If $Get(^who)'=2  Write "** FAIL  - Timed out waiting for fifo",!  Set errcnt=errcnt+1  Set fail=1  Quit
	. Set whichwriter="fifo"
	. Do reader
	. Set whichwriter="fifo2"
	. Do writer  Set ^who=1

	If errcnt=0 Write "   PASS",!

end
	Set ^errcnt2=errcnt
	Quit

	;Note : While analyzing timing issues
	; write begin -> ^debugmessage("fifo",1,1)
	; write end   -> ^debugmessage("fifo",1,1,"writer","done")
	; read begin  -> ^debugmessage("fifo",1,1,"reader","start")
	; read timeout-> will be printed in log file when it timesout
writer	; Write random messages to pipe
	New i,j
	Set ^count=$RANDOM(10)+1
	For i=1:1:^count  Do
	. Set ^message(whichwriter,ii,i)=""
	. set writemsg=""
	. For j=1:1:($RANDOM(80)+1)  Do
	. . set writemsg=writemsg_$CHAR($RANDOM(95)+32)
	. Set ^message(whichwriter,ii,i)=writemsg
	. use pipe
	. set ^debugmessage(whichwriter,ii,i)=ii_","_i_"::"_$H_"::"_^message(whichwriter,ii,i)
	. Write ^message(whichwriter,ii,i),!  Use $PRINCIPAL
	. set ^debugmessage(whichwriter,ii,i,"writer","done")=$H
	Quit

reader	; Read random messages from pipe
	New i,message,fail
	Set fail=0
	For i=1:1:^count Do  Quit:fail
	. Use pipe  s ^debugmessage(whichwriter,ii,i,"reader","start")=$H Read message:600  Use $PRINCIPAL
	. If $TEST=0 Write "reader timed out!",!,"Iteration::$H::Data_written_by_writer: ",^debugmessage(whichwriter,ii,i),!,"Time now :",$H,! Set fail=1 Set errcnt=errcnt+1 Quit
	. Do ^examine(message,^message(whichwriter,ii,i),"Read")
	. Set ^debugmessage(whichwriter,ii,i,"reader")=ii_","_i_"::"_$H_"::"_message
	Kill ^message
	Quit
