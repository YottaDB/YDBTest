;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
soczshowdleak
	;;; soczshowdleak.m
	; Test socket zshow "D" for memory leak
	;
	; ------------------------
	; configure the test
	; ------------------------
	i '$d(^config("portno")) w !,"Usage: ^config(""portno"") needs to be set to the port number to be used!",! q
	i '$d(^config("hostname")) w !,"Usage: ^config(""hostname"") needs to be set to the host to be used!",! q
	i '$d(^config("repcnt")) s ^config("repcnt")=100	; default number of times to repeat socket open
	i '$d(^config("skpcnt")) s ^config("skpcnt")=15	; default number of times to skip before loop start so $ZUSEDSTOR stabilizes
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
	; job off "client" after grabbing the sync lock
	; ------------------------
	l +^item
	s jmaxwait=0
	d ^job("client^soczshowdleak",1,"""""")
	; ------------------------
	; Server side - Check for leak -- listen and bind fails, no delimiter
	; ------------------------
slisten
	s ^config("testfinished")=0,^count=0,maxtimeouts=10
	w "Server - listen and zshow D",!
	i $d(^error)  k ^error
	o tcpdev:(LISTEN=portno_":TCP":attach="listener"):60:"SOCKET"
	e  d error("server","FAILED to open the socket device at "_$zpos)
	u tcpdev
	w /listen(5) s listenkey=$key
	; Release the client
	l -^item
	s (cnt,done,usedstart,usedend)=0
	f repno=0:1:repcnt d  q:done'=0
	. s:repno=skpcnt usedstart=$zus
	. s:repno=repcnt usedend=$zus
	. u tcpdev w /wait(60) s waitkey=$key,handle=$p(waitkey,"|",2)
	. i waitkey="" s waittimeout=$incr(waittimeout) d error("server","wait timed out or error")
	. i $get(waittimeout)>maxtimeouts s done=1 q
	. k zs zshow "D":zs
	. s desc="" f idx=1:1:$o(zs("D",""),-1) d  q:desc'=""
	. . s:zs("D",idx)[handle desc=$p($p(zs("D",idx),"DESC=",2)," ",1)
	. . q
	. c tcpdev:(socket=handle:DESTROY)
	. s:^config("testfinished") done=1 q
	. s cnt=cnt+1 i cnt=3600 d error("server","Test took too long") s done=1 q
	. i $d(^error) s done=1 q
	s ^server("repno")=repno,^server("usedstart")=usedstart,^server("usedend")=usedend
	i usedstart<usedend s cnt=repcnt-skpcnt,leak=usedend-usedstart d error("server","Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes")
	c tcpdev
	u $p
	i $d(^error) w "  FAILED: " zwr ^error
	e  w "  PASSED",!
	l +^item
	q:^config("testfinished")
stop	;
	d wait^job
	q
	; ------------------------
client	;
	s portno=^config("portno")
	s hostname=^config("hostname")
	s repcnt=^config("repcnt")
	s skpcnt=^config("skpcnt")
	l +^item
	s (done,err,startused,endused,cnt)=0
	s tcpdev="client"_$job
	s openarg="(connect="""_hostname_":"_portno_":TCP"""_":attach=""client"")"
	f repno=0:1:repcnt d  q:err
	. s:repno=skpcnt startused=$zus
	. s:repno=repcnt endused=$zus
	. o tcpdev:@openarg:60:"SOCKET"
	. e  c tcpdev s err=1 q
	. c tcpdev
	s ^config("testfinished")="c"
	s ^client("repno")=repno,^client("startused")=startused,^client("endused")=endused
	i startused<endused s cnt=repcnt-skpcnt,leak=endused-startused d error("client","Memory leak: In "_cnt_" iterations, leaked "_leak_" bytes")
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
