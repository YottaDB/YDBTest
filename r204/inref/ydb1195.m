;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb1195 ;
	set s="socket"
	set startport=$piece($zcmdline," ",1)
	set ^state=0
	write "# Start 2 child jobs that write 1 line each to a TCP socket",!
	for i=1:1:2 set port=startport+i open s:(listen=port_":TCP")::"socket" job child(port)
	write "# Wait for each job to start and open a TCP socket on port "_startport,!
	for  quit:^state=2  hang 0.01
	write "# Run write /wait(1) and read commands 7 times in a loop and display the output of $key for each iteration. Wait specifically until $key="""". This takes 5 iterations in M mode and 7 in UTF-8 mode.",!
	write "# Expect all 7 iterations to complete and all data written by child jobs to be output.",!
	write "# Previously, the test would hang in Iteration 3.",!
	for i=1:1:7 do
	. write "------------- Iteration ",i," --------------",!
	. set:i=3 ^state=3
	. write "# Run [use s write /wait(1) set key=$key]",!
	. use s write /wait(1) set key=$key
	. write "# Run [use $p zwrite key]",!
	. use $p zwrite key
	. if key'="" do
	. . set handle=$piece(key,"|",2)
	. . use s:(socket=handle)
	. . read data
	. . set device=$device
	. . close:device["Connection reset" s:socket=handle
	. . use $p
	. . write "# Run [zwrite data,device,handle]",!
	. . zwrite data,device,handle
	quit

child(port) ;
	set s="socket"
	open s:(CONNECT="[127.0.0.1]:"_port_":TCP":ioerror="trap")::"SOCKET"
	if $incr(^state)
	use s
	write "Client pid = "_$j,!
	for  quit:^state=3  hang 0.01
	quit
