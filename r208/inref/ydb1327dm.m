;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; Direct mode cases for the r208/tp_restart_new-ydb1327 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1327dm
	quit

tpzcont
	;inp:"break"
	;inp:"tstart ()"
	;inp:"zcontinue"
	;inp:"write ""$tlevel="",$tlevel,!"
	;inp:"trollback:$tlevel"
	;has:TPQUIT
tpzcontnew
	;inp:"break"
	;inp:"tstart ()"
	;inp:"new"
	;inp:"new"
	;inp:"zcontinue"
	;inp:"write ""$tlevel="",$tlevel,!"
	;inp:"trollback:$tlevel"
	;has:TPQUIT
tptrestart
	;inp:"break"
	;inp:"tstart"
	;inp:"new"
	;inp:"new"
	;inp:"trestart"
	;has:TRESTNEW
trnewdm
	;inp:"set x=1"
	;inp:"break"
	;inp:"tstart (x) set x=2 new  set x=3 trestart:$trestart<1"
	;inp:"write ""after the TRESTART: x="",$get(x,""<undef>""),"" $tlevel="",$tlevel,!"
	;inp:"trollback"
	;inp:"write ""after TROLLBACK: $tlevel="",$tlevel,!"
	;has:after the TRESTART: x=3 $tlevel=1
	;has:after TROLLBACK: $tlevel=0
trnewdmimp
	;inp:"set x=1,^a=0 kill ^b"
	;inp:"break"
	;inp:"tstart (x) set x=2 new  set v=^a zsystem:$trestart<1 ""$gtm_dist/mumps -run %XCMD 'set ^a=5'"" set ^b=v tcommit"
	;inp:"write ""after the restart: $tlevel="",$tlevel,"" $trestart="",$trestart,!"
	;inp:"trollback"
	;inp:"write ""after TROLLBACK: $tlevel="",$tlevel,"" ^a="",^a,"" ^b="",$get(^b,""<undef>""),!"
	;has:after the restart: $tlevel=1 $trestart=0
	;has:after TROLLBACK: $tlevel=0 ^a=5 ^b=<undef>
trexdm
	;inp:"set x=1"
	;inp:"break"
	;inp:"tstart (x) set x=2 new (y)  set x=3 trestart:$trestart<1"
	;inp:"write ""after the TRESTART: x="",$get(x,""<undef>""),"" $tlevel="",$tlevel,!"
	;inp:"trollback"
	;has:after the TRESTART: x=3 $tlevel=1
trnewhdl
	;inp:"set x=1"
	;inp:"break"
	;inp:"tstart (x) set x=2 new  set x=3 do rst^ydb1327dm"
	;inp:"write ""after: $tlevel="",$tlevel,"" x="",$get(x,""<undef>""),!"
	;has:handler: TRESTNEW $tlevel=1
	;has:handler after TROLLBACK: $tlevel=0
	;has:after: $tlevel=0 x=3
zbrdm
	;inp:"set x=1"
	;inp:"do zbr^ydb1327dm"
	;inp:"write ""after the ZBREAK action: x="",$get(x,""<undef>""),"" $tlevel="",$tlevel,!"
	;inp:"trollback"
	;has:after the ZBREAK action: x=3 $tlevel=1
zstdm
	;inp:"set x=1"
	;inp:"do zst^ydb1327dm"
	;inp:"write ""after the ZSTEP action: x="",$get(x,""<undef>""),"" $tlevel="",$tlevel,!"
	;inp:"trollback"
	;has:after the ZSTEP action: x=3 $tlevel=1
nobrkdm
	;inp:"set x=1"
	;inp:"tstart (x) set x=2 new  set x=3 trestart:$trestart<1"
	;inp:"write ""after the TRESTART: x="",$get(x,""<undef>""),"" $trestart="",$trestart,"" $tlevel="",$tlevel,!"
	;inp:"trollback"
	;has:after the TRESTART: x=1 $trestart=1 $tlevel=1
ztodm
	;inp:"set x=1"
	;inp:"do zto^ydb1327dm"
	;inp:"write ""after the $ZTIMEOUT action: x="",$get(x,""<undef>""),"" $tlevel="",$tlevel,!"
	;has:in the $ZTIMEOUT action: x=3 $trestart=1 $tlevel=1
	;has:after the $ZTIMEOUT action: x=2 $tlevel=0
zindm
	;inp:"set x=1"
	;inp:"do zin^ydb1327dm"
	;inp:"write ""after the $ZINTERRUPT action: x="",$get(x,""<undef>""),"" $tlevel="",$tlevel,!"
	;has:in the $ZINTERRUPT action: x=3 $trestart=1 $tlevel=1
	;has:after the $ZINTERRUPT action: x=2 $tlevel=0
	;
zbr	; A ZBREAK action with TSTART (x), an argumentless NEW and TRESTART, for zbrdm
	zbreak zbr+2^ydb1327dm:"tstart (x) set x=2 new  set x=3 trestart:$trestart<1"
	quit
zst	; A ZSTEP action with TSTART (x), an argumentless NEW and TRESTART, for zstdm
	zstep into:"tstart (x) set x=2 new  set x=3 trestart:$trestart<1"
	zstep into
	quit
zto	; A $ZTIMEOUT action with TSTART (x), an argumentless NEW and TRESTART, for ztodm. Waits for the action to set ^done.
	new i
	kill ^done
	set $ztimeout="1:tstart (x) set x=2 new  set x=3 trestart:$trestart<1  do act^ydb1327dm(""$ZTIMEOUT"")"
	for i=1:1:600 quit:$data(^done)  hang 0.1
	quit
zin	; $ZINTERRUPT with TSTART (x), an argumentless NEW and TRESTART, for zindm. Waits for the action to set ^done.
	new i
	kill ^done
	set $zinterrupt="tstart (x) set x=2 new  set x=3 trestart:$trestart<1  do act^ydb1327dm(""$ZINTERRUPT"")"
	zsystem "/bin/sh -c '$gtm_dist/mupip intrpt "_$job_" >mupip_intrpt.out 2>&1'"
	for i=1:1:600 quit:$data(^done)  hang 0.1
	quit
act(what)	; Report the state after the restart, then end the transaction
	write "in the ",what," action: x=",$get(x,"<undef>")," $trestart=",$trestart," $tlevel=",$tlevel,!
	trollback
	set ^done=1
	quit
	;
rst	; TRESTART with an error handler, for trnewhdl
	new $etrap
	set $etrap="do hdl^ydb1327dm"
	trestart:$trestart<1
	write "rst: no error",!
	quit
hdl	; Error handler for trnewhdl: TROLLBACK the transaction the TRESTART left as it was
	write "handler: ",$piece($piece($zstatus,",",3),"-",3)," $tlevel=",$tlevel,!
	trollback
	write "handler after TROLLBACK: $tlevel=",$tlevel,!
	set $ecode=""
	quit
