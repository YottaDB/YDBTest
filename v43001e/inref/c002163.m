 set unix=$zv'["VMS"
 set tcpdev="server$"_$j
 set portno=0
 set timeout=120
 set ^serverjobid=$j
 ;w !,"server: waiting for connection",!
 ;o tcpdev:(ZLISTEN=portno_":TCP":attach="server":zbfsize=2048:zibfsize=1024):timeout:"SOCKET"
 open tcpdev:(ZLISTEN=portno_":TCP":attach="server"):timeout:"SOCKET"
 ;s key1=$key
 ; o tcpdev:(ZLISTEN=portno_":TCP":attach="server":delimiter=delim):timeout:"SOCKET"
 use tcpdev 
 set key1=$key
 set ^realport=$p($key,"|",3)
 ;
 ; job off child after switching to principal device
 use $p
 set jmaxwait=0	; do not wait after spawning off child
 do ^job("main^cln2163",1,"""""")
 use tcpdev	; continue to use the tcp device for communication
 ;
 write /listen(1)
 write /wait(timeout)
 set key=$key
 if ""'=key d
  . use tcpdev read x:timeout
  . if '$t use 0 write "Read timed out",!
  . else  use 0 write x,!
 else  use 0 w "Wait for connection timed out",!
 close tcpdev
 ;
 do wait^job	; wait for child to die
 ;
 quit
