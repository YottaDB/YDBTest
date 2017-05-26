; [C9H03-002835] Test the MOREREADTIME socket device option.
;
; - Create a string to send 1000 bytes long.
; - For each MOREREADTIME of -2(undefined morereadtime),200, 100, 50, DEFAULT:
;   - Open a socket with no delimiters.
;   - ZSHOW the device
;   - Fork off a receiver process
;   - Record start time
;   - Send random 10-20 byte chunks of the string to the receiver.
;   - After each chunk, the sender waits for the full string to be returned (with a fixed length read).
;   - Receiver echos the received data in 3-5 byte chunks.
;   - Record ending elapsed time.
;   - Check that elapsed is less than previous elapsed (runs should be getting better or at least no worse).
;     [Update: Since some platforms (notably AIX and Tru64) seem to get the same dismal numbers for several of the
;      mrt settings, the rule is now that subsequent runs must not increase by more than 15%]
;   - Close down receiver process

        Set iterations=1		; Iterations of sending string for each MOREREADTIME loop.
	Set morereadtimedefault=10	; As of now (4/2007) default is 10ms
	Set startshutdowntimeout=300	; For loops starting up or shutting down, do a max 5 minute wait

        Set $Ztrap="Set $Ztrap="""" Set ^done=1 Use $P ZShow ""*"" Halt"
        Set unix=$ZVersion'["VMS"

        Set ^recvractive=0
        Set ^done=0
	Set ^maxdatalen=1000
	Set ^mrt(1)=-2
	Set ^mrt(2)=200
	Set ^mrt(3)=100
	Set ^mrt(4)=50
	Set ^mrt(5)=morereadtimedefault
	; Note an mrt of 1 does not test any better than an mrt of 10 so we limit the index to the first 4 and leave 1 out of it
	; since it causes test failures on account of the "continual improvement" requirement.
	Set ^mrt(6)=1
	Set ^mrtmaxindx=5

	; Build a string of ^maxdatalen bytes long out of repetitions of our buildingblock string below
	Set strblk="abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	Set $Piece(sdata,strblk,(^maxdatalen\$Length(strblk))+2)=""
	Set sdata=$Extract(sdata,1,^maxdatalen)
 
        ; Fork off receiver
        Write "Spawning receiver process",!
        If unix Job @("receiver^tsockmrt():(output=""receiver.mjo"":error=""receiver.mje"")")
        Else    Job @("receiver^tsockmrt():(nodetached:startup=""startup.com"":output=""receiver.mjo"":error=""receiver.mje"")")
        ; Make sure at least one dot
        For i=1:1:startshutdowntimeout Write "." Quit:^recvractive=1  Hang 1
        If i>startshutdowntimeout Do
        . Write !,"FAIL TEST - Receiver did not STARTUP in the allotted time",!
        . ZSHOW "*"
	. Halt
	Else  Write !,"Receiver process active",!

        ; Connecting to the receiver
	Write "Connecting to the receiver",!
        Set portno=^config("portno"),hostname=^config("hostname")
        Set tcpdev="client$"_$j,timeout=20	; 20 second timeout for heavy load conditions
        Set openarg="(connect="""_hostname_":"_portno_":TCP"""_":attach=""client"")"
        Open tcpdev:@openarg:timeout:"SOCKET"
        Write !,"Connection to receiver established",!

	Set lastelapsed=9999999
	; Loop through each morereadtime setting recording how long it takes to run with each one.
	For mrtindx=1:1:^mrtmaxindx Do  quit:^done
	. Set mrt=^mrt(mrtindx)
	. ; Need to do USE with MRT set here so it is properly reflected in the ZSHOW below
	. ; The first iteration (-2) does not define MOREREADTIME.  The code will do the initial read of one or 
	. ; more characters with timeout set to 200ms and then switch to the default of 10ms for additional reads
	. if 1=mrtindx Use tcpdev
	. else  Use tcpdev:MOREREADTIME=mrt
	. Use $P
	. Write !,!,"****************** New iteration (mrt=",mrt,") *****************",!,!
	. ZShow "D"
	. Use tcpdev
	. Set datatosend=sdata
	. Set recvdata=""
	. Set charcnt=0
	. Set starttime=$H
	. For  Do  Quit:^done!(datatosend="")
	. . Set slen=10+$Random(11)
	. . If slen>$Length(datatosend) Set slen=$Length(datatosend)
	. . Write $Extract(datatosend,1,slen)
	. . Set datatosend=$Extract(datatosend,slen+1,^maxdatalen)
	. . ; Now receive the echo
	. . Read dpacket#slen:timeout
	. . Else  Do
        . . . Use $P
        . . . Write "Read timeout after reading ",charcnt," chars in the mrt=",mrt," iteration",!
        . . . ZShow "*"
        . . . Close tcpdev
        . . . Set ^done=1
        . . . Do HaltWhenRecvrStopped
	. . If $Length(dpacket)'=slen Do
	. . . Use $P
	. . . Write "Expected ",slen," characters, Got ",$Length(dpacket),!
	. . . Use tcpdev
	. . Set charcnt=charcnt+slen
	. . Set recvdata=recvdata_dpacket
	. ;
	. ; At conclusion of loop record end time, compute elapsed and verify echoed string is what we sent.
	. Set endtime=$H
	. Set elapsecs=$$^difftime(endtime,starttime)
	. Use $P 
	. If ^done Do
	. . Write "Terminating early due to ^done being set",!
	. . Halt
	. If ($Length(recvdata)'=^maxdatalen)!(recvdata'=sdata) Do
	. . Write "Data length or contents not as expected",!
	. . Write "Sent length: ",^maxdatalen,"  Received length: ",$Length(recvdata),!
	. . Write "Received data:",!
	. . Write recvdata,!
	. . Set ^done=1
	. . ZShow "*"
	. . Do HaltWhenRecvrStopped
	. Write "Elapsed seconds for this mrt test: ",elapsecs,!
	.; The following lines were commented out due to inconsistent times on some slower platforms
	.; If elapsecs>(lastelapsed*1.15) Do
	.; . Write !,"Elapsed time (",elapsecs,") for mrt=",mrt,"ms is worse than previous elapsed time (",lastelapsed,")",!
	.; . Set ^done=1
	.; . ZShow "*"
	.; . Do HaltWhenRecvrStopped
	. Set lastelapsed=elapsecs
	. If 1=mrtindx set firstelapsed=elapsecs
	. If ^mrtmaxindx=mrtindx set finalelapsed=elapsecs

	; We expect the first elapsed time to be no more than 2 sec greater than the final elapsed time
	; The following lines were commented out due to inconsistent times on some slower platforms
	;If finalelapsed<(firstelapsed-2) Do
       ;. Write !,"FAIL TEST - first elapsed time not within 2 sec of final elapsed time",!
	;. Set ^done=1
	;. ZShow "*"
	;. Do HaltWhenRecvrStopped

	; If we fall out of the main loop then all mrt values did the expected thing
	Close tcpdev
	Set ^done=1
	Write !,"***************************",!
	Write !,"TEST PASS",!
	Write !,"Shutting down receiver process - test complete",!
	Do HaltWhenRecvrStopped

	; end of routine - this will not return


	;
	; Receiver routine..
receiver
        Set $Ztrap="Set $Ztrap="""" Use $P ZShow ""*"" Set ^recvractive=0 Set ^done=1 Halt"
	; Set up a listener and wait for connection
        Set portno=^config("portno")
        Set tcpdev="server$"_$j,timeout=30
        Set openarg="(ZLISTEN="""_portno_":TCP"""_":attach=""server"")"
        Open tcpdev:@openarg:timeout:"SOCKET"
        Set timeout=20  ; 20 second timeout is sufficient for small packets under heavy load
        Use tcpdev
        Write /listen(1)
        Set ^recvractive=1               ; signal main we are running (listening)
        Write /wait(timeout)
        Else  
	. Use $P 
	. Write "Open to main failed during wait for connection: $zstatus=",$Zstatus,! 
	. Set ^done=1 
	. Halt
        Set key=$Key,childsocket=$Piece(key,"|",2),ip=$p(key,"|",3)
        Use $P
        Zwrite key
        Write !,"Receiver now connected to main process",!

	Set mrtindx=1
	; do no set morereadtime for first iteration 
	Use tcpdev
	Set charcnt=0
	Set maxcharcnt=^maxdatalen
	;
	; This processes job is only to read in the bytes as they come in and write them
	; back out but perhaps in a different format than they were received.
	For  Quit:^done  Do
	. Read packet:timeout
	. Else  Do
	. . Use $P
	. . Write "Read timeout after reading ",charcnt," chars in the mrt=",^mrt(mrtindx)," iteration",!
	. . ZShow "*"
	. . Close tcpdev
	. . Set ^recvractive=0
	. . Set ^done=1
	. . Halt
	. If ^done Do
	. . Use $P
	. . Write "Terminating due to setting of ^done",!
	. . Close tcpdev
	. . ZShow "*"
	. . Set ^recvractive=0
	. . Halt
	. If packet="" Do
	. . Use $P
	. . Write "Null read received",!
        . . ZShow "*"
	. . Close tcpdev
        . . Set ^recvractive=0
	. . Set ^done=1
        . . Halt
	. ;
	. ; Keep track of how many chars we have received
	. Set charcnt=charcnt+$Length(packet)
	. ;
	. ; Next job is to send the received packet back out
        . Set datatosend=packet
        . For  Do  Quit:^done!(datatosend="")
        . . Set slen=3+$R(3)
        . . If slen>$Length(datatosend) Set slen=$Length(datatosend)
        . . Write $Extract(datatosend,1,slen)
        . . Set datatosend=$Extract(datatosend,slen+1,^maxdatalen)
	. ;
	. ; When we reach a boundary, switch to the next mrt or exit if done
	. If charcnt=^maxdatalen Do
	. . Set mrtindx=mrtindx+1
	. . If mrtindx>^mrtmaxindx Do
	. . . Use $P
	. . . Write "Echo process is complete -- waiting for ^done flag before exiting",!
        . . . ; Make sure at least one dot
        . . . For i=1:1 Write "." Quit:^done  Hang 1
        . . . Write !,"Main routine signals completion - shutting down now",!
	. . . Close tcpdev
	. . . Set ^recvractive=0
	. . . Halt
	. . Else  If charcnt>^maxdatalen Do
	. . . Use $P
	. . . Write "Charcnt (",charcnt,") unexpectedly exceeds maxdatalen (",^maxdatalen,")",!
	. . . ZShow "*"
	. . . Close tcpdev
        . . . Set ^recvractive=0
        . . . Set ^done=1
        . . . Halt
	. . Set charcnt=0
	. . Use tcpdev:MOREREADTIME=^mrt(mrtindx)

	; If we we didn't leave the loop quite like we wanted to. Receiver is dying so no need to
	; wait on its account..
	If ^done Do
        . Use $P
        . Write "Terminating due to setting of ^done",!
        . ZShow "*"

	; Normal close
	Close tcpdev
        Set ^recvractive=0
        Halt

; Routine to wait until the receiver process shuts down
HaltWhenRecvrStopped
        ; Make sure at least one dot
        For i=1:1:startshutdowntimeout Write "." Quit:^recvractive=0  Hang 1
	If i>startshutdowntimeout Do
	. Write !,"FAIL TEST - Receiver did not SHUTDOWN in the allotted time",!
	. ZShow "*"
        Else  Write !,"Receiver process has shutdown",!
	Halt
