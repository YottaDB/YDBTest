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

opentimeout
	set s="socket"
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = xxxx as expected",!
	. open:($ZTRNLNM("timeout")) s:(connect="notreal.txt:LOCAL"):.999:"SOCKET"
	. open:('$ZTRNLNM("timeout")) s:(connect="notreal.txt:LOCAL")::"SOCKET"
	if $trestart<=2  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	use $p
	write "Post Transaction DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	quit

locktimeout
	set ^start=0
	set ^stop=0
	job lockchild
	for  quit:^start  hang .1
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = xxxx as expected",!
	. lock:($ZTRNLNM("timeout")) ^A(1):.999
	. lock:('$ZTRNLNM("timeout")) ^A(1)
	. set ^stop=1
	if $trestart<=2  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	use $p
	write "Post Transaction DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	zsystem "$gtm_tst/com/wait_for_proc_to_die.csh "_$zjob
	quit

lockchild
	set pid="locktimeout.txt"
	open pid
	use pid
	write $job
	close pid
	lock ^A
	set ^start=1
	for  quit:^stop  hang .1
	lock
	quit

writeslashwait
	set sock="gtm8165.socket"
	open sock:(LISTEN="gtm8165sock.socket:LOCAL":attach="handle")::"SOCKET"
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = xxxx as expected",!
	. use sock
	. write:($ZTRNLNM("timeout")) /wait(.999)
	. write:('$ZTRNLNM("timeout")) /wait
	. close sock
	if $trestart<=2  do ;cannot use else because this commit changes the value of $test, similar usages throughout the test
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	use $p
	write "Post Transaction DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	quit

writeslashpass
	set ^stop=0
        set sock="gtm8165pass.socket"
        open sock:(LISTEN="passsocket1:LOCAL":attach="passhandle1")::"SOCKET"
        use sock:(detach="passhandle1")
	open sock:(LISTEN="passsocket2:LOCAL":attach="passhandle2")::"SOCKET"
	job passchild
	use sock
	write /wait
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. use $p
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = xxxx as expected",!
	. use sock
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
	zsystem "$gtm_tst/com/wait_for_proc_to_die.csh "_$zjob
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
	for  hang .1  quit:^stop
	quit

writeslashaccept
	set ^stop=0
        set sock="gtm8165pass.socket"
	open sock:(LISTEN="acceptsocket:LOCAL":attach="accepthandle")::"SOCKET"
	use sock
	job acceptchild
	write /wait
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. use $p
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = xxxx as expected",!
	. use sock
	. write:($ZTRNLNM("timeout")) /accept(.handle,,.999,)
	. write:('$ZTRNLNM("timeout")) /accept(.handle,,,)
        . close sock
	if $trestart<=2  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	set ^stop=1
	use $p
        write "Post Transaction DB Crit of DEFAULT owned by pid = ",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	zsystem "$gtm_tst/com/wait_for_proc_to_die.csh "_$zjob
	quit

acceptchild
	set pid2="writeslashaccept.txt"
	open pid2
	use pid2
	write $job
	close pid2
	set sock="socket"
	open sock:(CONNECT="acceptsocket:LOCAL")::"SOCKET"
	use sock
	use $p
	for  hang .1  quit:^stop
	quit


writeslashtls
	set ^stop=0
	set sock="gtm8165.socket"
	open sock:(LISTEN="3000:TCP":attach="handle")::"SOCKET"
	use sock
	job tlschild
	write /wait
	tstart ():(serial:transaction="BA")
	if $trestart>2  do
	. use $p
	. write:($job=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT")) "DB Crit of DEFAULT owned by pid = xxxx as expected",!
	. use sock
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
	zsystem "$gtm_tst/com/wait_for_proc_to_die.csh "_$zjob
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
