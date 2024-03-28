;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zsocket(host,port)	; check using $zsocket
	set (expectport,port)=$get(port,6666),host=$get(host,"localhost")
	if port'="LOCAL" set listenarg=port_":TCP",connarg=host_":"_listenarg
	else  set (listenarg,connarg)=host_":LOCAL",expectport=0
	set s="socdev",c="conndev",errors=0
	open s:::"socket"
	open s:(listen=listenarg:attach="listen")::"socket"
	use s set lkey=$key,ldev=$device if lkey="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL listen failed ",ldev,! halt
	set zsn=$zsocket("","NUMBER")
	if zsn'=1 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen NUMBER failed, = ",zsn,!
	set zsci=$zsocket(s,"currentindex")
	if zsci'=0 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen CURRENTINDEX failed, = ",zsci,!
	set zsi=$zsocket(s,"INDEX","listen")
	if zsi'=0 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen INDEX failed, = ",zsi,!
	set zsh=$zsocket(s,"SOCKETHANDLE",)
	if zsh'="listen" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen SOCKETHANDLE failed, = ",zsh,!
	set zshc=$zsocket(s,"HOWCREATED",)
	if zshc'="LISTEN" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen HOWCREATED failed, = ",zshc,!
	set zss=$zsocket(s,"STATE",)
	if zss'="LISTENING" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen STATE failed, = ",zss,!
	set zsprot=$zsocket(s,"PROTOCOL",)
	if $extract(zsprot,1,3)'=$select(port="LOCAL":"LOC",1:"TCP") set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen PROTOCOL failed, = ",zsprot,!
	set zslp=$zsocket(s,"LOCALPORT",)
	if zslp'=expectport set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen LOCALPORT failed, = ",zslp,!
	set zsp=$zsocket(s,"PARENT",0)
	if zsp'="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket listen PARENT failed, = ",zsp,!
	open c:::"socket"
	open c:(connect=connarg:attach="conn")::"socket"
	use c set ckey=$key,cdev=$device if ckey="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL connect failed ",cdev,! halt
	set zchc=$zsocket(c,"HOWCREATED",)
	if zchc'="CONNECT" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket connect HOWCREATED failed, = ",zchc,!
	set zcs=$zsocket(c,"STATE",)
	if zcs'="CONNECTED" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket connect STATE failed, = ",zcs,!
	set zcrp=$zsocket(c,"REMOTEPORT",)
	if zcrp'=expectport set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket connect REMOTEPORT failed, = ",zcrp,!
	set zcra=$zsocket(c,"REMOTEADDRESS",)
	if zcra="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket connect REMOTEADDRESS empty",!
	set zclp=$zsocket(c,"LOCALPORT",)
	if zclp="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket connect LOCALPORT empty",!
	set zcla=$zsocket(c,"LOCALADDRESS",)
	if zcla="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket connect LOCALADDRESS empty",!
	set zcbfszb4=$zsocket(c,"zbfsize",)
	use c:zbfsize=(zcbfszb4+1024)
	set zcbfsz=$zsocket(c,"zbfsize",)
	if zcbfsz'=(zcbfszb4+1024) set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket connect mismatch ZBFSIZE before("_zcbfszb4+1024_") and after("_zcbfsz_")",!
	set zcibfszb4=$zsocket(c,"zibfsize",)
	if ($zver'["VMS")&($zver'["Solaris") do  ; setsockopt SO_RCVBUF is privileged on OpenVMS and Solaris zones
	. use c:zibfsize=(zcibfszb4+1024)
	. set zcibfsz=$zsocket(c,"zibfsize",)
	. ; Note that "zcibfsz" may contain the system value for SO_RCVBUF in addition to the ZIBFSIZE device parameter.
	. ; In that case, the value would be "ZIBFSIZE;SO_RCVBUF". But what we are interested in here is the ZIBFSIZE
	. ; value. Therefore extract that out using the "$piece" below and use that for the remainder of the comparison.
	. if $piece(zcibfsz,";",1)'=(zcibfszb4+1024) set errors=$i(errors) do
	. . use 0 write "TEST-E-FAIL $zsocket connect mismatch ZIBFSIZE before("_zcibfszb4+1024_") and after("_zcibfsz_")",!
	use s write /wait
	set key=$key,handle=$piece(key,"|",2)
	if key="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL write /wait found nothing",! halt
	set zsch=$zsocket("","SOCKETHANDLE",)
	if zsch'=handle set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL mismatch handle from $key ("_handle_") and $zsocket("_zsch_")",!
	set zsi=$zsocket(s,"INDEX",handle)
	if zsi'=1 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted INDEX failed, = ",zsi,!
	set zsd=$zsocket(s,"DESCRIPTOR",zsi)
	set desc=$$getdesc^gethandle(s,zsi)
	if zsd'=desc set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted mismatch desc getdesc ("_desc_") and $zsocket("+zsd_")",!
	set zshc=$zsocket(s,"HOWCREATED",)
	if zshc'="ACCEPTED" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted HOWCREATED failed, = ",zshc,!
	set zss=$zsocket(s,"STATE",)
	if zss'="CONNECTED" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted STATE failed, = ",zss,!
	set zsn=$zsocket(s,"NUMBER")
	if zsn'=2 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted NUMBER failed, = ",zsn,!
	set zsci=$zsocket(s,"currentindex")
	if zsci'=1 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted CURRENTINDEX failed, = ",zsci,!
	set zsp=$zsocket(s,"PARENT",1)
	if zsp'="listen" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted PARENT failed, = ",zsp,!
	set zsrp=$zsocket(s,"REMOTEPORT",)
	if zsrp="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted REMOTEPORT empty",!
	set zsra=$zsocket(s,"REMOTEADDRESS",)
	if zsra="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted REMOTEADDRESS empty",!
	set zslp=$zsocket(s,"LOCALPORT",)
	if zslp'=expectport set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted LOCALPORT failed = ",zslp,!
	set zsla=$zsocket(s,"LOCALADDRESS",)
	if zsla="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted LOCALADDRESS empty",!
	set zsmrtb4=$zsocket(s,"morereadtime",)
	if zsmrtb4'="" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted MOREREADTIME set =",zsmrtb4,!
	use s:morereadtime=400
	set zsmrtaft=$zsocket(s,"morereadtime",)
	if zsmrtaft'=400 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted MOREREADTIME not set =",zsmrtaft,!
	use s:ioerror="t"
	set zserr=$zsocket(s,"ioerror",)
	if zserr'=1 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted IOERROR not set =",zserr,!
	use s:(delim="delim":zff="zff")
	set zsndelim=$zsocket(s,"delimiter",)
	if zsndelim'=1 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted number of DELIMs not 1 =",znsdelim,!
	set zsdelim=$zsocket(s,"delimiter",,0)
	if zsdelim'="delim" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted mismatched DELIM =",zsdelim,!
	set zszff=$zsocket(s,"zff",)
	if zszff'="zff" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted mismatched ZFF =",zszff,!
	use s:znodelay
	set zsdelay=$zsocket(s,"ZDELAY",)
	if zsdelay'=0 set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL $zsocket accepted ZDELAY still set =",zsdelay,!
	if errors>0 use 0 zwrite
	else  close c close s
	quit
