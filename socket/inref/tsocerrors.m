;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tsocerrors
	; Test TLS socket errors
	; ------------------------
	; configure the test
	; ------------------------
	i '$d(^config("portno")) w !,"Usage: ^config(""portno"") needs to be set to the port number to be used!",! q
	i '$d(^config("hostname")) w !,"Usage: ^config(""hostname"") needs to be set to the host to be used!",! q
	; ------------------------
	; Initialize some variables
	; ------------------------
        s portno=^config("portno")
	s hostname=^config("hostname")
	s tcpdev="server$"_$j
	if $get(^localsocket,"")="" Do
	. set connectport=hostname_":"_portno_":TCP"
	. set listenport=portno_":TCP"
	else  Do
	. set (connectport,listenport)=^localsocket_":LOCAL"
	quit
init	kill ^error,^case,^count
	quit
	; ------------------------
	; ------------------------
succeed(case,tlsid,clntid)			; WRITE /TLS is expected to succeed
	set expect=1,^case=case
	set clntid=$get(clntid,"")
	set:clntid'="" clntid=","""""_clntid_""""""
	do tsocerrors
	set $etrap="do sorftrap"
	do doopen(expect,"""1,1"_clntid_"""")		; client should also succeed
	if $data(^error(case))=0 do
	. do dotls(expect,tlsid)
	do finish
	quit
fail(case,tlsid,errstring,clnttry,clntsucceed,clntid)	; WRITE /TLS is expected to fail
	set expect=0,^case=case
	set:case="5b" expect=1		; special case - need enabled socket
	set clntsucceed=$get(clntsucceed,0)
	set clnttry=$get(clnttry,0)
	set clntid=$get(clntid,"")
	set:clntid'="" clntid=","""""_clntid_""""""
	do tsocerrors
	set $etrap="do sorftrap"
	do doopen(expect,""""_clnttry_","_clntsucceed_clntid_"""")
	set checkcase=case
	if $data(^error(case))=0 do
	. do dotls(expect,tlsid)
	. if case="5b" write /tls("server",60,"server")	; error since already enabled
	. else  set checkcase=checkcase_"|"_case_".dotls"
	if clnttry&(case'=2)&(case'="5b") set checkcase=checkcase_"|"_case_".clnt"
	do checkerror(checkcase,errstring)
	do finish
	quit
sorftrap	set ecode=$ecode,$ecode=""
	set ^expected(case,"device")=$device
	set ^expected(case,"zstatus")=$zstatus
	quit
servererrors(case)
	set expect=0,^case=case
	do tsocerrors
	do doopen(expect,"""0,0""")	; we expect the write /tls to fail early
	zshow "D":^zshowd("servererrors","serverb4")
	; insert tests here
	set $etrap="do serverror"
	; ^expected("badopt","zstatus")="150383618,servererrors+9^tsocerrors,%YDB-E-TLSPARAM, TLS parameter BADOPT not a valid option"
	do
	. set (case,^case)="badopt" u tcpdev write /tls("badopt")
	. do error("servererrors",case)
	do checkerror(case,"not a valid")
	; ^expected("noopt","zstatus")="150372778,servererrors+14^tsocerrors,%YDB-E-EXPR,Expression expected but not found"
	do
	. set (case,^case)="noopt" u tcpdev write /tls(,)
	. do error("servererrors",case)
	do checkerror(case,"E-EXPR")
	; ^expected("renegotiate","zstatus")="150383618,servererrors+19^tsocerrors,%YDB-E-TLSPARAM, TLS parameter RENEGOTIATE but TLS not enabled"
	do	; needs tls enabled socket
	. set (case,^case)="renegotiate" u tcpdev write /tls("renegotiate")
	. do error("servererrors",case)
	do checkerror(case,"TLS not enabled")
	; ^expected("listener","zstatus")="150383618,servererrors+27^tsocerrors,%YDB-E-TLSPARAM, TLS parameter /TLS but socket not connected"
	set $zstatus=""			; clear it
	do	; listening socket not able to enable tls
	. set (case,^case)="listener"
	. u tcpdev:(socket="listener":delimiter=$c(10))	; avoid accept
	. write /tls("server",60,"server")
	. do error("servererrors",case)
	zshow "D":^zshowd("listener")		; diagnostic information
	do checkerror(case,"not connected")
	use 0
	if $d(^error("servererrors")) w "  FAILED: " zwr ^error("servererrors",*)
	else  w "  PASSED: servererrors",!
	zshow "D":^zshowd("servererrors","serverafter")
	quit
serverror	set ecode=$ecode,$ecode=""
	set ^expected(case,"device")=$device
	set ^expected(case,"zstatus")=$zstatus
	quit
doopen(expected,clienttls)
	; job off "client" after grabbing the sync lock
	; ------------------------
	l +^item
	l +^ok2close
	s jmaxwait=0,jmjoname="tsocclnt_"_$piece(^case,"|")
	set ^checkjob(^case,"doopen")=expected_"|"_clienttls
	d ^job("tsocclnt^"_$text(+0),1,clienttls)
	s ^count=0
	o tcpdev:::"SOCKET"
	o tcpdev:(LISTEN=listenport:delim="":attach="listener"):1:"SOCKET"
	e  u tcpdev d error("server","FAILED to open the socket device "_$device_" at "_$zpos)
	u tcpdev
	; Release the client
	w /listen(5)
	l -^item
	w /wait(360)
	s key=$key i key'["CONNECT" d error("server","no connect after wait -$key : "_$key_" $device: "_$device) s done=1 q
	quit
dotls(expected,tlsid)
	If $get(^sunsetpasswd,0) Do
	. Do unsetenv^%ydbposix("gtmtls_passwd_"_tlsid)
	. Set ^checkjob(^case,"sunsetpasswd")=^sunsetpasswd Kill ^sunsetpasswd
	If $get(^sunsetconfig,0) Do
	. Do unsetenv^%ydbposix("gtmcrypt_config")
	. Set ^checkjob(^case,"sunsetconfig")=^sunsetconfig Kill ^sunsetconfig
	Set writetls="write /tls(""server"",60,tlsid"
	If $get(^spasswd,"")'="" Set writetls=writetls_",^spasswd",^checkjob(^case,"spasswd")=^spasswd
	If $get(^sconfig,"")'="" Do
	. If $get(^spasswd,"")="" Set writetls=writetls_","	; missing passwd
	. Set writetls=writetls_",^sconfig",^checkjob(^case,"sconfig")=^sconfig
	Set writetls=writetls_")",^checkjob(^case,"writetls")=writetls
	X writetls
	Kill ^spasswd,^sconfig
	Zshow "D":^zshowd(^case,"serverb4")
	Set test=$test,tlsset=$$getkeyword^gethandle(tcpdev,1,"TLS",1)
	Set zsocket=$zsocket(tcpdev,"TLS",1,"all,internal")
	Set ^checkjob(^case,"dotls","aftertls")=test_"|"_$device_"|"_tlsset_"|"_zsocket
	Set success=(test=1)&(+$Device=0)&(tlsset="TLS")
	If +zsocket'=(tlsset="TLS") Do
	. Do error("server",$text(+0)_"E-FAILED zsocket disagrees with gethandle: /"_zsocket_"/ vs /"_tlsset_"/")
	If expected'=success Do
	. New dev Set dev=$Device
	. do error("server",$text(+0)_"-E-FAILED to "_$s(expected=0:"not ",1:"")_"enable TLS: $T:"_test_" $D:"_dev_" tls:"_tlsset) s done=1 q
	Else  Do
	. set ^expected(^case_".dotls","device")=$device
	. set ^expected(^case_".dotls","zstatus")=$zstatus
	zshow "D":^zshowd(^case,"serverafter")
	set ^checkjob(^case,"zsocket","dotls")=$zsocket("","TLS",,"all,internal")
	if $data(^error(^case)) quit	; failed so done
	if $data(^reneg) do
	. set rentotchk=^checkjob(^case,"zsocket","dotls")
	. set rentotstart=$find(rentotchk,"RENTOT:")
	. if rentotstart=0 do  quit
	. . use $p write !,$text(+0)_"-E-FAILED no RENTOT in $zsocket so unable to test: ",rentotchk,!
	. set rentotb4=+$extract(rentotchk,rentotstart,99)
	. use tcpdev:delim=$c(10)
	. for i=1:1:3 write i_" just some data",! read somedata:60 quit:'$test
	. write "prep4reneg",!
	. for i=1:1:100 read ok2reneg:10 quit:+$device  quit:ok2reneg="ok2reneg"
	. set device=$device
	. if ('$TEST)!(+device) do  quit
	. . set ^checkjob(^case,"nook2reneg")="ok2reneg:"_ok2reneg_",$test:"_$test_",$device:"_device
	. . set ^expected(^case_".server","device")=device
	. . use $p write !,$text(+0)_"-E-FAILED No OK to renegotiate after "_i_" tries"," $device = ",device,!
	. . halt
	. set writereneg="write /tls(""renegotiate"""
	. if $data(^reneg("tlsid"))=1 set writereneg=writereneg_",,"_$zwrite(^reneg("tlsid"))
	. if $data(^reneg("opts"))=1 do
	. . if $data(^reneg("tlsid"))=0 set writereneg=writereneg_",,"
	. . set writereneg=writereneg_",,"_$zwrite(^reneg("opts"))
	. set writereneg=writereneg_")"
	. set ^checkjob(^case,"writereneg")=writereneg
	. x writereneg
	. set ^checkjob(^case,"zdevice","afterreneg","server")=$device
	. set ^checkjob(^case,"zsocket","afterreneg","server")=$zsocket("","TLS",,"all,internal")
	. set rentotchk=^checkjob(^case,"zsocket","afterreneg","server")
	. set rentotstart=$find(rentotchk,"RENTOT:")
	. set rentotafter=+$extract(rentotchk,rentotstart,99)
	. if $get(^reneg("conf"))["SSL_VERIFY_CLIENT_ONCE" set ^reneg("opts")=^reneg("conf")
	. if $get(^reneg("opts"))["SSL_VERIFY_CLIENT_ONCE" do
	. . set verifymode=$extract(rentotchk,$find(rentotchk,"|O:"),99999)
	. . set vmoff=$find(verifymode,",")
	. . set verifymode=$extract(verifymode,vmoff,vmoff+1)
	. . if $$FUNC^%HD(verifymode)'=5 do error("reneg",$text(+0)_"-E-FAILED verify-mode expected 05 got "_verifymode)
	. set ret=0
	. ; Exchange data with client looking for RENTOT changes
	. ; Note that from TLS 1.3 onwards, there is no renegotiation that happens (see YDB@44931460 commit message for details).
	. ; Therefore, in that case, we expect to see RENTOT as 0 all the time.
	. do:'$ztrnlnm("ydb_test_tls13_plus")
	. . for i=1:1:5 do  quit:ret!(rentotb4<rentotafter)
	. . . write i_" afterreneg",!
	. . . set ret=$$renegcheckerr(^case,"renegserv",$device)
	. . . if ret set ^checkjob(^case,"write","afterreneg"_i)=$device quit
	. . . read somedata:60
	. . . set ^checkjob(^case,"zsocket","afterreneg","server"_i)=$zsocket("","TLS",,"all,internal")_"<data:"_$get(somedata)
	. . . set ret=$$renegcheckerr(^case,"renegserv",$device)
	. . . if ret do  quit
	. . . . set ^checkjob(^case,"read","afterreneg"_i)=$device
	. . . . do checkerror(^case_".renegserv.reneg",$get(^reneg("expected")))
	. . . set rentotchk=^checkjob(^case,"zsocket","afterreneg","server"_i)
	. . . set rentotstart=$find(rentotchk,"RENTOT:")
	. . . set rentotafter=+$extract(rentotchk,rentotstart,99)
	. . if (ret=0)&(rentotb4'<rentotafter) do error("server",$text(+0)_"-E-FAILED RENTOT unchanged")
	quit
renegcheckerr(case,side,device)
	new caller,ret set caller=$stack($stack-1,"PLACE")
	set ret=+device
	if ret do
	. if ^reneg="fail" do
	. . set ^expected(case_"."_side_".reneg","device")=device
	. else  do error(side_".reneg",caller_"-E-FAILED Success expected, $device:"_device)
	quit ret
checkerror(case,errstring)
	new errmsg,device,zstatus,what,i,somestatus set somestatus=0
	set ^checkjob(case,"checkerror")=errstring
	for i=1:1:3 set what=$zpiece(case,"|",i) quit:what=""  do
	. set device=$get(^expected(what,"device"),0)
	. set zstatus=$get(^expected(what,"zstatus"),"")
	. if (device=0)&(zstatus="") quit
	. set somestatus=somestatus+1,^checkjob(what,i,"checkerror","dev|status")=device_"|"_zstatus
	. if ($zfind(device,errstring)=0)&($zfind(zstatus,errstring)=0) do
	. . set errmsg=$text(+0)_"-E-FAILED expected error "_errstring_" not found - $D: "_$device
	. . do error("checkerror"_what,errmsg)
	if somestatus=0 do error("checkerror",$text(+0)_"-E-FAILED no expected errors found")
	quit
finish
	; i $d(^error(^case)) s done=1 q
	c tcpdev
	l -^ok2close
	u 0
	i $d(^error(^case)) w "  FAILED: " zwr ^error(^case,*)
	e  w "  PASSED: ",^case,!
stop	;
	d wait^job
	q
buildconfig(option,type,value)
	if $data(^sconfig)=0 set ^sconfig=""
	if type="string" do
	. set ^sconfig=^sconfig_option_": """_value_""";"
	else  set ^sconfig=^sconfig_option_": "_value_";"
	quit
	;
tsocclnt(wanttls,gettls,clntid)	;client
	set gettls=$get(gettls,0)	; expect to establish TLS
	set clntid=$get(clntid,"")
	set ^checkjob(^case,"tsocclnt")=wanttls_"|"_gettls_"|"_clntid
	set cconfig=""
	if ^case["cunset" do
	. do unsetenv^%ydbposix("gtmcrypt_config")
	. set ^checkjob(^case,"unsetenv")=$ztrnlnm("gtmcrypt_config")
	. if ^checkjob(^case,"unsetenv")'="" do error("client","FAILED to unsetenv gtmcrypt_config: "_^checkjob(^case,"unsetenv"))
	. if gettls do
	. . set cconfig="CAfile: "_$zwrite($ztrnlnm("PWD")_"/calist.pem")_";"
	. . set ^checkjob(^case,"cconfig")=cconfig
	do tsocerrors
	if ^case="9b" do
	. set cconfig="CAfile: "_$zwrite($ztrnlnm("PWD")_"/calist.pem")_";"
	. set ^checkjob(^case,"cconfig")=cconfig
	l +^item	; wait for server to listen
	o tcpdev:::"SOCKET"
	o tcpdev:(CONNECT=connectport:delim="":attach="client"):60:"SOCKET"
	e  u tcpdev d error("client","FAILED to open the socket device"_$device_" at "_$zpos) set wanttlssave=wanttls,wanttls=0
	u tcpdev
	if wanttls do
	. if (cconfig'="")&(clntid="") set clntid="clntid4cconfig",^checkjob(^case,"clntid")=clntid_"|"_cconfig
	. Set writeclient="write /tls(""client"",60,clntid"
	. if cconfig'="" Set writeclient=writeclient_",,cconfig"
	. Set writeclient=writeclient_")"
	. Set ^checkjob(^case,"writeclient")=writeclient
	. x writeclient
	. zshow "D":^zshowd(^case,"clientb4")
	. Set test=$test,tlsset=$$getkeyword^gethandle(tcpdev,0,"TLS",1)
	. Set zsocket=$zsocket(tcpdev,"TLS",0,"all,internal")
	. Set ^checkjob(^case,"tsocclnt","aftertls")=test_"|"_$device_"|"_tlsset_"|"_zsocket
	. If +zsocket'=(tlsset="TLS") Do
	. . Do error("client",$text(+0)_"E-FAILED zsocket disagrees with gethandle: /"_zsocket_"/ vs /"_tlsset_"/")
	. Set success=(test=1)&(+$Device=0)&(tlsset="TLS")
	. If success'=gettls Do
	. . New dev Set dev=$Device
	. . do error("client",$text(+0)_"-E-FAILED to "_$s(gettls=0:"not ",1:"")_"enable TLS: $T:"_test_" $D:"_dev_" tls:"_tlsset) q
	. Else  If 'success Do	; record info on expected failure
	. . Set ^expected(^case_".clnt","device")=$device
	. . Set ^expected(^case_".clnt","zstatus")=$zstatus
	. If (^case=2)&(gettls=0)&($Device["no ciphers available") Do
	. . do error("client",$text(+0)_"-E-FAILED CASE 2 check cipher-lists in config file, $D: "_$Device)
	. zshow "D":^zshowd(^case,"clientafter")
	set ^checkjob(^case,"zsocket","tsoclnt")=$zsocket("","TLS",,"all,internal")
	set rentotchk=^checkjob(^case,"zsocket","tsoclnt")
	set rentotstart=$find(rentotchk,"RENTOT:")
	if rentotstart=0 do
	. set rentotb4=0	; client may not have session so no RENTOT:0 even
	else  set rentotb4=+$extract(rentotchk,rentotstart,99)
	if $data(^reneg) do
	. use tcpdev:delim=$c(10)
	. set ret=0
	. for i=1:1:9 do  quit:ret!(somedata="prep4reneg")!$zeof
	. . read somedata:60 quit:somedata="prep4reneg"
	. . set ret=$$renegcheckerr(^case,"renegclntb4",$device)
	. . if ret set ^checkjob(^case,"read","clntb4reneg"_i)=$device quit
	. . write i_" just some data",!
	. . set ret=$$renegcheckerr(^case,"renegclntb4",$device)
	. . if ret set ^checkjob(^case,"write","clntb4reneg"_i)=$device quit
	. if somedata="prep4reneg" write "ok2reneg",!
	. set ret=0
	. do:'$ztrnlnm("ydb_test_tls13_plus")
	. . for i=1:1:9 do  quit:ret!(somedata["afterreneg")!$zeof
	. . . read somedata:60 quit:$zeof
	. . . set ret=$$renegcheckerr(^case,"renegclnt",$device)
	. . . if ret set ^checkjob(^case,"read","clntafterreneg"_i)=$device quit
	. . . write i_" just some data",!
	. . . set ret=$$renegcheckerr(^case,"renegclnt",$device)
	. . . if ret set ^checkjob(^case,"write","clntafterreneg"_i)=$device quit
	. . . set ^checkjob(^case,"zsocket","tsoclnt","afterreneg"_i)=$zsocket("","TLS",,"all,internal")_"<data:"_somedata
	. . . set rentotchk=^checkjob(^case,"zsocket","tsoclnt","afterreneg"_i)
	. . . set rentotstart=$find(rentotchk,"RENTOT:")
	. . . if rentotstart=0 do
	. . . . set rentotafter=0	; client may not have session so no RENTOT:0 even
	. . . else  set rentotafter=+$extract(rentotchk,rentotstart,99)
	. . if (ret=0)&(rentotb4'<$get(rentotafter)) do error("client",$TEXT(+0)_"-E-FAIL RENTOT unchanged")
	l +^ok2close
	c tcpdev
	l -^ok2close
	l -^item
	u 0
	i $d(^error(^case)) w "  FAILED: " zwr ^error(^case,*)
	e  w "  PASSED",!
	q
error(side,content)
	new previo,dev set previo=$IO,dev=$device
	s ^error(^case,$increment(^count),side,"testmsg")=content
	s ^error(^case,^count,side,"zstatus")=$zstatus
	s ^error(^case,^count,side,"device")=$device
	zshow "DV":^error(^case,^count,side,"zshowd")
	u $p
	zwr ^error(^case,*)
	use previo
	q
	;
