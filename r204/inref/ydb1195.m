;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ydb1195 ;
	set s="socket",ports=""
	set ^state=0
	write "# Start 2 child jobs that write 1 line each to a TCP socket",!
	for i=1:1:2  do
	. set port=$piece($zcmdline," ",i)
	. open s:(listen=port_":TCP")::"socket"
	. job child(port)
	. set expect(i)="Client pid = "_$zjob
	. set ports=ports_" "_port
	write "# Wait for each job to start and open a TCP socket on ports"_ports,!
	for  quit:^state=2  hang 0.01
	write "# Run write /wait(1) and read commands in a loop, telling the child jobs to exit in iteration 3, until both",!
	write "# connections are reset by peer and a later write /wait(1) returns with $key="""". The iteration in which each",!
	write "# event occurs depends on how fast the child jobs exit, so the loop records the events and the checks follow it.",!
	write "# Previously, the third write /wait(1) would hang, using 100% of a CPU.",!
	set maxiter=60,(nconnect,nreset,done)=0
	for i=1:1:maxiter do  quit:done
	. set:i=3 ^state=3
	. use s write /wait(1) set key=$key
	. use $p
	. if key="" set done=(2=nreset) quit
	. set handle=$piece(key,"|",2)
	. set:"CONNECT"=$piece(key,"|",1) nconnect=nconnect+1
	. use s:(socket=handle)
	. read data
	. set device=$device
	. close:device["Connection reset" s:socket=handle
	. use $p
	. set data(handle)=$get(data(handle))_data
	. set:device["Connection reset" nreset=nreset+1
	write "# Expect write /wait(1) to return with $key="""" after both connections are reset, within ",maxiter," iterations",!
	write $select(done:"$key="""" after both connections were reset : as expected",1:"WRONG : nreset="_nreset_" after "_maxiter_" iterations, expected 2 and then $key="""""),!
	write "# Expect 2 CONNECT events",!
	write $select(2=nconnect:"2 CONNECT events : as expected",1:"WRONG : "_nconnect_" CONNECT events, expected 2"),!
	write "# Expect the line each child job wrote to be read in full from one of the connections",!
	set handle="" for  set handle=$order(data(handle)) quit:""=handle  set got(data(handle))=""
	for i=1:1:2 write $select($data(got(expect(i))):"Line from child job "_i_" : as expected",1:"WRONG : line ["_expect(i)_"] from child job "_i_" not read"),!
	quit

child(port) ;
	set s="socket"
	open s:(CONNECT="[127.0.0.1]:"_port_":TCP":ioerror="trap")::"SOCKET"
	if $incr(^state)
	use s
	write "Client pid = "_$j,!
	for  quit:^state=3  hang 0.01
	quit
