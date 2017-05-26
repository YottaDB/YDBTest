;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2004, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
slowfill(jobcnt);
	write "Starting slowfill.m at:",$zdate($horolog,"DD-MON-YEAR 24:60:SS"),!
	set fillid=+$ztrnlnm("gtm_test_dbfillid")
	set ^endloop(fillid)=0
	set jobid=$ztrnlnm("gtm_test_jobid")
	set ^%slowfill("trigger")=0
	set jmaxwait=0		; Child process(es) will continue in background. So do not wait, just return.
	do ^job("slowjob^slowfill",jobcnt,"""""")
	;
	; Wait for at least some update to be done.
	; This is because for standalone test we want to make sure shared memory is initalized before this returns
	do waitupd^slowfill
	write "Finishing slowfill.m at:",$zdate($horolog,"DD-MON-YEAR 24:60:SS"),!
	quit
slowjob;
	set fillid=+$ztrnlnm("gtm_test_dbfillid"),fillidC=fillid_","
	; For gtcm we cannot use TP at all, because it is not supported.
	set gtcm=+$ztrnlnm("gtm_test_is_gtcm")
	set ^%slowfill("gtcm",fillid)=gtcm
	set istp='gtcm
	set trigger=^%slowfill("trigger")
	; If triggers are enabled, then global {b,c,d,e,f,g,h,i}tpslowfilling will be updated by
	; triggers invoked as a result of updates to globals atpslowfilling. Hence those updates
	; need not be redone outside trigger. The below table indicates globals SET inside trigger
	; (a(<global>)=1 and globals SET outside trigger (a(<global>)=0
	if trigger do
	.	set trigupd("atpslowfilling")=0
	.	set trigupd("btpslowfilling")=1
	.	set trigupd("ctpslowfilling")=1
	.	set trigupd("dtpslowfilling")=1
	.	set trigupd("etpslowfilling")=1
	.	set trigupd("ftpslowfilling")=1
	.	set trigupd("gtpslowfilling")=1
	.	set trigupd("htpslowfilling")=1
	.	set trigupd("itpslowfilling")=1
	.	set trigupd("jtpslowfilling")=0
	.	set trigupd("ktpslowfilling")=0
	.	set trigupd("ltpslowfilling")=0
	write "Starting slowfill.m at:",$zdate($horolog,"DD-MON-YEAR 24:60:SS"),!
	set infloop=1000000
	set inc=+$ztrnlnm("gtm_test_wait_factor")
	if inc=0 set inc=1
	write "Process PID=",$j,!
	set templ1="abcdefghijkl"
	set startindex=1+$order(^lslowfilling(fillid,""),-1)
	for I=startindex:1:infloop do  quit:$get(^endloop(fillid),0)
	.	for vind=1:1:$length(templ1) do
	.	.	set var=$extract(templ1,vind,vind)_"slowfilling"
	.	.	set var="^"_var_"("_fillidC_I_")"
	.	.	set @var=I
	.	if istp do
	.	.	tstart ():(serial:transaction="ONLINE")
	.	.	for vind=1:1:$length(templ1) do
	.	.	.	set var=$extract(templ1,vind,vind)_"tpslowfilling"
	.	.	.	; If triggers are enabled, then ^atpslowfilling will invoke updates for global ^btpslowfilling, ^ctpslowfilling
	.	.	.	; If triggers are not enabled, then all the updates need to happen. Adjust the condition below accordingly
	.	.	.	if 'trigger!'trigupd(var) do
	.	.	.	.	set var="^"_var_"("_fillidC_I_")"
	.	.	.	.	set @var=I*I
	.	.	tcommit
	.	hang inc
	.	; Go to the sleep cycle if a ^pause is requested. Wait until ^resume is called
	.	do pauseifneeded^pauseimptp
	write "Job completion successful",!		; Some test may search for string "successful"
	write "Finishing slowfill.m at:",$zdate($horolog,"DD-MON-YEAR 24:60:SS"),!
	quit
	;
waitupd;
	set fillid=+$ztrnlnm("gtm_test_dbfillid"),fillidC=fillid_","
	set maxwait=600
	write "Process PID=",$j,!
	set var="^aslowfilling("_fillidC_""""")"
	set lastind=+$order(@var,-1)
	set var="^lslowfilling("_fillidC_""""")"
	for i=1:1:maxwait quit:+$order(@var,-1)>lastind  hang 1
	if i=maxwait write "TEST-E-SLOWFILL Test timed out. In ",maxwait," seconds no change in index = ",lastind,!
	quit
	;
verify;
	set fillid=+$ztrnlnm("gtm_test_dbfillid"),fillidC=fillid_","
	; For gtcm we cannot use TP at all, because it is not supported.
	set gtcm=^%slowfill("gtcm",fillid)
	set istp='gtcm
	;
	set templ1="abcdefghijkl"
	set maxerr=20
	set err=0
	;
	set var="^aslowfilling("_fillidC_""""")"
	set lastind=+$order(@var,-1)
	if lastind=0 write "TEST-E-SLOWFILL No data found for ^aslowfilling",!  halt
	; All globals should have same subscripts
	for vind=1:1:$length(templ1) do
	. set var=$extract(templ1,vind,vind)_"slowfilling"
	. set var="^"_var_"("_fillidC_""""")"
	. if +$order(@var,-1)'=lastind write "Verify fail: ",var," : last index expected ",lastind," found =",+$order(@var,-1),! Set err=err+1
	. if istp do
	. . set var=$extract(templ1,vind,vind)_"tpslowfilling"
	. . set var="^"_var_"("_fillidC_""""")"
	. . if +$order(@var,-1)'=lastind write "Verify fail: ",var," : last index expected ",lastind," found =",+$order(@var,-1),! Set err=err+1
	;
	; Verify all data
	for I=1:1:lastind do  quit:err>maxerr
	. for vind=1:1:$length(templ1) do
	. . set var=$extract(templ1,vind,vind)_"slowfilling"
	. . set var="^"_var_"("_fillidC_I_")"
	. . if $get(@var)'=I write "Verify fail: expected ",var,"=",I," found =",$get(@var),! set err=err+1
	. . if istp do
	. . . set var=$extract(templ1,vind,vind)_"tpslowfilling"
	. . . set var="^"_var_"("_fillidC_I_")"
	. . . if $get(@var)'=(I*I) write "Verify fail: expected ",var,"=",I*I," found =",$get(@var),! set err=err+1
	if err>maxerr write "Too many failure",!
	if err=0 write "Verify Pass",!
	q
