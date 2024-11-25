;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

connect ; entry: connect to non-existent IP address
	;
	; important: don't perform any database or print operation here
	; because it would start a timer, but we want to go without any
	; timer to test OPEN command's timeout behaviour
	;
	set beg=$horolog
	open "socket":(connect="[240.0.0.0]:19355:TCP"):1:"SOCKET"
	set end=$horolog
	;
	set elapsed=$$^difftime(end,beg)
	if elapsed>2 do  quit
	.write "test was running for ",$justify(elapsed,0,2)," sec, failed",!
	;
	write "test was running less than 2 sec, passed",!
	quit

server	; entry: server
	;
	do procArgs
	do rstcc
	do checkpoint(actor,1,"server start")
	;
	if delay>0 do
	.write "hanging for ",delay," sec",!
	.hang delay
	open "server":::"SOCKET"
	use "server":LISTEN=portno_":TCP"
	write /listen(clicount)
	do checkpoint(actor,9,"client has finished",5)
	lock +(^wait):5
	;
	write "# client summary",!
	set cpass=^client(portno,"pass")
	do sumpar
	write "pass: ",cpass,!
	set cfail=^client(portno,"fail")
	do sumpar
	write "fail: ",$select(cfail=0:"-",1:cfail),!
	lock -(^wait)
	quit
	;
sumpar  ; print parameters for summary
	write delay,"-",timeout,"-",clistretch," - number of clients "
	quit
	;
rstcc	; reset client counters
	;
	kill ^client(portno)
	set ^client(portno,"stuck")=0
	set ^client(portno,"pass")=0
	set ^client(portno,"fail")=0
	quit

client	; entry: client
	;
	lock +(^wait($job))
	set ^wait($job)=$job
	do procArgs
	do checkpoint(actor,1,"server start")
	do incc("stuck")
	;
	set pre=0.1
	write "# stretch client start in time, hang "
	write $justify(pre,0,2),".."
	write $justify(pre+clistretch,0,2)," sec",!
	if clicount=1 set spread=pre
	else  set spread=clistretch*(clino-1)/(clicount-1)+pre
	write "hanging ",$justify(spread,1,2),!
	hang spread
	;
	write "# attempt to connect with timeout=",timeout,!
	set before=$zhorolog
	set isset=(+timeout=timeout)
	set timeout=+timeout
	set expect=$select(delay'>timeout:"catch",1:"miss")
	set score=0
	;
	if isset open "client":(connect="127.0.0.1:"_portno_":TCP"):timeout:"SOCKET"
	if 'isset open "client":(connect="127.0.0.1:"_portno_":TCP")::"SOCKET"
	set after=$zhorolog
	;
	set $ztrap="set key="""" goto skipUseError"
	use "client"
	set key=$key
skipUseError ; skip error if USE "client" fails, we check for key=""
	set $ztrap=""
	do printKeyMasked
	zshow "d":zshd
	do printZshowDExtr
	do printElapsed(before,after)
	;
	set resolution=$select(score=3:"pass",1:"fail")
	do incc(resolution)
	write "# overall resolution",!
	write actor," score: ",score,"/3 - ",resolution,!
	;
	close "client"
	do checkpoint(actor,9,"client has finished")
	kill ^wait($job)
	lock -(^wait($job))
	quit
	;
incc(token) ; increment client counter for token
	;
	lock +^client(portno)
	if token'="stuck" set ^client(portno,"stuck")=^client(portno,"stuck")-1
	set ^client(portno,token)=1+^client(portno,token)
	lock -^client(portno)
	quit

getw	; entry: get first stuck process
	;
	write $order(^wait("")),!
	quit

killw	; entry: purge process from stuck list
	;
	kill ^wait($zcmdline)
	quit

procArgs ; process args ($ZCMDLINE)
	;
	set portno=$piece($zcmdline," ",1)
	set delay=$piece($zcmdline," ",2)
	set timeout=$piece($zcmdline," ",3)
	set actor=$piece($zcmdline," ",4)
	set clicount=$piece($zcmdline," ",5)
	set clino=$piece($zcmdline," ",6)
	set clistretch=$piece($zcmdline," ",7)
	quit

printKeyMasked ; print masked $KEY
	;
	new i
	use $principal
	write "# check $KEY value, first field should "
	if expect="catch" write "report ""ESTABLISHED""",!
	if expect="miss" write "be empty",!
	for i=2:1:3 do
	.if $length($piece(key,"|",i))>0 set $piece(key,"|",i)="<masked>"
	write "key=""",key,"""",!
	;
	if expect="catch"&(key'="") set score=1+score
	if expect="miss"&(key="") set score=1+score
	;
	quit

printZshowDExtr ; print ZSHOW "D" extract
	;
	new i,total
	use $principal
	write "# check ZSHOW ""D"" TOTAL value (number of open connections), should be "
	if expect="catch" write "above zero",!
	if expect="miss" write "zero",!
	set total="total=0" ; report "total=0" if not found
	for i=1:1 quit:$data(zshd("D",i))=0  do
	.if zshd("D",i)["TOTAL=" do
	..set total=$piece(zshd("D",i)," ",4)
	..if $piece(total,"=",2)>0 set $piece(total,"=",2)="<greater-than-zero>"
	write "ZSHOW ""D"" extract: ",total,!
	;
	set totalvalue=$piece(total,"=",2)
	if expect="catch"&(totalvalue'=0) set score=1+score
	if expect="miss"&(totalvalue=0) set score=1+score
	;
	quit

printElapsed(before,after) ; print elapsed time
	;
	new elapsed,min,error
	set elapsed=$$^difftime(after,before)
	set min=$select(delay<timeout:delay,1:timeout)
	write "# check elapsed time, it should be ",min," sec",!
	set error=""
	if elapsed<(min-1) set error="is below"
	if elapsed>(min+2) set error="exceeds"
	if error="" write "elapsed is around ",min," sec",!
	else  write "error: elapsed ",error," expected: ",elapsed,!
	;
	if error="" set score=1+score
	;
	quit

checkpoint(actor,id,comment,to) ; sync mechanism for multiple processes
	;
	set verbose=0
	set comment=$get(comment,"")
	set to=$get(to,60)
	if comment'="" set comment=" - "_comment
	use $principal
	if verbose write "# ",actor," entered checkpoint ",id,comment,!
	lock +(^checkpoint(portno))
	set ^checkpoint(portno,id)=1+$get(^checkpoint(portno,id),0)
	lock -(^checkpoint(portno))
	for i=1:1:to*10 quit:^checkpoint(portno,id)=^checkpoint(portno_"-count")  hang 0.1
	if verbose write "# ",actor," left checkpoint ",id,comment,!
	quit

chkset	; set checkpoint count
	;
	do procArgs
	set count=$piece($zcmdline," ",2)
	set ^checkpoint(portno_"-count")=count
	quit

chkrst	; reset checkpoint values
	;
	do procArgs
	kill ^checkpoint(portno)
	quit
