;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7327	;test TPNOTACID conditions
	;
	new (act)
	if '$data(act) new act set act="use $p write !,$zpos,! zprint @$zpos zshow ""*"""
	new $etrap
	set $ecode="",$etrap="goto err",zl=$zl
	set file="pid.txt"
	open file:newversion
	use file
	write $job,!
	close file
	kill ^childjob
	set x=+$ztrnlnm("gtm_zmaxtptime")
	if $select(x<60:x,1:0)'=$zmaxtptime,$increment(cnt) xecute act
	for i=1:1 set x=$piece($text(notacid+i),";",2) quit:""=x  do trans(x,1)
	kill ^childjob
	for i=1:1 set x=$piece($text(zerotime+i),";",2) quit:""=x  do trans(x,2)
	kill ^childjob
	write !,$select('$get(cnt):"No",1:"")," errors from ",$text(+0)
	quit
silly	lock ^silly			; Hold lock to aggravate the subsequent LOCK and ZALLOCATE commands
	set ^childjob=1
	write !,$job
	for i=1:1:90 quit:'$data(^childjob)  hang 1
	if 90=i write "YDB-E-TESTERROR, child timed out"
	write !,"finished"
	quit
trans(x,y)
	kill j
	tstart ():serial
	if 5<$increment(j) trollback  quit
	set ^a=$trestart
	if 3>$trestart trestart
	if $zsyslog("trans+6^gtm7327 : "_$translate(x,"^+\!","....")) xecute x
	lock
	close "silly.txt":delete
	zdeallocate ^silly
	tcommit:$tlevel
	quit:(x'["job")
	set ^jobid(y)=$zjob
	for k=1:1:90 quit:$data(^childjob)  hang 1	; HANG must be less than gtm_tpnotacidtime
	if 90=k write "YDB-E-TESTERROR, no evidence of JOB success",!
	quit
err	for lev=$stack:-1:0 quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set loc=$stack(lev,"PLACE"),next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
notacid
;break				;before read
;hang 3
;job silly::3
;lock ^silly:3
;open "silly.txt":newversion:3
;read !,"> ",r:3
;zallocate ^silly:3

zerotime
;hang 0
;job silly::0
;lock ^silly:0
;open "silly.txt":newversion:0
;zallocate ^silly:0
;zsystem "printf ""\ngtm7327"""
