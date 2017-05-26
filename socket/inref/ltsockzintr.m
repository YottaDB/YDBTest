;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; LOCAL C9G04-002779 - Socket read is not Mupip interrupt-able
;
; Test flow:
; 1) Generate 1000 random numbers between 1K and 50K.
; 2) Set these numbers as pieces in one long string.
; 3) Fork off our communication peer (who in this scenario will do the "listening").
; 4) Fork off the interrupter job telling it process ids of both peer and ourselves.
; 5) Hang for a bit so the peer has its listen/wait interrupted a few times.
; 6) Open a local socket to the peer.
; 7) Send the random number string to the peer.
; 8) For each of the random lengths (in order), generate strings of the length given by the number
;    using the number itself as the source (repeated) of the string. This can be efficiently done
;    using set $piece and using the number as the delimiter.
; 9) Send each string across to the peer where they will be read and verified (while being
;    interrupted).
;

	Set ^rancnt=1000

	Set notifyinterval=^rancnt\20
        Set unix=$ZVersion'["VMS"
	Set ranmax=(50*1024)-(1*1024)
	For i=1:1:^rancnt Set $Piece(rands,"|",i)=$Random(ranmax)+(10*1024)

	Kill ^error
	Set ^drvactive=0,^peeractive=0
	Set ^done=0
	Set ^mainpid=$j
	Set ^zintmaincnt=0
	Set ^zintpeercnt=0
	Set ^zintsent=0
	Set $Zint="Set ^zintmaincnt=^zintmaincnt+1"
        Set $Ztrap="Set $Ztrap="""" Set ^done=1 Set ^done(""ltsockzintr"")=$Zpos Use $P Zshow ""*"" Halt"

	; Fork off peer
        Write "Spawning peer job",!
        If unix Job @("commpeer^ltsockzintr():(output=""commpeer.mjo"":error=""commpeer.mje"")")
        Else    Job @("commpeer^ltsockzintr():(nodetached:startup=""startup.com"":output=""commpeer.mjo"":error=""commpeer.mje"")")
	Write "." ; Make sure at least one dot
        For i=1:1 Quit:^peeractive=1  Write "."  Hang 1
	Write !,"Peer job active",!

        ; We have an external job to be our processus interruptus
        Write "Spawning interrupter job",!
        If unix Job @("intrdrv^ltsockzintr():(output=""intrdrv.mjo"":error=""intrdrv.mje"")")
        Else    Job @("intrdrv^ltsockzintr():(nodetached:startup=""startup.com"":output=""intrdrv.mjo"":error=""intrdrv.mje"")")
	Write "."
        For i=1:1 Quit:^drvactive=1  Write "."  Hang 1
	L ^drvactive		     ; When we get this lock, interrupter is starting to interrupt
	L

	Write !,"Interrupter job active -- Spinning for a few seconds",!
	; Peer and interrupter jobs are now active .. hang a bit more so peer gets beat on. Note we cannot do this with
	; the HANG command as it will be restarted when a $zinterrupt returns so it will effectively never exit.
	For i=1:1:20000 Set dummy($j(i,22))=$j(i,50)
	Kill dummy

	; Setup main driver -- connect to peer.
	Write "Connecting to peer",!
        Set path=^config("path"),delim=^config("delim")
        Set tcpdev="client$"_$j,timeout=120
        Set openarg="(connect="""_path_":LOCAL"""_":attach=""client"")"
        Open tcpdev:@openarg:timeout:"SOCKET"
        Else  Do
	. Set ^error($H,"client")="SOCBA2SIC-E-FAILED to open socket connection at "_$Zpos
	. Write "open failed : $zstatus=",$Zstatus,!
	. ZShow "*"
	. Set ^done=1,^done("Open failed")=$Zpos
	. Halt
        Write !,"Connection to peer established",!
	Use tcpdev:(delimiter=delim:width=1048576)

	; Send peer the list of generated random numbers.
	Write rands,!

	Use $P
	Write "Random number list sent -- Beginning send of strings",!
	Use tcpdev
	; Now run list of strings and send them all as fast as we can
	For i=1:1:^rancnt Do
	. If ^done Use $P Write "Halting on ^done setting",! Halt
        . Set sendlen=$Piece(rands,"|",i)
 	. Set sendtxt=$$stroflen(sendlen)
	. Write sendtxt,!
	. If i#notifyinterval=0 Use $P Write "Write #",i," complete",! Use tcpdev

	Use $P
	Write "String sends complete -- awaiting peer completion",!
	; Now wait for peer to go inactive (it is finished). If it takes more than
	; 60 seconds, raise an error as it shouldn't get *that* far behind since all
	; on same system doing approx same processing getting the same beating from the
	; interrupt job.
        L ^peeractive:60
	If ^peeractive Do
        . Set ^error($H,"client")="SOCBA2SIC-E-FAILED Peer did not finish in allotted time"
        . Write "Peer did not finish in allotted time",!
        . Set ^done=1,^done("Peer did not finish in allotted time")=$Zpos
        . Halt

	Set ^done=1	;; shutdown the interrupter job
	Hang 1		;; Give it a millibleem to shutdown
	; Print some stats
	Write "Total interrupts sent by interrupter job: ",^zintsent,!
	Write "Interupts fielded by main process:        ",^zintmaincnt,!
	Write "Interrupts fielded by peer process:       ",^zintpeercnt,!
	Close tcpdev
	Quit

commpeer  ;;;	    The peer process
	Write "Peer startup",!
        Set $Ztrap="Set $Ztrap="""" Set ^peeractive=0 Set ^done=1 Set ^done(""commpeer"")=$Zpos Use $P Zshow ""*"" Halt"
        Set $Zint="Set ^zintpeercnt=^zintpeercnt+1"
	Set notifyinterval=^rancnt\20
	Do peersetup	; Setup listening socket
	Use $P
	Write "Interrupt count at start of reads: ",^zintpeercnt,!
	Use tcpdev
	L ^peeractive	; Keep this till we exit
	; Receive the list of generated random numbers
	Read rands
	; save some status in case of an error
	Set dollardevice=$Device,dollarkey=$Key,dollarzeof=$Zeof
	Set lenrands=$Length(rands,"|")
	If lenrands'=^rancnt Do
	. Set ^error($H,"server")="LTSOCKZINTR-E-FAILED Piece count in random string was "_lenrands_" instead of "_^rancnt
	. Use $P
	. ZShow "*"
	. Write !,"Error: Piece count in random string was ",lenrands," instead of ",^rancnt,!
	. Set ^done=1,^peeractive=0,^done("Piece count read error")=$Zpos
	. Halt

	Use $P
	Write "Random number list received -- starting receive of random length strings",!
	Use tcpdev

	For i=1:1:lenrands Do
	. If ^done Use $P Write "Halting on ^done setting",! Halt
	. Kill expectstr,rcvstr
	. Set readstart=$H
	. Read rcvstr:60
	. If '$T Do
        . . Set ^error($H,"server")="LTSOCKZINTR-E-FAILED Read "_i_" timed out - Read start: "_readstart_"  Read end: "_$H
        . . Use $P Write "Error: Read ",i," timed out - Read start: ",readstart,"  Read end: ",$H,!
	. . If $Data(rcvstr) Write "rcvlen is ",$Length(rcvstr),!
        . . Set ^done=1,^peeractive=0,^done("Read Timeout")=$Zpos
	. . Zshow "*"
        . . Halt
	. ; Check expected length of string
	. Set expectlen=$Piece(rands,"|",i)
	. Set recvlen=$Length(rcvstr)
	. If expectlen'=recvlen Do
        . . Set ^error($H,"server")="LTSOCKZINTR-E-FAILED Read "_i_" is not the expected length - expected "_expectlen_" received "_recvlen
        . . Use $P Write "Error: Read ",i," is not the expected length - expected ",expectlen," received ",recvlen,!
        . . Set ^done=1,^peeractive=0,^done("Read not the expected length")=$Zpos
	. . Zshow "*"
        . . Halt
	. ; Build expected string and make sure we got what we expected
	. Set expectstr=$$stroflen(expectlen)
	. If expectstr'=rcvstr Do
        . . Set ^error($H,"server")="LTSOCKZINTR-E-FAILED Read "_i_" expected and received text do not match"
        . . Use $P Write "Error: Read ",i," expected and received text do not match",!
        . . Set ^done=1,^peeractive=0,^done("Expected and received text do not match")=$Zpos
	. . Zshow "*"
        . . Halt
        . If i#notifyinterval=0 Use $P Write "Read #",i," complete",! Use tcpdev

	; When the loop is complete, close down and notify main we are done.
	Close tcpdev
	Use $P
	Write "Peer all done .. closing down",!
	Set ^peeractive=0
	Quit

	; Setup listen socket we will communicate with..
peersetup	;;;
	Set path=^config("path"),delim=^config("delim")
        Set tcpdev="server$"_$j,timeout=120
        Set openarg="(ZLISTEN="""_path_":LOCAL"""_":attach=""server"")"
        Open tcpdev:@openarg:timeout:"SOCKET"
        Else  Set ^error($H,"server")="LTSOCKZINTR-E-FAILED to open socket at "_$Zpos  Use $P Write "open failed : $zstatus=",$Zstatus,! Set ^done=1,^done("Peer open failed")=$Zpos Halt
        Use tcpdev
        Write /listen(1)
	Set ^peerpid=$j
	Set ^peeractive=1		; signal main we are running
        Write /wait(timeout)
	If ""=$Key do
	. Set ^error($H,"server")="LTSOCKZINTR-E-FAILED to establish connection at "_$Zpos
	. Use $P Write "open failed : $zstatus=",$Zstatus,!
	. Set ^done=1,^done("Peer failed to connect")=$Zpos
	. Halt
        Set key=$Key,childsocket=$Piece(key,"|",2),ip=$p(key,"|",3)
        Use $P
        Write "$key="  zwr key
        Write !,"Server/peer connected : ",!
	Use tcpdev:(delimiter=delim:width=1048576)
        Quit

intrdrv
        ;
        ; Drive the interrupts to the two processes (main and peer). Use $ZSIGPROC so we can exactly control
	; the amount of time between each interrupt (currently randomized). Note that different systems can have
	; different numbers for the SIGUSR1 interrupt used here.
	;

        Set unix=$ZVersion'["VMS"
        Set $Ztrap="Set $Ztrap="""" Set ^drvactive=0 Set ^done=1 Set ^done(""intrdrv"")=$Zpos Zshow ""*"" Halt"
	L +^drvactive
        Set ^drvactive=1
        Hang 2 ; Chill while parent realizes we are running.. It will hang on this lock then we begin..
	L
        Write "Interrupt job beginning for processes ",^mainpid," and ",^peerpid,!

        ; Interrupt until we are requested to shutdown or we reach an outer limit of 100,000 interrupts
        ; which probably means we were orphaned and are just chewing up cpu time.

	; Signal for SIGUSR1: Linux-x86:10 AIX:30, Tru64:30, all others (HPUX, Solaris, VMS) are 16.
	If $ZVersion["x86" Do
	. Set signum=10
	. Set minsnooze=1
	. Set maxsnooze=500
	Else  If $ZVersion["AIX" Do
	. Set signum=30
	. Set minsnooze=200
	. Set maxsnooze=800
	Else  If $ZVersion["OSF1" Do
	. ; Rate set low due to OSF1 connect() call foibles (backgrounds connect giving addr in use error when we restart open)
	. Set signum=30
	. Set minsnooze=2000
	. Set maxsnooze=8000
	Else  If $ZVersion["Solaris" Do
	. Set signum=16
        . Set minsnooze=400
        . Set maxsnooze=1000
	Else  If $ZVersion["HP-PA" Do
        . Set signum=16
        . Set minsnooze=200
        . Set maxsnooze=800
	Else  Do ; Includes VMS
        . Set signum=16
	. ; Issue with VMS is fault in job interrupt implementation that causes process crash (it basically just
	. ; disappears with no log) if interrupts come in too rapidly. Low priority TR exists.
        . Set minsnooze=5000
        . Set maxsnooze=9000
        Write "Interrupt rate chosen - Minimum: ",minsnooze/10000,"  Maximum: ",maxsnooze/10000,"  Signum: ",signum,!

	Set stopnow=0,sigtomain=1,sigincr=2
        For x=1:1:100000 Quit:(('^peeractive)!stopnow)  Do
        . If sigtomain If $ZSigproc(^mainpid,signum) Set sigtomain=0,sigincr=1
        . If $ZSigproc(^peerpid,signum) Set ^done=1,stopnow=1 Quit
        . Set ^zintsent=^zintsent+sigincr
	. Hang ($Random(maxsnooze-minsnooze)+minsnooze)/10000
        Set ^drvactive=0
        Write "Interrupt job for processes ",^mainpid," and ",^peerpid," complete after sending ",^zintsent," interrupts",!
        Quit

	; Construct string from repeated copies of the length of the string. Since the length will probably not
	; be an exact match, add the last few chars on the end if necessary.
stroflen(sendlen)
	New lensendlen,reps,sendtxt
	; Construct string
	Set lensendlen=$Length(sendlen)
	Set reps=sendlen\lensendlen
	If (sendlen\lensendlen)'=(sendlen/lensendlen) Set reps=reps+1
	Set $Piece(sendtxt,sendlen,reps)=""
	Set sendtxt=sendtxt_$Extract(sendlen,1,sendlen-$Length(sendtxt))
	Quit sendtxt
