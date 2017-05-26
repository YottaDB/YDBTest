; We need at least 2 DSE/LKE processes running to initiate a bypass. This script jobs off the 1st process.
; This test tries to simulate a DSE console environment where the user types "dump" and "exit" commands.
; After "dump"  command is typed, a second process will come in.
runregular(fileno)
	set ^go=0 ; This is used for hanging. Must be externally set to 1
	set out="regularout"_"_"_fileno
	set err="regularerror"_"_"_fileno
	set cmd="regular:(output="""_out_""":error="""_err_""")"
	job @cmd
	quit

regular
	set go=0
	set $zinterrupt="set go=1"
	write $JOB,!
	open "regulardseproc":(shell="/bin/sh":command=$ztrnlnm("gtm_dist")_"/dse":stderr="regulardseprocstderr")::"pipe"
	use "regulardseproc"
	write "dump",!
	; read dump output to make sure dump command is executed
	; read dump output should be 11 lines long. We have to count lines because DSE does not put an EOF at the end of DSE DUMP output
	for i=1:1  quit:i=11  do 
	.   use "regulardseprocstderr" 
	.   read line:300
	.   if $test=0 use $P write "Error: Read timeout.",! halt
	.   else  use $P write line,!
	use $P
	write "start",! ; signal second process to go.
	use "regulardseproc"
	for i=1:1  quit:go=1  hang 1 if i=300 use $P write "300 seconds elapsed. Did not receive interrupt.",! halt; wait until go is externally set to 1
	write "exit",!
	write /EOF
	use $P
	write "DSE DONE",!
	close "regulardseproc"
	quit
