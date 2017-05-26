;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2007, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c002916client(answer,port)
	; answer local was previously read interactively from the user. This was inhibiting
	; test automation so we pass it as a parameter inside %XCMD command.
	set host="localhost"
	if $ZV'["VMS",$ZV'["HP-PA",$ZV'["Solaris" do
	. set rand=$random(4)
	. if rand=0 set host="localhost"
	. if rand=1 do
	. . if $ZV'["AIX",$ZV'["HP-UX" set host="localhost6"
	. if rand=2 set host="[::1]"
	. if rand=3 set host="127.0.0.1"
	write "starts to connect to ",host,!
	set sock="sock1"
	set timeout=30
	open sock:(connect=host_":"_port_":TCP":delim=$char(13,10):ioerror="TRAP"):timeout:"SOCKET"
	else  do
	. write "The server may not support IPv6. Use IPv4 only",!
	. set host="127.0.0.1"
	. open sock:(connect=host_":"_port_":TCP":delim=$char(13,10):ioerror="TRAP"):timeout:"SOCKET"
	. else  write "Time-out connecting to the server. Test failed. Quit." quit
	write "connected to ",host,":",port,!
	write "local zshow ""D"":",!
	zshow "D"
	write "remote zshow ""D"":",!
	use sock:(ioerror="TRAP":exception="zgoto "_$zlevel_":error")
	; soak up zshow "D" from server
	for i=0:1:10 read a(i) use $p write a(i),! use sock quit:a(i)["lost"
	set dev0=$DEVICE
	use $p
	write !,"testing disconnect during ",answer,!
	use sock
	write answer,!
	set dev1=$DEVICE
	for j=0:1:20 read b(j) set dev=$DEVICE,key=$KEY quit:b(j)["disconnect"
	if answer="read" use sock:delim="/: "
	if answer="read" do
	. hang 1 write "line of input",$char(13,10)
	. set devr=$device,dollarkeyr=$key,zeofr=$zeof,zar=$za
	else  do
	. read line:20
	. set devw=$device,dollarkeyw=$key,zeofw=$zeof,zaw=$za
	close sock
	use $p
	zshow "*"
	quit

error	set errdev=$device,errkey=$key,erreof=$zeof,errza=$za
	use $principal
	write "socket error:",!
	zshow "*"
	quit
