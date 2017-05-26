;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
client
	; ------------------------
	; The process that gets the socket open failures
	; ------------------------
	;
	s path=^config("path")
	s repcnt=^config("repcnt")
	s skpcnt=^config("skpcnt")
	s tcpdev="client$"_$j
	s socket=path_":LOCAL"
	; ------------------------
	; Client side - Check for leak -- connect and connect fails, no delimiter
	;  (path bound, but not listening)
	; ------------------------
	; ------------------------
	; Client side - Check for leak -- listen and bind fails, no delimiter
	; ------------------------
clistennd
	l +^item
	s (done,err,startused,endused,cnt)=0
	f repno=0:1:repcnt d  q:err
	. s:repno=skpcnt startused=$zus
	. s:repno=repcnt endused=$zus
	. o tcpdev:(ZLISTEN=path_":LOCAL":deliminiter="":attach="listener"):1:"SOCKET"
	. i  c tcpdev d error("client","socket "_socket_" connect succeeded!") s err=1 q
	i startused<endused s cnt=repcnt-skpcnt,leak=endused-startused d error("client","Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes")
	g:err clienterror
	s ^config("testfinished")=1
	l -^item
	; Wait for server
	f  d  q:done'=0
	. h 1
	. s:^config("testfinished")=0 done=1
	. s cnt=cnt+1 i cnt=3600 d error("server","Test took too long") s done=1 q
	. i $d(^error) s done=1 q
	; ------------------------
	; Client side - Check for leak -- listen and bind fails, delimiter
	; ------------------------
clistend
	l +^item
	s (done,err,startused,endused,cnt)=0
	f repno=0:1:repcnt d  q:err
	. s:repno=skpcnt startused=$zus
	. s:repno=repcnt endused=$zus
	. o tcpdev:(ZLISTEN=path_":LOCAL":deliminiter="abcdefg":attach="listener"):1:"SOCKET"
	. i  c tcpdev d error("client","socket "_socket_" connect succeeded!") s err=1 q
	i startused<endused s cnt=repcnt-skpcnt,leak=endused-startused d error("client","Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes")
	g:err clienterror
	s ^config("testfinished")=1
	l -^item
	q
	;
clienterror
	; The lock is still held
	tstart ():serial
	s ^config("testfinished")=2
	tcommit
	l -^item
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
