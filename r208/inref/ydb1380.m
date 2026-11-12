;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; ZSTEP after a $ZTIMEOUT that expired, or after a MUPIP INTRPT (see r208/u_inref/zstep_queued_ztimeout-ydb1380.csh)
;
ydb1380	;
	quit
	;
	; Each case records what runs, in order, in "seq": "S@<place>" for a ZSTEP action, "Z@<place>" for the $ZTIMEOUT
	; vector, "J@<place>" for $ZINTERRUPT, "E@<place>=<mnemonic>" for an error and "L<n>" for line <n> of the case. Then
	; "done" compares "seq" with the value expected for the case.
	;
nofor	; A $ZTIMEOUT that expires at once, then ZSTEP INTO, and no FOR loop
	new seq
	set seq="",$ztimeout="0:set seq=seq_""Z@""_$zposition_"" """ zstep into:"set seq=seq_""S@""_$zposition_"" """
	set seq=seq_"L3 "
	set seq=seq_"L4 "
	do done("nofor",seq,"S@nofor+3^ydb1380 L3 Z@nofor+4^ydb1380 L4 S@nofor+5^ydb1380 S@done+2^ydb1380 ")
	quit
	;
for	; The same with a FOR loop on the line of the ZSTEP
	new seq,i,x
	set seq="",$ztimeout="0:set seq=seq_""Z@""_$zposition_"" """ zstep into:"set seq=seq_""S@""_$zposition_"" """  for i=1:1:3 set x=i
	set seq=seq_"L3 "
	set seq=seq_"L4 "
	do done("for",seq,"S@for+3^ydb1380 L3 Z@for+4^ydb1380 L4 S@for+5^ydb1380 S@done+2^ydb1380 ")
	quit
	;
nozstep	; Control: the same as nofor without the ZSTEP
	new seq
	set seq="",$ztimeout="0:set seq=seq_""Z@""_$zposition_"" """
	set seq=seq_"L3 "
	set seq=seq_"L4 "
	do done("nozstep",seq,"Z@nozstep+3^ydb1380 L3 L4 ")
	quit
	;
later	; After the $ZTIMEOUT of nofor, a later $ZTIMEOUT and a job interrupt
	new seq,i
	set $zinterrupt="set seq=seq_""J@""_$zposition_"" """
	set seq="",$ztimeout="0:set seq=seq_""Z@""_$zposition_"" """ zstep into:"set seq=seq_""S@""_$zposition_"" """
	set seq=seq_"L4 "
	set $ztimeout="0.5:set seq=seq_""Z2@""_$zposition_"" """
	for i=1:1:20 hang 0.1
	if $zsigproc($job,"SIGUSR1")
	for i=1:1:10 hang 0.1
	do done("later",seq,"S@later+4^ydb1380 L4 Z@later+5^ydb1380 S@later+6^ydb1380 Z2@later+6^ydb1380 S@later+7^ydb1380 J@later+8^ydb1380 S@later+9^ydb1380 S@done+2^ydb1380 ")
	quit
	;
jinofor	; A MUPIP INTRPT of this process, then ZSTEP INTO, and no FOR loop
	new seq
	set seq="",$zinterrupt="set seq=seq_""J@""_$zposition_"" """
	zsystem "$gtm_dist/mupip intrpt "_$job_" >& mupip_intrpt_jinofor.out" zstep into:"set seq=seq_""S@""_$zposition_"" """
	set seq=seq_"L4 "
	set seq=seq_"L5 "
	do done("jinofor",seq,"S@jinofor+4^ydb1380 L4 J@jinofor+5^ydb1380 L5 S@jinofor+6^ydb1380 S@done+2^ydb1380 ")
	quit
	;
jifor	; The same with a FOR loop on the line of the ZSTEP
	new seq,i,x
	set seq="",$zinterrupt="set seq=seq_""J@""_$zposition_"" """
	zsystem "$gtm_dist/mupip intrpt "_$job_" >& mupip_intrpt_jifor.out" zstep into:"set seq=seq_""S@""_$zposition_"" """  for i=1:1:3 set x=i
	set seq=seq_"L4 "
	set seq=seq_"L5 "
	do done("jifor",seq,"S@jifor+4^ydb1380 L4 J@jifor+5^ydb1380 L5 S@jifor+6^ydb1380 S@done+2^ydb1380 ")
	quit
	;
tpnofor	; A TP timeout ($ZMAXTPTIME) that expires during a ZSYSTEM, then ZSTEP INTO, and no FOR loop. The $ETRAP records the
	; error ("E@<place>=<mnemonic>"), rolls back the transaction, ends the ZSTEP and goes to the end of the case.
	new seq
	set seq="",$etrap="set seq=seq_""E@""_$zposition_""=""_$piece($piece($zstatus,"","",3),""-"",3)_"" "",$ecode="""" trollback:$tlevel  zstep into:""""  goto tpnofor+8"
	set $zmaxtptime=1 tstart ():serial zsystem "sleep 2" zstep into:"set seq=seq_""S@""_$zposition_"" """
	set seq=seq_"L5 "
	set seq=seq_"L6 "
	trollback:$tlevel
	do done("tpnofor",seq,"S@tpnofor+5^ydb1380 L5 E@tpnofor+6^ydb1380=TPTIMEOUT ")
	quit
	;
tpfor	; The same with a FOR loop on the line of the ZSTEP
	new seq,i,x
	set seq="",$etrap="set seq=seq_""E@""_$zposition_""=""_$piece($piece($zstatus,"","",3),""-"",3)_"" "",$ecode="""" trollback:$tlevel  zstep into:""""  goto tpfor+7"
	set $zmaxtptime=1 tstart ():serial zsystem "sleep 2" zstep into:"set seq=seq_""S@""_$zposition_"" """  for i=1:1:3 set x=i
	set seq=seq_"L4 "
	set seq=seq_"L5 "
	trollback:$tlevel
	do done("tpfor",seq,"S@tpfor+4^ydb1380 L4 E@tpfor+5^ydb1380=TPTIMEOUT ")
	quit
	;
done(case,seq,exp)
	set $ztimeout=-1
	write $select(seq=exp:"PASS",1:"FAIL")," : ",case," ran [",seq,"]",!
	write:seq'=exp "      expected [",exp,"]",!
	quit
