;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8191a	;look for effects of POOLLIMIT
	; convert command line parameters into a function invocation - the parameters are:
	; interval in seconds
	; number of competing jobs
	; iterations which always include a series starting with a limit of 50% and halving until they reach the minimum
	;	at which point there's one iteration with no limit; additional iterations occur before the described set
	new
	set inparms=$zcmdline,invoke="func("
	set defparms=$piece($text(defaults),";",2)
	for i=1:1:$length(defparms,",") do
	. set value=$piece(inparms," ",i),invoke=invoke_$select(0<value:+value,1:$piece(defparms,",",i))_","
	set $extract(invoke,$length(invoke))=")"
	do @invoke
	quit
defaults ;5,5,10
	;
func(interval,numjobs,iterations)	; function call so we can drive it from another GT.M routine - see above for arguments
	new (act,debug,interval,numjobs,iterations)
	if '$data(act) new act set act="use $principal write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="zgoto "_$zlevel_":error";,$zstep="zprint @$zposition zstep into"
	set tired=180
	set parms=$piece($piece($text(func),"(",2),")"),defparms=$piece($text(defaults),";",2)
	for i=1:1:$length(defparms,",") set p=$piece(parms,",",i),value=$get(@p) set:'value @(p_"="_$piece(defparms,",",i))
	kill ^x
	set (^active,^stop)=0,^report=1
	set jmaxwait=0,jobid=1
	do ^job("activity^"_$text(+0),numjobs,"""""")				; create streams of activity
	set savlim=$view("POOLLIMIT","DEFAULT")				; so we can restore it when done
	view "POOLLIMIT":"DEFAULT":"50%"
	set bts=2*$view("POOLLIMIT","DEFAULT")
	view "POOLLIMIT":"DEFAULT":"100%"
	set rounds=bts								; make sure there are enough rounds to exercise
	for i=1:1 set rounds=rounds*.5 quit:17>rounds
	set rounds=$select(iterations>i:iterations-i,1:i+1)
	set:rounds>iterations iterations=rounds+1
	set stop=(iterations+rounds)*interval*5
	for i=1:1:tired hang 1 if (numjobs)=^active quit			; wait until all activity processes have started
	else  write !,"TEST-E-TEXT, only ",^active," jobs started"
	set jobid=2
	do ^job("limit^"_$text(+0),1,""""_bts_","_rounds_","_tired_","_stop_"""")	; start limit process
	for i=1:1:iterations*1.5 hang interval set ^report=1 do  if ^stop quit		; ask for a report each interval
	. for j=1:1:tired*10 quit:'^report!^stop  hang .1
	. if tired=j write !,"TEST-E-TEXT, timed out waiting for reporter to finish" set ^stop=1
	else  write !,"TEST-E-TEXT, test ",$text(+0)," timed out"
error	set ^stop=1
	for jobid=1,2 do wait^job
	view "POOLLIMIT":"DEFAULT":savlim
	quit
activity();									; competing activity - might should be more random
	set act="write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack
	set $ecode="",$etrap="do ^incretrap"
	if $increment(^active)
	for i=1:1 quit:^stop=1  set ^x($job,$justify(i,200))=$j(i,2000) if ^report for  hang .1 quit:'^report!^stop  set ^x=$job
	quit
deviceprob
	xecute act
	set ^stop=1
	quit
	;
limit(bts,xiter,tired,stoptime)
	set act="write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack
	set $ecode="",$etrap="goto err",zl=$zlevel
	write !,"bts=",bts
	set odev=$text(+0)_".txt",sdev="mupip"
	open odev:(newver:exception="goto deviceprob")
	set limit="100%",stopday=+$horolog,stoptime=$piece($horolog,",",2)+stoptime
	if stoptime>=86400,$increment(stopday),$increment(stoptime,-86400)
	for i=1:1 do  quit:^stop
	. kill ^x
	. set ^report=0
	. for j=1:1:tired/.1 hang .1 if $data(^x) quit				; wait for some activity in ^x
	. else  write !,"limit^",$text(+0)," waited too long for data in ^x" set ^stop=1 quit
	. set starttime=$piece($horolog,",",2),x="^x"
	. for j=1:1 quit:^report!^stop  set x=$query(@x) if ""=x set x="^x"		; run hard through ^x
	. set endtime=$horolog,time=$piece(endtime,",",2)-starttime
	. set:0>time time=time+86400						; in case of midnight run
	. use odev
	. write !,"Round:",$justify(i,3),"  At:",$zdate(endtime," 24:60:SS"),"  Time:",$justify(time,3)
	. write "  Poollimit:",$justify($view("POOLLIMIT","DEFAULT"),6),"  Ops:",$justify(j,8)
	. open sdev:(command="mupip size -select=^x -region=DEFAULT":exception="goto deviceprob")::"PIPE"
	. use sdev:exception="goto sdeveof"
	. write !
	. for  read resp use odev write resp,! use sdev			; transcribe size output
sdeveof	. close sdev
	. if 'limit set ^stop=1 quit
	. do:xiter<=i							; after some unlimited runs bring down the limit
	.. set limit=$select(+limit=limit:(limit*50/bts)_"%",1:limit*bts/200)
	.. write !,"limit: ",limit
	.. set:17>$select(+limit=limit:limit,1:bts*limit/100) limit=0		; if below minimum turn limit off
	.. view "POOLLIMIT":"DEFAULT":limit
	. if +$horolog=stopday,$piece($horolog,",",2)>stoptime do
	.. write !,"TEST-E-TEXT, limited^",$text(+0)," timed out" set ^stop=1 xecute act
	.. zshow "iv"
	close odev,sdev
	write !,"limit^",$text(+0)," finished"
	quit