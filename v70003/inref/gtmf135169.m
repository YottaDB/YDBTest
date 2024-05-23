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

startup(eh) ; common startup: parse args, init backgroud/foreground lock
	; eh: common error handling (default: 1)
	;
	set eh=$get(eh,1)
	if eh do
	.set shoulderror=-1
	.set $ztrap="goto error"
	;
	set port=$piece($zcmdline," ",1)
	set case=$piece($zcmdline," ",2)
	set procid=$piece($zcmdline," ",3)
	set runmode=$piece($zcmdline," ",4)
	;
	if runmode'="-" lock +(^bgprocrun(port,procid))
	quit

error	; common error handler
	;
	use $principal
	if shoulderror=0 write " test FAILED -"
	if shoulderror=1 write " test passed -"
	write " error: ",$piece($zstatus,",",3,5),!
	do chkabrt
	do cleanup
	halt

cleanup	; common cleanup: wait background processes
	;
	if runmode="fg" do
	.do sig
	.write "waiting for background processes to finish",!
	.lock +(^bgprocrun(port))
	.lock -(^bgprocrun(port))
	;
	quit

sig	; print signature (without line ending LF)
	;
	new rbs
	set rbs=""
	set readback=$get(readback,"")
	if readback="indv" set rbs="-indv"
	if readback="opts" set rbs="-opts"
	;
	use $principal
	write "# ",case,rbs
	if (procid'="-")&(procid'="server") write "/",procid
	write ": "
	quit

isnotdupe ; entry point: checks if a test case should run, not a duplication
	;
	set options=$piece($zcmdline," ",1)
	set command=$piece($zcmdline," ",2)
	;
	set result=1
	if command="OPEN" do
	.set result=0
	.for index=1:1 set item=$piece(options,";",index) quit:item=""  do
	..if $piece(item,":",1)="0" set result=1
	..if $piece(item,":",2)="" set result=1
	;
	write result,!
	quit

k1	; entry point for KEEPALIVE=0 test, OPEN with TRAP
	;
	do startup(1)
	do sig
	set shoulderror=1
	write $piece($text(k1t)," ",2,99),!
k1t	open "socket":(listen=port_":TCP":ioerror="TRAP":options="KEEPINTVL=0")::"SOCKET"
	do kner
	quit

k2	; entry point for KEEPALIVE=0 test, OPEN with NOTRAP
	;
	do startup(1)
	do sig
	set shoulderror=1
	write $piece($text(k2t)," ",2,99),!
k2t	open "socket":(listen=port_":TCP":ioerror="NOTRAP":options="KEEPINTVL=0")::"SOCKET"
	do kner
	quit

k3	; entry point for KEEPALIVE=0 test, USE with TRAP
	;
	do startup(1)
	do sig
	set shoulderror=1
	write $piece($text(k3t)," ",2,99),!
k3t	open "socket":(listen=port_":TCP":ioerror="TRAP")::"SOCKET" use "socket":(options="KEEPINTVL=0")
	do kner
	quit

k4	; entry point for KEEPALIVE=0 test, USE with NOTRAP
	;
	do startup(0)
	do sig
	set shoulderror=1
	write $piece($text(k4t)," ",2,99),!
k4t	open "socket":(listen=port_":TCP":ioerror="NOTRAP")::"SOCKET" use "socket":(options="KEEPINTVL=0")
	do kdev
	quit

kner	; for KEEPALIVE=0 tests, no error: fail
	;
	use $principal
	write " no error, test failed",!
	quit
	;
kdev	; Open leaves $TEST=1, but $device contains the error
	;
	set d=$device
	use $principal
	;
	if d="" write " $DEVICE is empty, test failed",!
	else  write " test passed - $DEVICE error: ",$piece(d,",",2),!
	quit

argtest	; entry point: background process for testing arg errors
	;
	do startup
	set option=$piece($zcmdline," ",5)
	set command=$piece($zcmdline," ",6)
	set mistake=$piece($zcmdline," ",7)
	;
	do atprep
	do atcaption
	if command="OPEN" do atopen
	if command="USE" do atuse
	do atres
	quit
	;
atprep	; prepare arg test based on test parameters (CLI args):
	; - assemble `optargs`, the effective test options: OPTIONS=optargs
	; - set `shoulderror` variable, which tells if it's OK to produce error
	;
	set effopts=option
	set shoulderror=1
	;
	; by default, the test case should produce some error
	; when the `mistake` arg is "NONE": shouldn't produce error
	; except for "KEEPINTVL=0": invalid value, report error
	if mistake="NONE" set shoulderror=0
	;
	; the option value can go wrong these 4 ways
	if mistake="MISSING" set effopts=$piece(option,"=",1)
	if mistake="INVALID" set $piece(effopts,"=",2)=",,"
	if mistake="MULTI" set effopts=option_option
	if mistake="OVERFLOW" do
	.set longnum=""
	.for i=1:1:25 set longnum=longnum_(i#10)
	.set $piece(effopts,"=",2)=longnum
	;
	quit
	;
atcaption ; print caption for argtest
	;
	do sig
	write "command=""",command,""""
	write ", mistake=""",mistake,""""
	write ", options=""",effopts,""""
	if 'shoulderror write " - expecting NO error"
	write !
	quit
	;
atopen	; OPEN test for argtest
	;
	open "socket":(listen=port_":TCP":delim=$char(13):options=effopts)::"SOCKET"
	do stsrsck
	quit
	;
atuse	; USE test for argtest
	;
	open "socket":(listen=port_":TCP":delim=$char(13))::"SOCKET"
	do stsrsck
	use "socket":(options=effopts)
	quit
	;
atres	; print result for argtest
	;
	use $principal
	write " test "
	if shoulderror write "FAILED"
	if 'shoulderror write "passed"
	write ", no error",!
	do cleanup
	quit

client	; entry point: auxiliary program for write-readback tests (clients)
	;
	do startup
	do sig
	write "started",!
	;
	do checkpoint(1,"server is started")
	do sig
	write "connecting to server",!
	open "socket":(CONNECT="127.0.0.1:"_port_":TCP":delim=$char(13))::"SOCKET"
	do checkpoint(2,"client is connected")
	;
	do cleanup
	do sig
	write "finished",!
	quit

wrtest	; entry point: write-readback test main program (server)
	;
	do startup
	set options=$piece($zcmdline," ",5)
	set command=$piece($zcmdline," ",6)
	set readback=$piece($zcmdline," ",7)
	do sig
	write "starting test case"
	write ", options=""",options,""""
	write ", command=""",command,""""
	write ", readback=""",readback,"""",!
	;
	do wrpo ; parse options
	do wropen ; open socket
	;
	do checkpoint(1,"server started")
	do recvconns
	do checkpoint(2,"clients attached")
	;
	do wrso ; set options
	if 'd do
	.if readback="indv" do
	..do prsoi ; print options, using individual ZSOCKET(sock,<option>,index)
	.if readback="opts" do
	..do prsow ; print warnings for grouped "OPTIONS"
	..do prsoo ; print options, using grouped ZSOCKET(sock,"OPTIONS",index)
	;
	do cleanup
	quit
	;
wrpo	; write-readback test: parse options
	;
	new i1,r1,optsi,optv,op,opi,opv
	for i1=1:1 set r1=$piece(options,";",i1) quit:r1=""  do
	.set optsi=$piece(r1,":",1),optsv=$piece(r1,":",2)
	.if optsv="" set optsi=0,optsv=$piece(r1,":",1)
	.for i2=1:1 set op=$piece(optsv,",",i2) quit:op=""  do
	..set opi=$piece(op,"=",1)
	..set opv=$piece(op,"=",2)
	..set topi="value"
	..if opi="ZIBFSIZE" do  quit
	...set opts("zibfsize",optsi)=opv
	...set opts("token",opi)=""
	..set opts("value",optsi,opi)=opv
	..set opts("token",opi)=""
	..set value=$get(opts("options",optsi),"")
	..if value'="" set value=value_","
	..set opts("options",optsi)=value_opi_"="_opv
	quit
	;
wropen	; write-readback test: open socket, optionally with options
	;
	new openopts,openzibf,lis
	set openopts="",openzibf=""
	if command="OPEN" do
	.set openopts=$get(opts("options",0),"")
	.set openzibf=$get(opts("zibfsize",0),"")
	;
	do sig
	set lis="listening, set options with OPEN: "
	;
	if (openopts'="")&(openzibf'="") do  quit
	.write lis,"ZIBFSIZE=""",openzibf,""", OPTIONS=""",openopts,"""",!
	.open "socket":(listen=port_":TCP":delim=$char(13):zibfsize=openzbif:options=openopts)::"SOCKET"
	.do stsrsck
	;
	if openopts'="" do  quit
	.write lis,"OPTIONS=""",openopts,"""",!
	.open "socket":(listen=port_":TCP":delim=$char(13):options=openopts)::"SOCKET"
	.do stsrsck
	;
	if openzibf'="" do  quit
	.write lis,"ZIBFSIZE=""",openzibf,"""",!
	.open "socket":(listen=port_":TCP":delim=$char(13):zibfsize=openzbif)::"SOCKET"
	.do stsrsck
	;
	write "listening, no OPEN options set",!
	open "socket":(listen=port_":TCP":delim=$char(13))::"SOCKET"
	do stsrsck
	quit
	;
wrso	; write-readback test: set options
	;
	if command="OPEN" for i=1:1:2 do setopts(i)
	if command="USE" for i=0:1:2 do setopts(i)
	quit
	;
setopts(index) ; set options with USE
	;
	set d=""
	new useopts,usezibf
	set useopts=$get(opts("options",index),"")
	set usezibf=$get(opts("zibfsize",index),"")
	use "socket":(socket=conns(index))
	;
	if command="OPEN"&(index=0) do  quit
	.use $principal
	.if useopts'="" write " skip setting OPTIONS with USE: index=""",index,"""",!
	.if usezibf='"" write " skip setting ZIBFSIZE with USE: index=""",index,"""",!
	.use "socket":(OPTIONS=useopts:ZIBFSIZE=usezibf)
	.do setopte
	;
	if useopts'="" do
	.use $principal
	.write " set OPTIONS with USE: index=""",index,""", value=""",useopts,"""",!
	.use "socket":(OPTIONS=useopts)
	.do setopte
	;
	if usezibf'="" do
	.use $principal
	.write " set ZIBFSIZE with USE: index=""",index,""", value=""",usezibf,"""",!
	.use "socket":(ZIBFSIZE=usezibf)
	.do setopte
	;
	quit
	;
setopte	; setopts() error handling
	;
	set d=$device
	if d="" quit
	;
	use $principal
	write " error during setting option: ",$piece(d,",",2),!
	quit
	;
prsoi	; print options, using individual option names
	new index,token,query
	do sig
	write "get options using individual option names",!
	;
	set token=""
	for  set token=$order(opts("token",token)) quit:token=""  do
	.for index=0:1:2 do
	..set query=0
	..if command="OPEN" set query=1
	..if $data(opts("value",index,token)) set query=1
	..if query do priopts(token,index)
	;
	quit
	;
prsow	; print options warnings for "OPTIONS"
	new index,kiwarn,kiwsum
	do sig
	write "get options using ""OPTIONS""",!
	;
	if $data(opts("zibfsize")) do
	.write "# notice: OPTIONS does not report ZIBFSIZE/SO_RCVBUF",!
	;
	set kiwsum=0
	for index=0:1:2 do
	.set kiwarn=0
	.if $get(opts("value",index,"KEEPALIVE"),-1)=0 set kiwarn=1
	.if $get(opts("value",index,"KEEPIDLE"),-1)<1 set kiwarn=0
	.set kiwsum=kiwarn+kiwsum
	if kiwsum>0 do
	.write "# notice: when KEEPALIVE is zero, OPTIONS does not report KEEPIDLE",!
	;
	quit
	;
prsoo	; print options, using "OPTIONS" instead of names
	;
	new index
	for index=0:1:2 do priopts("OPTIONS",index)
	quit
	;
priopts(token,index) ; print option
	;
	new zso,sysvalue,usrvalue
	use $principal
	set zso=$zsocket("socket",token,index)
	;
	if token'="OPTIONS" do  ; mask out sysvalue
	.if token="KEEPALIVE" quit  ; don't mask out, it has stable sysvalue
	.set sysvalue=$piece(zso,";",2)
	.if sysvalue'="" do
	..if sysvalue<0 set sv="[sysvalue<0:masked]"
	..if sysvalue=0 set sv="0"
	..if sysvalue>0 set sv="[sysvalue>0:masked]"
	..set $piece(zso,";",2)=sv
	;
	if token'="OPTIONS" do  ; mask out usrvalue if differs from the value set
	.set usrvalue=$piece(zso,";",1)
	.if token'="ZIBFSIZE" do
	..set origvalue=$get(opts("value",index,token),"")
	..if origvalue=""&(command="OPEN") set origvalue=$get(opts("value",0,token))
	..if origvalue="" set origvalue="n.a."
	.if token="ZIBFSIZE" set origvalue=$get(opts("zibfsize",index),"n.a.")
	.if usrvalue'=origvalue do
	..if usrvalue<0 set uv="[usrvalue<0:masked]"
	..if usrvalue=0 set uv="0"
	..if usrvalue>0 set uv="[usrvalue>0:masked] "_usrvalue
	..set $piece(zso,";",1)=uv
	;
	use $principal
	write " get option with $ZSOCKET(s,""",token,""",",index,"): """,zso,"""",!
	;
	quit

stsrsck	; set server socket
	;
	kill conns
	set conns(0)=$zsocket("socket","sockethandle",0)
	quit

recvconns ; receive connections
	;
	new index
	for index=1:1:2 do
        .use "socket"
        .write /wait(1,"read")
        .set conns(index)=$piece($key,"|",2)
        .use $principal
        .write " server received incoming connection, index=",index,!
	quit

checkpoint(id,comment) ; checkpoint mechanism for processes to wait for each other
	; Number of processes must be set manually.
	; Example: 1 server + 2 clients => 3
	new procnum set procnum=3
	;
	; Checkpoint messages are muted: there isn't any read/write operation in
	; these tests, so they couldn't hang which should be debugged. Anyway,
	; if `debug` is set to 1, synchronization messages will be printed.
	new debug set debug=0
	;
	new comment
	if debug do
	.set comment=$get(comment,"")
	.if comment'="" set comment=" - "_comment
	.do sig
	.write "entered checkpoint ",id,comment,!
	;
	lock +(^checkpoint(port))
	set ^checkpoint(port,id)=1+$get(^checkpoint(port,id),0)
	set ^checkpoint(port,"q")=$get(^checkpoint(port,"q"),0)
	lock -(^checkpoint(port))
	;
	for  quit:$get(^checkpoint(port,id),0)=procnum  do
	.if $get(^checkpoint(port,"q"),0) do  halt
	..do sig
	..write "error reported in other process, halting",!
	.hang 0.1
	;
	if debug do
	.do sig
	.write " left checkpoint ",id,comment,!
	;
	quit

chkabrt	; abort all processes
	set ^checkpoint(port,"q")=1
	quit

chkrst	; entry point: heckpoint reset, need to call between tests
	set port=$piece($zcmdline," ",1)
	kill ^checkpoint(port)
	quit

parse	; parse strace output
	;
	set case=$piece($zcmdline," ",2)
	set options=$piece($zcmdline," ",5)
	set file=$piece($zcmdline," ",6)
	set readback=$piece($zcmdline," ",7)
	write "# ",case,": filtered ",file,!
	if options["SNDBUF=" do
	.write "# notice: getsockopt(SO_SNDBUF) value (4th arg)"
	.write " is masked due to the OS rounding mechanism"
	.write " (the value get may differ from the value set)",!
	if readback="opts" do
	.write "# notice: $ZSOCKET(s,""OPTIONS"",i) reports only the"
	.write " value specified by the user, so that's why there"
	.write " are no getsockopt() calls in the strace log",!
	;
	set index=1
	set keepgetso=0
	open file:readonly
	f  use file quit:$zeof  do
	.read line
	.use $principal
	.if line["individual" set keepgetso=1
	.set syscall=$piece(line,"(",1)
	.set found=0
	.if syscall="setsockopt" set found=1
	.if syscall="getsockopt" set found=keepgetso
	.quit:'found
	.set option=$piece(line,",",3)
	.if $extract(option,1)=" " set option=$extract(option,2,999)
	.quit:option="SO_REUSEADDR"
	.quit:option="TCP_NODELAY"
	.set args=$piece(line,"(",2)
	.set lines(index)=line
	.set index=1+index
	close file
	;
	set index=""
	set split=0
	for  set index=$order(lines(index)) quit:index=""  do
	.set line=lines(index)
	.set syscall=$piece(line,"(",1)
	.if syscall="setsockopt" set split=1
	.if split do
	..set line=$$maskarg(line,1)
	..set line=$$maskarg(line,5)
	..set option=$piece(line,",",3)
	..if $extract(option,1)=" " set option=$extract(option,2,999)
	..if (syscall="getsockopt")&(option="SO_SNDBUF") set line=$$maskarg(line,4)
	..write " ",line,!
	;
	quit
	;
maskarg(line,n) ; mask specified arg of a function call
	;
	set right=$piece(line,"(",2)
	set args=$piece(right,")",1)
	set $piece(args,",",n)=$select(n=1:"",1:" ")_"<masked>"
	set $piece(right,")",1)=args
	set $piece(line,"(",2)=right
	quit line
