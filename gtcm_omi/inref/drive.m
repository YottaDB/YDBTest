drive	; ; ; driver program for [tp]resil
	;
	New
	Set output="volkill.mjo0",error="volkill.mje0"
	Open output:newversion,error:newversion
	Use output
	Set kx=0,cnt=0
	New $ZTrap Set $ZTrap="Set cnt=cnt+1 Use error ZSHOW ""*"" Write ! Use output ZGoto "_$ZLevel_":error^drive"
	W "PID ",$j,!
 	do ^cmclient(2,101,$ZPARSE("mumps.gld"))
	set portfile="portno.txt" open portfile use portfile
	read port
	close portfile
 	i $$^connect("127.0.0.1",port,"user","pw")=0 w "Attempted connection to GT.CM server failed!",! q
	set jmaxwait=0
	do ^job("^volkill",8,"""""")
	w "Spawned all the 8 clients...",!
	; Do interfering updates in parent GT.M process
 	Do in0^gtcmfill("set")
 	Do in0^gtcmfill("ver")
  	Do in1^gtcmfill("set")
  	Do in1^gtcmfill("ver")
	; Wait for children/clients to finish
	do wait^job
	w "All the clients Done",!
	s disconnect=$$^disc()
	q
error
	w "f kx=1:1:8  s job=$$^get(""^JOB"") q:job=0  do in2^gtcmfill(""set""),in2^gtcmfill(""ver""),in2^gtcmfill(""kill"")  h 30",!  
	f kx=1:1:8  s job=$$^get("^JOB") q:job=0  do in2^gtcmfill("set"),in2^gtcmfill("ver"),in2^gtcmfill("kill")  h 120
	Set $ZTrap=""
	Write !,$Select(cnt:"FAIL",1:"COMPLETE")," from ",$T(+0)
	Close output
	If cnt Close error
	Else  Close error:delete
	Halt
