;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available 	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

server	; background process
	do setPort
	do bgProcStarted("server")
	;
        write "# server: waiting for the client",!
        open "socket":(LISTEN=port_":TCP":delim=$char(13))::"SOCKET"
	do list("client is not connected yet")
	do checkpoint("server",1,"server is started")
	;
	do checkpoint("server",2,"client request sent")
	do read
	do list("client is connected")
	;
	write "close client connection",!
	close "socket":(socket=conn)
	;
	write "close client connection again (and catch the error)",!
	set $etrap="goto already"
	close "socket":(socket=conn)
	write "something is wrong: succesfully closed the connection twice",!
	halt
already	;
        set error=$piece($zstatus,",",3)
        use $principal
        write "error caught: ",error,!
	;
	do checkpoint("server",3,"connection is closed by server")
	do checkpoint("server",4,"message sent by client on closed connection")
	do list("client connection closed, index-1 should be empty")
	quit

read	; read client's message and display it
	;
	new r
	use "socket"
        write /wait(2,"read")
        set conn=$piece($key,"|",2)
        use "socket":(socket=conn)
        read r#1:(1)
	use $principal
	write "read from the client: [",r,"]",!
	quit  ; returns `conn`

list(msg)    ; list active sockets using $ZSOCKET()
	;
	new i,r,token
	use $principal
	write "socket list - ",msg,":",!
	for i=0:1:2 do
	.set token="state"
	.set r=$zsocket("socket",token,i)
        .write "    index-",i,": [",r,"]",!
        quit

client	; foreground process
	;
        do setPort
	do checkpoint("client",1,"server is started")
        write "# client: connect to the server",!
        open "socket":(CONNECT="127.0.0.1:"_port_":TCP":delim=$char(13))::"SOCKET"
	write "# client: send a 'c' character",!
	use "socket" write "c",!
	do checkpoint("client",2,"client request sent")
	do checkpoint("client",3,"connection is closed by server")
	write "# client: send 'x' character on closed connection",!
	use "socket" write /wait write "x",!
	do checkpoint("client",4,"message sent by client on closed connection")
	use $principal
	;
	use $principal
	write "# client: waiting for the server to finish",!
        do waitForBgProc
        quit

bgProcStarted(index) ; acquire the lock indicates that background process is running
	;
        do setPort
        lock +(^bgprocrun(port,index))
        quit

waitForBgProc ; wait for the lock indicates background process is running
	;
        do setPort
        lock +(^bgprocrun(port))
        lock -(^bgprocrun(port))
        quit

setPort ; set port value specified by CLI arg or display error
        ;
        if $data(port) quit
        set port=$zcmdline
        if $length(port) quit  ; returns `port`
        use $principal
        write "TEST-E-ERROR: internal error: no port arg is provided by the shell script",!
        halt

checkpoint(actor,id,comment) ; checkpoint mechanism for server and client to wait each other
	;
        set comment=$get(comment,"")
        if comment'="" set comment=" - "_comment
        use $principal
        write "# ",actor," entered checkpoint ",id,comment,!
        lock +(^checkpoint(port))
        set ^checkpoint(port,id)=1+$get(^checkpoint(port,id),0)
        lock -(^checkpoint(port))
        for  quit:^checkpoint(port,id)=2  hang 0.1
        write "# ",actor," left checkpoint ",id,comment,!
        quit
