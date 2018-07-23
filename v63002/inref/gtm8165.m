;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

writeslashwait
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	. set sock="gtm8165.socket"
	. open sock:(LISTEN="gtm8165sock.socket:LOCAL":attach="handle")::"SOCKET"
	. use sock
	. if $ZTRNLNM("timeout")  write /wait(.999)
	. if '$ZTRNLNM("timeout")  write /wait
	. close sock
	if $trestart<=2  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	use $p
	write "Post Transaction DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	quit

writeslashpass
	set ^stop=0
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
        . set sock="gtm8165pass.socket"
        . open sock:(LISTEN="passsocket1:LOCAL":attach="passhandle1")::"SOCKET"
        . use sock:(detach="passhandle1")
	. open sock:(LISTEN="passsocket2:LOCAL":attach="passhandle2")::"SOCKET"
	. use sock
	. job passchild
	. write /wait
	. if $ZTRNLNM("timeout")  write /pass(,.999,"passhandle1")
	. if '$ZTRNLNM("timeout")  write /pass(,,"passhandle1")
        . close sock
	if $trestart<=2  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	set ^stop=1
	use $p
        write "Post Transaction DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	quit

passchild
	set pid2="writeslashpass.txt"
	open pid2
	use pid2
	write $job
	close pid2
	set sock="socket"
	open sock:(CONNECT="passsocket2:LOCAL")::"SOCKET"
	use sock
	use $p
	for  quit:^stop
	quit

writeslashaccept
	set ^stop=0
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
        . set sock="gtm8165pass.socket"
        . open sock:(LISTEN="acceptsocket1:LOCAL":attach="accepthandle1")::"SOCKET"
        . use sock:(detach="accepthandle1")
	. open sock:(LISTEN="acceptsocket2:LOCAL":attach="accepthandle2")::"SOCKET"
	. use sock
	. job acceptchild
	. write /wait
	. if $ZTRNLNM("timeout")  write /accept(.handle,,.999,)
	. if '$ZTRNLNM("timeout")  write /accept(.handle,,,)
        . close sock
	if $trestart<=2  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	set ^stop=1
	use $p
        write "Post Transaction DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	quit

acceptchild
	set pid2="writeslashaccept.txt"
	open pid2
	use pid2
	write $job
	close pid2
	set sock="socket"
	open sock:(CONNECT="acceptsocket2:LOCAL")::"SOCKET"
	use sock
	use $p
	for  quit:^stop
	quit


writeslashtls
	set ^stop=0
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	. set sock="gtm8165.socket"
	. open sock:(LISTEN="3000:TCP":attach="handle")::"SOCKET"
	. use sock
	. job tlschild
	. write /wait
	. if $ZTRNLNM("timeout")  write /tls("client",.999)
	. if '$ZTRNLNM("timeout")  write /tls("client")
	. close sock
	if $trestart<=2  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	set ^stop=1
	use $p
	write "Post Transaction DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	quit

tlschild
	set pid2="writeslashtls.txt"
	open pid2
	use pid2
	write $job
	close pid2
	set sock="socket"
	open sock:(CONNECT="localhost:3000:TCP":attach="handle")::"SOCKET"
	use sock
	for  quit:^stop
	quit
