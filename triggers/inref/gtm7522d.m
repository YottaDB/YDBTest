;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7522d ;
        for i=1:1:10 do
        .       set xstr="set X=$ZTRIGGER(""ITEM"",""+^SAMPLE("_i_") -commands=S -xecute=""""w 123"""" -name=myname"_i_""")"
        .       ; write xstr,!
        .       xecute xstr
	set jmaxwait=0,^stop=0,^njobs=8 set:'$data(jobid) jobid=1
	do ^job("child^gtm7522d",^njobs,"""""")
	hang 15
	set ^stop=1
	do wait^job
	; Since this test does not operate under the supplmentary instance framework, we don't have
	; access to the supplementary gvn masking. Kill the global to avoid an extract failure.
	kill ^%jobwait(jobid)
        quit

child	;
	if jobindex'=1 do add
	else           do delete
	quit

add	;
	set spec="+^unusedbyothersdummytrigger -name=triggername"_jobindex_" -commands=S -xecute=""do ^nothing"""
	for  quit:^stop=1  do
	. if $ztrigger("i",spec)
	. else  write "TEST-E-FAIL",!	; trigger insert should never fail even if trigger already exists
	. if (jobindex=8)&('$random(20))&$ztrigger("i","-*")
	quit

delete	;
	set njobs=^njobs
	for  quit:^stop=1  do
	. for i=1:1:njobs do
	. . if $ztrigger("i","-triggername"_i)
	quit

remote	; On the remote supplementary instance, JOB off the conflict process and return
	set jobid=9
	job ^gtm7522d:(output="remote.mjo":error="remote.mje":PASSCURLVN)
	set ^remotepid=$zjob
	quit

	; Wait for the remote process to exit and kill ^remotepid to avoid extract differences
remotewait
	do ^waitforproctodie(^remotepid)
	kill ^remotepid
	quit
