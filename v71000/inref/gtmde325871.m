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
gtcmfdlimit ;
	for i=1:1:1021  do
	. set filename="file"_i
	. open filename:newversion
	set ^x=1
	quit

server ;
	set port=$piece($zcmdline," ",1)
	set s="server"
	write "# Server waiting for client on port "_port,!
	open s:(LISTEN=port_":TCP":delim=$char(13))::"SOCKET"
	use s write /wait
	write "CONNECTED",!
	close s
	quit

client ;
	for i=1:1:1022 open "file"_i:newversion
	set port=$piece($zcmdline," ",1)
	set s="client"
	open s:(CONNECT="127.0.0.1:"_port_":TCP")::"SOCKET"
	use s:(DELIMITER=$C(13))
	read x
	close s
	use $p
	write x
	quit
