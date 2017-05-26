;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Server which works with a socket on $P, as for inetd
server
	set key=$key,handle=$piece(key,"|",2)
	set timeout=30
	set $etrap="set err=""server_""_$job_"".err""  open err  use err  zshow ""*""  halt"
	use $io:ioerror="TRAP"
	set zhandle=$zsocket("","sockethandle",0)
	if zhandle'=handle do
	. set err="server_"_$job_".err"  open err use err
	. write "TEST-E-zsocket, handle = ",$zwrite(handle)," zhandle = ",$zwrite(zhandle),!  zshow "*"  halt
	set zhow=$zsocket("","howcreated",0)
	if zhow'="PRINCIPAL" do
	. set err="server_"_$job_".err"  open err use err
	. write "TEST-E-zsocket, created expected PRINCIPAL, got = ",$zwrite(zhow),!  zshow "*"  halt
	use $P:DELIMITER=$c(10)
	write "What is your favorite song?",!
	read line:timeout
	else   set err="server_"_$job_".err"  open err  use err  write "TEST-E-timeout, server read timed out",!  zshow "*"  halt
	set f="answer.out"
	open f  use f  write line  close f  use $p
        zshow "D"
	do
	. use $P:DETACH=handle
	. ; Test I/O against socket $P with no sockets - should work like null device
	. use $P  read nothing  zwrite nothing  write #,"waste",#,"lots",#,"of",#,"null",#,"paper",#  write "one line",!
	. read nothing#1  use $P:delimiter="q"  write /wait(1)
	. set s="junksocketdev"
	. open s:::"SOCKET"
	. use s:ATTACH=handle
	. close s:SOCKET=handle
	. ; Test I/O against non-$P socket with no sockets - should raise NOSOCKETINDEVs
	. set xfailcnt=0,traplog="server_"_$job_"_nosock.out",nosocketrap="set pos=$zposition  goto nosockhandler"
	. open traplog:APPEND
	. use s
	. set $etrap=nosocketrap
	. read:xfailcnt<1 nothing  do:xfailcnt<1 missingtrap($zposition)
	. zwrite:xfailcnt<2 nothing  do:xfailcnt<2 missingtrap($zposition)
	. write:xfailcnt<3 #,"waste",#,"lots",#,"of",#,"null",#,"paper",#  do:xfailcnt<3 missingtrap($zposition)
	. write:xfailcnt<4 "one line",!  do:xfailcnt<4 missingtrap($zposition)
	. read:xfailcnt<5 nothing#1  do:xfailcnt<5 missingtrap($zposition)
	. use:xfailcnt<6 s:delimiter="q"  do:xfailcnt<6 missingtrap($zposition)
	. write /wait(1)	; should be fine, since a wait on an empty socket device just returns
	. close traplog
	halt

nosockhandler
	new savio
	set xfailcnt=xfailcnt+1,savio=$io,$etrap=""
	use traplog
	if $piece($piece($zstatus,",",3),"-",3)'="NOSOCKETINDEV"  write "TEST-E-Got unexpected error: "_$zstatus,!
	else  write "Got NOSOCKETINDEV as expected: "_pos,!
	use savio
	set $ecode="",$etrap=nosocketrap
	goto @pos

missingtrap(pos)
	new savio
	set xfailcnt=xfailcnt+1,$etrap="",savio=$io
	use traplog
	write "TEST-E-Missing expected error at "_pos,!
	use savio
	set $etrap=nosocketrap
	quit

; Simple TCP client for the above server
tclient(host,portno)
	set s="mysocket",timeout=30
	set $etrap="set err=""client_""_$job_"".err""  open err  use err  zshow ""*""  halt"
	open s:(connect=host_":"_portno_":TCP":ioerror="TRAP"):timeout:"SOCKET"
	else  write "TEST-E-timeout, tclient open timed out",!  halt
	do client(s,timeout)
	halt

; Simple LOCAL client for the above server
lclient(sf)
	set s="mysocket",timeout=30
	set $etrap="set err=""client_""_$job_"".err""  open err  use err  zshow ""*""  halt"
	open s:(connect=sf_":LOCAL":ioerror="TRAP"):timeout:"SOCKET"
	else  write "TEST-E-timeout, lclient open timed out",!  halt
	do client(s,timeout)
	halt

client(s,timeout)
	use s
	use s:DELIMITER=$c(10)
	read line:timeout
	else  use $p  write "TEST-E-timeout, client read timed out",!  halt
	set f="question.out"
	open f  use f  write line  close f  use s
	write "My bonnie lies over the ocean.",!
	for  quit:$zeof  read line:timeout quit:line=""  use $p write line use s
	use $p
	close s
	halt

; Implement a one-shot inetd-like socket listener which passes the accepted socket as $P to the given routine
nanoinetd(portno,routine,outspec)
	write "In nanoinetd("_$zwrite(portno)_","_$zwrite(routine)_")",!
	set $etrap="use $p  zshow ""*""  halt"
	set s="server",timeout=60
	open s:(LISTEN=portno_":TCP":ioerror="TRAP"):timeout:"SOCKET"
	else  write "TEST-E-timeout, nanoinetd server open timed out",!  halt
	use s
	do:$data(outspec) nanowork(routine,timeout,outspec)
	do:'$data(outspec) nanowork(routine,timeout)
	halt

; Implement a one-shot inetd-like LOCAL socket listener which passes the accepted socket as $P to the given routine
nanolocd(sf,routine)
	write "In nanolocd("_$zwrite(sf)_","_$zwrite(routine)_")",!
	set $etrap="use $p  zshow ""*""  halt"
	set s="server",timeout=60
	open s:(LISTEN=sf_":LOCAL":ioerror="TRAP"):timeout:"SOCKET"
	else  write "TEST-E-timeout, nanolocd server open timed out",!  halt
	use s
	do nanowork(routine,timeout)
	halt

nanowork(routine,timeout,outspec)
	zshow "D":zs  set f="nanowork_zshow_"_$job_".out",io=$io  open f  use f  zwrite zs  close f  use io
	write /wait(timeout)
	else  use $p  write "TEST-E-timeout, server connection wait timed out",!  zshow "*"  halt
	set key=$key,handle=$piece(key,"|",2)
	use $io:DETACH=handle
	set inspec="SOCKET:"_handle
	set:'$data(outspec) outspec="SOCKET:"_handle
	job @(routine_":(INPUT="""_inspec_""":OUTPUT="""_outspec_""")")
	use $p
	set cnt=0
	do waitforproctodie^waitforproctodie($zjob,timeout)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test combinations of socket passing on INPUT/OUTPUT/ERROR

; server which receives INPUT/OUTPUT/ERROR sockets, checks lsof/zshow "D", and verifies read/write
fdworker(opts)
	use $p:(DELIMITER=$c(10):ioerror="TRAP")
	set timeout=30
	set $etrap="set err=""fdworker_""_$job_"".err""  open err  use err  zshow ""*""  halt"
	set key=$KEY,handle=$piece(key,"|",2),device=$DEVICE
	do:(opts["i")&((key="")!(device=""))
	. zshow "*":zs
	. set err="fdworker_"_opts_"_nodollar.err"
	. open err  use err  write "TEST-E-nodollar, $KEY or $DEVICE is empty",!  zwrite zs  close err
	do:(opts["i")&(handle="")
	. zshow "*":zs
	. set err="fdworker_"_opts_"_nohandle.err"
	. open err  use err  write "TEST-E-nohandle, $KEY does not contain a handle",!  zwrite zs  close err
	zsystem "lsof -p "_$job_" >& fdworker_"_opts_"_lsof.out"
	set f="fdworker_"_opts_"_zshowd.out"  open f  use f  zshow "D"  close f
	use $p
	read line:timeout
	else  do
	. set f="fdworker_"_opts_"_timeout.err"
	. open f  use f  write "TEST-E-timeout, fdworker read timed out",!  zshow "*"
	. halt
	set f="fdworker_"_opts_"_read.out"  open f  use f  write "worker read: ",line,!  close f  use $p
	use $p  write opts_": "_$zwrite($get(line)),!
	halt

; client which connects to server and verifies read/write
tfdclient(host,portno,opts)
	set s="mysocket",timeout=30
	set $etrap="use $p  zshow ""*""  halt"
	open s::timeout:"SOCKET"
	else  use $p  write "TEST-E-timeout, tfdclient open timed out",!  zshow "*"  halt
	use s:(connect=host_":"_portno_":TCP":delimiter=$c(10):ioerror="TRAP")
	set key=$key
	if key=""  use $p  write "TEST-E-error, tfdclient connect failed",!  zshow "*"  halt
	set f="fdclient_t"_opts_"_zshowd.out"  open f  use f  zwrite key  zshow "D"  close f
	do fdclientcom(s,opts,timeout)
	halt

lfdclient(sf,opts)
	set s="mysocket",timeout=30
	set $etrap="use $p  zshow ""*""  halt"
	open s::timeout:"SOCKET"
	else  use $p  write "TEST-E-timeout, lfdclient open timed out",!  zshow "*"  halt
	use s:(connect=sf_":LOCAL":delimiter=$c(10):ioerror="TRAP")
	set key=$key
	if key=""  use $p  write "TEST-E-error, lfdclient connect failed",!  zshow "*"  halt
	set f="fdclient_l"_opts_"_zshowd.out"  open f  use f  zwrite key  zshow "D"  close f
	do fdclientcom(s,opts,timeout)
	halt

fdclientcom(s,opts,timeout)
	use $p  write opts,!  use s
	use s:DELIMITER=$c(10)
	write "data for "_opts_" server",!
	write "data for "_opts_" worker",!
	read line:timeout
	else  use $p  write "TEST-E-timeout, fdclientcom read timed out",!  zshow "*"  halt
	use $p  write "-> "_line,!
	quit

; driver routine which implements listener, starts client jobs, and passes connected sockets to worker jobs
tcheckfds(host,portno)
	set s="server",c="client",timeout=30
	set $etrap="use $p  zshow ""*""  halt"
	open s:(ioerror="TRAP":DELIMITER=$c(10))::"SOCKET"
	use s:LISTEN=portno_":TCP"
	do checkfdscom(s,"tfdclient(host,portno,opts)","t")

lcheckfds(sf)
	set s="server",c="client",timeout=30
	set $etrap="use $p  zshow ""*""  halt"
	open s:(ioerror="TRAP":DELIMITER=$c(10))::"SOCKET"
	use s:LISTEN=sf_":LOCAL"
	do checkfdscom(s,"lfdclient(sf,opts)","l")

checkfdscom(s,clijob,optpfx)
	for iflag=0:1:1  do
	. for oflag=0:1:1  do
	. . for eflag=0:1:1  do
	. . . set opts=optpfx_$$optstring(iflag,oflag,eflag)
	. . . job @(clijob_":(OUTPUT=""fdclient_"_opts_".out"":ERROR=""fdclient_"_opts_".err"")")
	. . . set clientjob=$zjob
	. . . use s
	. . . write /wait(timeout*2)	; Lookups of "::1" can be slow on AIX, so allow extra time.
	. . . else  do
	. . . . use $p
	. . . . write "TEST-E-timeout, checkfdscom wait timed out, see checkfds_lsof.err",!
	. . . . zshow "*"
	. . . . halt
	. . . set key=$key,handle=$piece(key,"|",2)
	. . . use s:DELIMITER=$c(10)
	. . . set f="checkfds_"_opts_"_zshowd.out"  open f  use f  zwrite key  zshow "D"  close f  use s
	. . . read line:timeout
	. . . else  use $p  write "TEST-E-timeout, checkfdscom read timed out",!  halt
	. . . use $p  write "server read: ",line,!
	. . . if 'iflag  do				; Consume write from fdclient
	. . . . use s
	. . . . read junk:timeout
	. . . . else  use $p  write "TEST-E-timeout, checkfdscom read timed out",!  halt
	. . . . set f="checkfds_"_opts_".in"  open f  use f  write "file input for "_opts,! close f  use s
	. . . if 'oflag  do				; Provide fdclient with something to read
	. . . . use s
	. . . . write "junk",!
	. . . . use $p
	. . . use s:DETACH=handle
	. . . set args=":(INPUT="""_$select(iflag:"SOCKET:"_handle,1:"checkfds_"_opts_".in")_""""
	. . . set args=args_":OUTPUT="""_$select(oflag:"SOCKET:"_handle,1:"fdworker_"_opts_".out")_""""
	. . . set args=args_":ERROR="""_$select(eflag:"SOCKET:"_handle,1:"fdworker_"_opts_".err")_""")"
	. . . job @("fdworker("""_opts_""")"_args)
	. . . do waitforproctodie^waitforproctodie($zjob,timeout)
	. . . do waitforproctodie^waitforproctodie(clientjob,timeout)
	halt

; build opts string from flags
optstring(iflag,oflag,eflag)
	new n
	set n=""
	set:iflag n=n_"i"
	set:oflag n=n_"o"
	set:eflag n=n_"e"
	set:n="" n="x"
	quit n

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Connect to host/portno and write out anything it returns until it runs out
netcat(host,portno)
	set s="mysocket",timeout=30
	set $etrap="set err=""netcat_""_$job_"".err""  open err  use err  zshow ""*""  halt"
	open s:(connect=host_":"_portno_":TCP":ioerror="TRAP":DELIMITER=$c(10)):timeout:"SOCKET"
	else  write "TEST-E-timeout, netcat open timed out",!  halt
	use s
	for  quit:$zeof  read line:timeout  quit:line=""  use $p  write line  use s
	use $p
	close s
	halt

; execute a simple zshow "D"
justzshowd
	write "$P=",$P,!
	zshow "D"
	write !,"ZSHOW ""D"" output saved in B:",!
	zshow "D":B
	zwrite B
	halt
