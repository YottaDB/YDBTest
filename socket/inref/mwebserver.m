;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.                                     ;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; M client for OSEHRA M Web Server as modified by Sam Habiel for TLS
	; http://osehra.org
	; https://github.com/OSEHRA-Sandbox/M-Web-Server/blob/master/M-Restful-Services-White-Paper.pdf
	; https://github.com/shabiel/M-Web-Server
	; The M Web Server is licensed "Apache License, Version 2.0"
	; This test requires VPRJREQ.m VPRJRSP.m VPRJRUT.m _WHOME.m for ping and home functions
mwebserver(portno,hostname)
	do ^sstepgbl
	set portno=$get(portno,9080)
	set portno=$get(^VPRHTTP(0,"port"),portno)
	set hostname=$get(hostname,"localhost")
	set timeout=$get(timeout,60),maxloop=$get(maxloop,20)
	set ^mwebserver($J,"port")=portno,^mwebserver($J,"host")=hostname
	for i=1:1:100 quit:$get(^VPRHTTP(0,"listener"))="running"  h 5
	if $get(^VPRHTTP(0,"listener"))'="running" do  quit
	. write !,"TEST-E-FAIL mwebserver listener not running at ",$H,!
	; need host name when hostname verification is added - curl needs now
	set c="c" open c:::"socket"
	open c:(connect=hostname_":"_portno_":tcp":ioerror="n":attach="ping"):timeout:"socket"
	use c
	if ('$test)!(+$device) set dev=$device use 0 zwrite  zshow "DS" quit
	write /tls("client")
	if +$device set dev=$device use 0 zwrite  zshow "DS" quit
	set ^mwebserver($J,"zsocket","ping")=$zsocket(c,"TLS",,"ALL") if @$reference="" do  quit
	. set dev=$device use 0 zwrite  zshow "DS"
	zshow "D":^mwebserver($J,"zshowd","ping")
	set status=$$getrequest("ping","ping")
	set ^ping("status")=status
	if status do
	. do pingresults("line")
	close c:socket="ping"
	open c:(connect=hostname_":"_portno_":tcp":ioerror="n":attach="home"):timeout:"socket"
	use c
	if ('$test)!(+$device) set dev=$device use 0 zwrite  zshow "DS" quit
	write /tls("client")
	if +$device set dev=$device use 0 zwrite  zshow "DS" quit
	set ^mwebserver($J,"zsocket","home")=$zsocket(c,"TLS",,"ALL") if @$reference="" do  quit
	. set dev=$device use 0 zwrite  zshow "DS"
	zshow "D":^mwebserver($J,"zshowd","home")
	set home="",^home("zbfsize")=$zsocket(c,"ZBFSIZE",)	;both sides use default
	set status=$$getrequest("home","")	; home page is bigger than ZBFSIZE
	set ^home("status")=status
	if status do
	. for i=1:1 read home("line",i) set home=home_home("line",i) quit:$zeof  if +$device do  quit
	. . set dev=$device use 0 zwrite  zshow "DS"
	. set ^home("len")=$length(home)
	. if ^home("len")'>^home("zbfsize") do
	. . use 0 write "TEST-E-FAIL mwebserver home too short, zbfsize = "_^home("zbfsize")_", length of response = "_^homelen,!
	. else  use 0 write "mwebserver home PASSED",!
	else  use 0 write "TEST-E-FAIL mwebserver home FAILED status = ",status,!
	close c
	; if curl available, extract CAfile, pass as "--cacert path"
	zsystem "which curl >/dev/null" if '$zsystem do
	. ; extract CAfile from $gtmcrypt_config
	. set cf=$ztrnlnm("gtmcrypt_config")
	. open cf:(read:stream) use cf
	. for  read cfline quit:$zeof!(cfline["CAfile")
	. if $zeof close cf quit
	. set cafile=$piece(cfline,"""",2)
	. set p="pipe"
	. set command="curl -s -S --cacert "_cafile_" https://"_hostname_":"_portno_"/ping"
	. if $ZVERSION["AIX" do
	. . ; /opt/freeware/bin/curl needs to use /opt/freeware/lib/libcrypto
	. . set command="(unsetenv LIBPATH LD_LIBRARY_PATH ; "_command_" )"
	. open p:(command=command:readonly)::"PIPE" use p
	. do pingresults("curl")
	. close p
	. set pingend=$find(command,"ping")
	. set $extract(command,pingend-4,pingend-1)=""	;remove ping
	. open p:(command=command:readonly)::"PIPE" use p
	. set home=""
	. for i=1:1 read home("curl",i) set home=home_home("curl",i) quit:$zeof  if +$device do  quit
	. . set dev=$device use 0 zwrite  zshow "DS"
	. set ^home("curllen")=$length(home)
	. if ^home("curllen")'>^home("zbfsize") do
	. . use 0 write "TEST-E-FAIL mwebserver home via curl too short, zbfsize = "_^home("zbfsize")_", length of response = "_^home("curllen"),!
	. else  use 0 write "mwebserver home via curl PASSED",!
	. close p
	else  do
	. use 0 write "mwebserver ping via curl MISSING",!
	. use 0 write "mwebserver home via curl MISSING",!
	set ^VPRHTTP(0,"listener")="stop"		; shut it down
	for i=1:1:100 quit:^VPRHTTP(0,"listener")="stopped"  h 5
	if ^VPRHTTP(0,"listener")'="stopped" do  quit
	. write !,"TEST-E-FAIL mwebserver listener (pid= "_mwebpid_") still running at ",$H,!
	quit
getrequest(what,uri)
	write "GET /"_uri_" HTTP/1,1"_$c(13,10)_"User-Agent:gtm"_what_$c(13,10)
	if +$device s dev=$device use 0 zwrite  zshow "DS" quit 0
	write "Host: "_hostname_":"_portno_$c(13,10)
	if +$device s dev=$device use 0 zwrite  zshow "DS" quit 0
	write "Accept: */*"_$c(13,10),!
	if +$device s dev=$device use 0 zwrite  zshow "DS" quit 0
	quit 1
pingresults(label)
	set via=$select(label="curl":"via curl ",1:""),loop=0
	for i=1:1 read ^ping($J,label,i):timeout quit:$zeof  if ('$t&($i(loop)>maxloop))!(+$device) do  quit
	. set dev=$device use 0 zwrite  zshow "DS"
	if ^ping($J,label,i-1)'["running" do
	. use 0 write "TEST-E-FAIL mwebserver ping "_via_"FAILED",!
	. zwrite ^ping($J,*) zshow "DS"
	else  do
	. set mwebpid=$piece(^ping($J,label,i-1),"{",2)
	. set mwebpid=$piece(mwebpid,":",2)
	. set mwebpid=+$extract(mwebpid,2,18)
	. set ^mwebserver($J,"serverpid"_$tr(via," "))=mwebpid
	. use 0 write "mwebserver ping "_via_"PASSED",!
	quit
