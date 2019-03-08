;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7522a;
	set ^stop=0,^proceed=0,^njobs=4
        for i=0:1:9 do
        . set xstr="set X=$ZTRIGGER(""ITEM"",""+^SAMPLE("_i_") -commands=S -xecute=""""w 123"""" -name=myname"_i_""")"
        . xecute xstr
	. if X=0 write "TEST-E-FAIL : Trigger addition using $ZTRIGGER failed unexpectedly. Exiting...",!  zwrite  halt
	set jmaxwait=0
	do ^job("child^gtm7522a",^njobs,"""""")
	; run the test for about 15 seconds (stop sooner if a failure is detected)
	for i=1:1:15  quit:^stop=1  hang 1
	set ^stop=1
	do wait^job
	quit
	;
child	;
	; out of ^njobs, one does selects and the others does insert/delete
	if jobindex=1 do select
	set i=9
        for  quit:^stop=1  do
	.	set i=((i+1)#10)
        .       set xstr="set X=$ZTRIGGER(""ITEM"",""-^SAMPLE("_i_") -commands=S -xecute=""""w 123"""" -name=myname"_i_""")"
        .       write xstr,!
        .       xecute xstr
	.	if X=0 write "TEST-E-FAIL : Trigger deletion using $ZTRIGGER failed unexpectedly. Exiting...",!  set ^stop=1 quit
        .       set xstr="set X=$ZTRIGGER(""ITEM"",""+^SAMPLE("_i_") -commands=S -xecute=""""w 123"""" -name=myname"_i_""")"
        .       write xstr,!
        .       xecute xstr
	.	if X=0 write "TEST-E-FAIL : Trigger addition using $ZTRIGGER failed unexpectedly. Exiting...",!  set ^stop=1 quit
        quit
select	;
	new trignum,cycle,i,j,k,expect,seen,missing,error,misscnt,njobs,sfile,vfile
	set error=0,njobs=^njobs
	for i=1:1 quit:((^stop=1)!error)  do
	. ; redirect $ztrigger output to a file and verify output is transaction consistent
	. set sfile="select"_i_".log"
	. open sfile:(newversion)
	. use sfile
	. if '$ZTRIGGER("SELECT","*")  write "TEST-E-FAIL: $ZTRIGGER select * returned 0",!
	. close sfile
	. open sfile
	. use sfile
	. set j=0 for  read line($incr(j))  quit:$zeof
	. if line(j)="" kill line(j) set j=j-1	; remove empty last line
	. set vfile="verify"_i_".log"
	. open vfile:(newversion)
	. use vfile
	. ; now that line() array contains all lines of trigger select output start verification
	. kill seen
	. for k=1:1:j  do
	. . ; output is of the following form
	. . ;	;trigger name: myname2 (region DEFAULT)  cycle: 146
	. . ;	+^SAMPLE(2) -name=myname2 -commands=S -xecute="w 123"
	. . if k=1 set cycle=$piece(line(k)," ",8)
	. . if k#2=1 do
	. . . set trignum=$piece($piece(line(k)," ",3),"myname",2)
	. . . if $data(seen(trignum)) do
	. . . . write "TEST-E-FAIL: Saw trigger number ",trignum," more than once in same output",!  set error=1
	. . . set seen(trignum)=""
	. . . set expect=";trigger name: myname"_trignum_" (region DEFAULT)  cycle: "_cycle
	. . else     set expect="+^SAMPLE("_trignum_") -name=myname"_trignum_" -commands=S -xecute=""w 123"""
	. . if line(k)'=expect do
	. . . write "TEST-E-FAIL: Line ",k," of $ZTRIGGER select output is incorrect",! zwrite line(k),expect set error=1
	. if k#2=1 write "TEST-E-FAIL: Odd number of lines seen in $ZTRIGGER select output",! set error=1
	. ; compute what is missing. we allow max of 1 missing
	. kill missing
	. set misscnt=0
	. for k=1:1:(j/2) if '$data(seen(k)) set missing(k)="" if $incr(misscnt)
	. ; Out of njobs jobs, one of them does the select (this one). The rest could be deleting at most 1 trigger
	. ; and so we expect at most (njobs - 1) triggers to be missing from the original list.
	. if (misscnt>(njobs-1))  do
	. . write "TEST-E-FAIL: Missing more than ",njobs-1," triggers. List of missing numbers follows",! set error=1
	. . zwrite missing
	. if error=0 close vfile:Delete,sfile:Delete
	. else       close vfile,sfile
	if error=1  set ^stop=1
	quit

