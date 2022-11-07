;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2007, 2013 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
socketmemleak
	;;; socmemleak.m
	; Test socket open failure for memory leak
	;   "server" just keeps the port busy so the "client" errors when
	;   trying to open the same port
	;
	; ------------------------
	; configure the test
	; ------------------------
	i '$d(^config("portno")) w !,"Usage: ^config(""portno"") needs to be set to the port number to be used!",! q
	i '$d(^config("hostname")) w !,"Usage: ^config(""hostname"") needs to be set to the host to be used!",! q
	i '$d(^config("repcnt")) s ^config("repcnt")=100	; default number of times to repeat socket open
	i '$d(^config("skpcnt")) s ^config("skpcnt")=5	; default number of times to skip before loop start so $ZUSEDSTOR stabilizes
	; We do a few global updates in the previous lines. Flush those updates right away in case ASYNCIO is turned ON
	; as otherwise the flush might happen a little later (when the flush timer kicks in, usually in 1 second) at which
	; point we might be in the middle of a section of the test which expects no memory leaks and fail the leak test because
	; the flush did a malloc (see "gtm_malloc(SIZEOF(struct gd_info))" in "sr_unix/aio_shim.c") when ASYNCIO is turned ON.
	; If ASYNCIO is OFF, the database flush logic does not do any mallocs so we do not do the flush right away in that case.
	view:$ztrnlnm("gtm_test_asyncio") "flush"
	; ------------------------
	; Initialize some variables
	; ------------------------
        s portno=^config("portno")
	s hostname=^config("hostname")
	s repcnt=^config("repcnt")
	s skpcnt=^config("skpcnt")
	s tcpdev="server$"_$j
	s socket=hostname_":"_portno_":TCP"
	s incrtrapNODISP=1
	; ------------------------
	; Check for leak -- ERR_SOCKETEXIST, no delimiter
	; ------------------------
socketexistnd
	s (done,startused,endused)=0 w "ERR_SOCKETEXIST, no delimiter",!
	f repno=1:1:repcnt d  q:done'=0
	. s:repno=skpcnt startused=$zus
	. s:repno=repcnt endused=$zus
	. o tcpdev:(LISTEN=portno_":TCP":delimiter="":attach="LISTENER"):1:"SOCKET"
	. e  w !,"FAILED to open the socket device at "_$zpos,! s done=1 q
	. o tcpdev:(LISTEN=portno_":TCP":delimiter="":attach="LISTENER":exception="g incrtrap^incrtrap"):1:"SOCKET"
	. c tcpdev:(NODEST)
	i startused<endused s cnt=repcnt-skpcnt,leak=endused-startused w "  FAILED: Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes",!
	e  w "  PASSED",!
	; ------------------------
	; Check for leak -- ERR_SOCKETEXIST, delimiter
	; ------------------------
socketexistd
	s (done,startused,endused)=0 w "ERR_SOCKETEXIST, delimiter",!
	f repno=1:1:repcnt d  q:done'=0
	. s:repno=skpcnt startused=$zus
	. s:repno=repcnt endused=$zus
	. o tcpdev:(LISTEN=portno_":TCP":delimiter="abcdefg":attach="LISTENER"):1:"SOCKET"
	. e  w "FAILED to open the socket device at "_$zpos,! s done=1 q
	. o tcpdev:(LISTEN=portno_":TCP":delimiter="abcdefg":attach="LISTENER":exception="g incrtrap^incrtrap"):1:"SOCKET"
	. c tcpdev:(NODEST)
	i startused<endused s cnt=repcnt-skpcnt,leak=endused-startused w "  FAILED: Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes",!
	e  w "  PASSED",!
	; ------------------------
	; Check for leak -- ERR_DELIMWIDTH, no delimiter
	;
	; Obviously, included for completeness, but it makes no sense.
	;     If there is no delimiter, it won't be too wide
	; ------------------------
	; Check for leak -- ERR_DELIMWIDTH, delimiter
	; ------------------------
delimwidthd
	s (done,startused,endused)=0 w "ERR_DELIMWIDTH, delimiter",!
	o tcpdev:(LISTEN=portno_":TCP":delimiter="":attach="LISTENER"):1:"SOCKET"
	e  w "FAILED to open the socket device at "_$zpos,! s done=1 q
	u tcpdev:(width=10)
	s delim="abcdefghijklmnopqrstuvwxyz"
	f repno=1:1:repcnt d  q:done'=0
	. s:repno=skpcnt startused=$zus
	. s:repno=repcnt endused=$zus
	. o tcpdev:(LISTEN=portno_":TCP":delimiter=delim:attach="LISTENER"):1:"SOCKET"
	. c tcpdev:(NODEST)
	u 0
	i startused<endused s cnt=repcnt-skpcnt,leak=endused-startused w "  FAILED: Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes",!
	e  w "  PASSED",!
	; ------------------------
	; Check for leak -- ERR_SOCKMAX, no delimiter
	; ------------------------
socmaxnd
	s (done,startused,endused)=0 w "ERR_SOCKMAX, no delimiter",!
	f repno=0:1:repcnt d  q:done'=0
	. s:repno=skpcnt startused=$zus
	. s:repno=repcnt endused=$zus
	. f sock=1:1:1000 d  i $p($zs,",",1)=150381146 s $zs="" q
	. . o tcpdev:(LISTEN="0:TCP":delimiter="":attach="listen"_sock:exception="g incrtrap^incrtrap"):1:"SOCKET"
	. . ;Empty line where incrtrap returns
	. f sock=1:1:sock-1 c tcpdev:(NODEST:socket="listen"_sock)
	. c tcpdev:(NODEST)
	i startused<endused s cnt=repcnt-skpcnt,leak=endused-startused w "  FAILED: Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes",! zwrite startused,endused
	e  w "  PASSED",!
	; ------------------------
	; Check for leak -- ERR_SOCKMAX, delimiter
	; ------------------------
socmaxd
	s (done,startused,endused)=0 w "ERR_SOCKMAX, delimiter",!
	f repno=0:1:repcnt d
	. s:repno=skpcnt startused=$zus
	. s:repno=repcnt endused=$zus
	. f sock=1:1:1000 d  i $p($zs,",",1)=150381146 s $zs="" q
	. . o tcpdev:(LISTEN="0:TCP":delimiter="abcdefg":attach="listen"_sock:exception="g incrtrap^incrtrap"):1:"SOCKET"
	. . ;Empty line where incrtrap returns
	. f sock=1:1:sock-1 c tcpdev:(NODEST:socket="listen"_sock)
	. c tcpdev
	i startused<endused s cnt=repcnt-skpcnt,leak=endused-startused w "  FAILED: Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes",! zwrite startused,endused
	e  w "  PASSED",!
	; ------------------------
	; Check for leak -- Connect fails, no delimiter
	; ------------------------
connectnd
	s (done,startused,endused)=0 w "Connect fails, no delimiter",!
	f repno=0:1:repcnt d  i $p($zs,",",1)=150376394!done'=0 s $zs="" q
	. s:repno=skpcnt startused=$zus
	. s:repno>skpcnt endused=$zus
	. o tcpdev:(connect=socket:deliminiter="":attach="connect":exception="g incrtrap^incrtrap"):1:"SOCKET"
	. i  c tcpdev:(NODEST) w "FAILED: socket open succeeded at "_$zpos s done=1 q
	i startused<endused s cnt=repno-skpcnt,leak=endused-startused w !,"  FAILED: Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes",!
	e  w "  PASSED",!
	; ------------------------
	; Check for leak -- Connect fails, delimiter
	; ------------------------
connectd
	s (done,startused,endused)=0 w "Connect fails, delimiter",!
	f repno=0:1:repcnt d  i $p($zs,",",1)=150376394!done'=0 s $zs="" q
	. s:repno=skpcnt startused=$zus
	. s:repno>skpcnt endused=$zus
	. o tcpdev:(connect=socket:deliminiter="abcdefg":attach="connect":exception="g incrtrap^incrtrap"):1:"SOCKET"
	. i  c tcpdev:(NODEST) w "FAILED: socket open succeeded at "_$zpos s done=1 q
	i startused<endused s cnt=repno-skpcnt,leak=endused-startused w "  FAILED: Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes",!
	e  w "  PASSED",!
	;
	; ------------------------
	; Rest of the tests require client-server
	; ------------------------
	;
	; ------------------------
	; job off "client" after grabbing the sync lock
	; ------------------------
servertest
	l +^item
	s jmaxwait=0
	d ^job("socmlkclnt",1,"""""")
	; ------------------------
	; Server side - Check for leak -- connect and connect fails, no delimiter
	; ------------------------
	; ------------------------
	; Server side - Check for leak -- listen and bind fails, no delimiter
	; ------------------------
slistennd
	s ^config("testfinished")=0,^count=0
	w "Server - listen and bind fails, no delimiter",!
	i $d(^error)  k ^error
	o tcpdev:(LISTEN=portno_":TCP":deliminiter="":attach="listener"):1:"SOCKET"
	e  d error("server","FAILED to open the socket device at "_$zpos)
	u tcpdev
	; Release the client
	w /listen(5)
	l -^item
	s cnt=0,done=0
	f  d  q:done'=0
	. h 1
	. s:^config("testfinished") done=1
	. s cnt=cnt+1 i cnt=3600 d error("server","Test took too long") s done=1 q
	. i $d(^error) s done=1 q
	c tcpdev
	u 0
	i $d(^error) w "  FAILED: " zwr ^error
	e  w "  PASSED",!
	l +^item
	q:^config("testfinished")=2
	; ------------------------
	; Server side - Check for leak -- listen and bind fails, delimiter
	; ------------------------
slistend
	s ^config("testfinished")=0,^count=0
	w "Server - listen and bind fails, delimiter",!
	i $d(^error)  k ^error
	o tcpdev:(LISTEN=portno_":TCP":deliminiter="":attach="listener"):1:"SOCKET"
	e  d error("server","FAILED to open the socket device at "_$zpos)
	u tcpdev
	; Release the client
	w /listen(5)
	l -^item
	s cnt=0,done=0
	f  d  q:done'=0
	. h 1
	. s:^config("testfinished") done=1
	. s cnt=cnt+1 i cnt=3600 d error("server","Test took too long") s done=1 q
	. i $d(^error) s done=1 q
	c tcpdev:(NODEST)
	u 0
	i $d(^error) w "  FAILED: " zwr ^error
	e  w "  PASSED",!
stop	;
	d wait^job
	q
	;
error(side,content)
	tstart ():serial
	s ^error(^count,side)=content,^count=^count+1
	tcommit
	u $p
	zwr ^error
	q
	;
