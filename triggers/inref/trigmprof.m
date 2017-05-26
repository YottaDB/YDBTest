	; We should be able to use M profiling when triggers are involved.
	; M profiling is started and stopped at various boundaries between the
	; M runtime and trigger levels.
trigmprof
	; load the trigger file before doing the test
	do text^dollarztrigger("tfile^trigmprof","trigmprof.trg")
	do file^dollarztrigger("trigmprof.trg",1)

	do setA^trigmprof
	do setB^trigmprof
	do setC^trigmprof
	do setD^trigmprof
	do setE^trigmprof
	do ^echoline
	quit

	;
	; The output information says what the test should do
	;

setA
	do ^echoline
	view "trace":1:"^trace"
	write "Set ^A, tracing started in the M routine",!
	set ^A($increment(^count))=^count
	view "trace":0
	quit

setB
	do ^echoline
	write "Set ^B, tracing started and stopped in the trigger",!
	set ^B($increment(^count))=^count
	quit

setC
	do ^echoline
	write "Set ^C whose trigger stops tracing",!
	set ^C($increment(^count))=^count
	write "Turn on tracing for ^C and see if it can stop it",!
	view "trace":1:"^trace"
	set ^C($increment(^count))=^count
	quit

setD
	do ^echoline
	write "Set ^D, tracing started in the trigger, stopped outside",!
	set ^D($increment(^count))=^count
	view "trace":0
	quit

setE
	do ^echoline
	view "trace":1:"^E"
	write "Set ^E, tracing turned on and put into triggered GVN",!
	set ^E($increment(^count))=^count
	view "trace":0
	quit

	; this is the routine used in the triggers to just write out
	; stuff to show that the trigger was invoked
trace
	write $char(9),"Trigger trace Executed",!
	set x=$increment(^count)
	quit

tfile
	;;paired with setA
	;+^A(:) -commands=S -xecute="do trace^trigmprof"
	;;paired with setB. view trace is done inside the trigger
	;+^B(:) -commands=S -xecute="view ""trace"":1:""^trace"" do trace^trigmprof view ""trace"":0 "
	;;paired with setC. view trace is stopped inside the trigger
	;+^C(:) -commands=S -xecute="view ""trace"":0 do trace^trigmprof"
	;;paired with setE. view trace is stopped inside the trigger
	;+^E(:) -commands=S -xecute="do trace^trigmprof"
	;;paired with setD. view trace is started inside the trigger
	;+^D(:) -commands=S -xecute="view ""trace"":1:""^trace"" do trace^trigmprof"
