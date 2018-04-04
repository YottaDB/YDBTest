;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2007, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
replwason;
	quit

init	;
	set $etrap="do ztr"
	quit

triginit;
	; Enable triggers if -trigger was specified & platform supports triggers
	set trigger=(0'=+$ztrnlnm("gtm_test_trigger"))
	quit

start	;
	set jmaxwait=0
	set ^threads=5
	set ^stop=0
	do ^job("run^replwason",^threads,"""""")
	quit

trig1	; invoked by a triggering update in run^replwason (see replwason.trg for trigger definitions)
	; "jobindex" and "i" will be set at trigger entry
	;
	new refer,rand
	new ztlevel,ztriggerop,ztval
	set xstr="set ztlevel=$ztlevel,ztriggerop=$ztriggerop,ztval=$ztval"
	xecute xstr   ; use indirection so this code compiles fine on non-trigger supported platforms
	if (ztlevel=1) do
	.	set refer=$reference
	.	if (ztriggerop="S") do
	.	.	if (refer=("^a("_jobindex_","_i_")"))  set ^b(jobindex,i)=ztval
	.	.	if (refer=("^b("_jobindex_","_i_")"))  set ^c(jobindex,i)=ztval
	.	.	if (refer=("^c("_jobindex_","_i_")"))  set ^a(jobindex,i)=ztval
	.	if (ztriggerop="K") do
	.	.	if (refer=("^a("_jobindex_","_i_")"))  kill ^b(jobindex,i)
	.	.	if (refer=("^b("_jobindex_","_i_")"))  kill ^c(jobindex,i)
	.	.	if (refer=("^c("_jobindex_","_i_")"))  kill ^a(jobindex,i)
	if (ztlevel=2) do
	.	set refer=$reference
	.	if (ztriggerop="S") do
	.	.	if (refer=("^b("_jobindex_","_i_")"))  set ^c(jobindex,i)=ztval
	.	.	if (refer=("^c("_jobindex_","_i_")"))  set ^a(jobindex,i)=ztval
	.	.	if (refer=("^a("_jobindex_","_i_")"))  set ^b(jobindex,i)=ztval
	.	if (ztriggerop="K") do
	.	.	if (refer=("^b("_jobindex_","_i_")"))  kill ^c(jobindex,i)
	.	.	if (refer=("^c("_jobindex_","_i_")"))  kill ^a(jobindex,i)
	.	.	if (refer=("^a("_jobindex_","_i_")"))  kill ^b(jobindex,i)
	; Randomly test that kills of same global outside AND inside trigger work fine
	; In the below case, an example kill pattern would be
	;   $ztlevel=0 : kill ^a(jobindex,i)
	;   $ztlevel=1 : kill ^b(jobindex,i)
	;   $ztlevel=2 : kill ^c(jobindex,i)
	;   $ztlevel=3 : kill ^a(jobindex,i)
	; ^a is being killed in $ztlevel=0 as well as $ztlevel=3.
	set rand=$r(100)
	if ((rand=50)&(ztlevel=3)) do
	.	set refer=$reference
	.	if (ztriggerop="K") do
	.	.	if (refer=("^c("_jobindex_","_i_")"))  kill ^a(jobindex,i)
	.	.	if (refer=("^a("_jobindex_","_i_")"))  kill ^b(jobindex,i)
	.	.	if (refer=("^b("_jobindex_","_i_")"))  kill ^c(jobindex,i)
	quit

run	;
	set updsize=150
	set waittime=0
	set unix=0
	if ($zv'["VMS"=1) set unix=1 set updsize=4*updsize	; to account for increased autoswitch size on UNIX
	new imod,istp
	do init
	do triginit ; initializes "trigger" variable as appropriate
	if unix do
	.	do init^zpeekhelper
	.	set jnlpool=$$fetchfld^zpeekhelper("Jpcrepl","jnlpool_ctl_struct.jnlpool_size","U")
	.	write "Journal pool:  ",jnlpool,!
	.	set limit=(jnlpool*0.75)\1	; pause a bit when 75% of journal pool is used
	for i=0:1  quit:^stop=1  do
	.	if unix do
	.	. 	set readaddr=$$fetchfld^zpeekhelper("GSlrEPL:"_0,"gtmsource_local_struct.read_addr","U")
	.	. 	set rsrvwriteaddr=$$fetchfld^zpeekhelper("Jpcrepl","jnlpool_ctl_struct.rsrv_write_addr","U")
	.	. 	set poolused=rsrvwriteaddr-readaddr
	.	. 	if (poolused>limit) do
	.	. 	.	set waittime=waittime+1
	.	. 	.	write "Journal pool used :  ",poolused,!
	.	. 	.	write "slowing down updates a bit. hang for : ",waittime,!
	.	. 	.	hang waittime
	.	. 	else  set waittime=0
	.	set istp=(i#4>1)
	.	if istp tstart ():serial
	.	if 'trigger  set (^a(jobindex,i),^b(jobindex,i),^c(jobindex,i))=$j(i,updsize)
	.	else  do
	.	.	set imod=i#3
	.	.	if imod=0  set ^a(jobindex,i)=$j(i,updsize)
	.	.	if imod=1  set ^b(jobindex,i)=$j(i,updsize)
	.	.	if imod=2  set ^c(jobindex,i)=$j(i,updsize)
	.	if istp tcommit
	.	if istp tstart ():serial
	.	if (i#2=1) do
	.	.	if 'trigger  kill ^a(jobindex,i),^b(jobindex,i),^c(jobindex,i)
	.	.	else  do
	.	.	.	set imod=i#6
	.	.	.	if imod=1  kill ^a(jobindex,i)
	.	.	.	if imod=3  kill ^b(jobindex,i)
	.	.	.	if imod=5  kill ^c(jobindex,i)
	.	if istp tcommit
	set ^jobindex(jobindex)=i-1
	quit

allverify;
	do verify
	do ver
	quit

verify	;
	set updsize=150
	if ($zv'["VMS"=1) set updsize=4*updsize	; to account for increased autoswitch size on UNIX
	for i=1:1:^threads  do
	.	set max=^jobindex(i)
	.	for j=0:2:max  do
	.	.	if ^a(i,j)'=$j(j,updsize)  write "TOPVERIFY-FAIL",!  zshow "*"  halt
	.	for j=1:2:max  do
	.	.	if $data(^a(i,j))'=0  write "TOPVERIFY-FAIL",!  zshow "*"  halt
	write "Verification PASS",!
	quit

stop	;
	set ^stop=1	; signals all jobbed of processes running to stop
	do wait^job	; waits for all jobbed of processes to die
	quit

set1	;
	set start=1
	do set
	quit

set2	;
	set start=2
	do set
	quit

trig2	; invoked by a triggering update in set^replwason (see replwason.trg for trigger definitions)
	; "i" will be set at trigger entry
	;
	new refer
	new ztlevel,ztriggerop,ztval
	set xstr="set ztlevel=$ztlevel,ztriggerop=$ztriggerop,ztval=$ztval"
	xecute xstr   ; use indirection so this code compiles fine on non-trigger supported platforms
	if (ztlevel=1) do
	.	set refer=$reference
	.	if (ztriggerop="S") do
	.	.	if (refer=("^aps("_i_")"))  set ^bps(i)=ztval
	.	.	if (refer=("^bps("_i_")"))  set ^cps(i)=ztval
	.	.	if (refer=("^cps("_i_")"))  set ^aps(i)=ztval
	.	if (ztriggerop="K") do
	.	.	if (refer=("^aps("_i_")"))  kill ^bps(i)
	.	.	if (refer=("^bps("_i_")"))  kill ^cps(i)
	.	.	if (refer=("^cps("_i_")"))  kill ^aps(i)
	if (ztlevel=2) do
	.	set refer=$reference
	.	if (ztriggerop="S") do
	.	.	if (refer=("^bps("_i_")"))  set ^cps(i)=ztval
	.	.	if (refer=("^cps("_i_")"))  set ^aps(i)=ztval
	.	.	if (refer=("^aps("_i_")"))  set ^bps(i)=ztval
	.	if (ztriggerop="K") do
	.	.	if (refer=("^bps("_i_")"))  kill ^cps(i)
	.	.	if (refer=("^cps("_i_")"))  kill ^aps(i)
	.	.	if (refer=("^aps("_i_")"))  kill ^bps(i)
	quit

set	;
	set updsize1=10,updsize2=20
	if ($zv'["VMS"=1) set updsize1=4*updsize1,updsize2=4*updsize2	; to account for increased autoswitch size on UNIX
	do triginit ; initializes "trigger" variable as appropriate
	if 'trigger  do
	.	for i=start:2:10 set (^aps(i),^bps(i),^cps(i))=$j(i,updsize2)
	.	for i=start:4:10 kill ^aps(i),^bps(i),^cps(i)
	.	for i=start:4:10 tstart ():serial set (^aps(i),^bps(i),^cps(i))=$j(i,updsize1) tcommit
	.	for i=start:8:10 tstart ():serial kill ^aps(i),^bps(i),^cps(i) tcommit
	if trigger  do
	.	set cnt=0
	.	for i=start:2:10  do
	.	.	set cntmod=cnt#3
	.	.	if cntmod=0 set ^aps(i)=$j(i,updsize2)
	.	.	if cntmod=1 set ^bps(i)=$j(i,updsize2)
	.	.	if cntmod=2 set ^cps(i)=$j(i,updsize2)
	.	.	set cnt=cnt+1
	.	set cnt=0
	.	for i=start:4:10  do
	.	.	set cntmod=cnt#3
	.	.	if cntmod=0 kill ^aps(i)
	.	.	if cntmod=1 kill ^bps(i)
	.	.	if cntmod=2 kill ^cps(i)
	.	.	set cnt=cnt+1
	.	set cnt=0
	.	for i=start:4:10  do
	.	.	tstart ():serial
	.	.	set cntmod=cnt#3
	.	.	if cntmod=0 set ^aps(i)=$j(i,updsize1)
	.	.	if cntmod=1 set ^bps(i)=$j(i,updsize1)
	.	.	if cntmod=2 set ^cps(i)=$j(i,updsize1)
	.	.	tcommit
	.	.	set cnt=cnt+1
	.	set cnt=0
	.	for i=start:8:10  do
	.	.	tstart ():serial
	.	.	set cntmod=cnt#3
	.	.	if cntmod=0 kill ^aps(i)
	.	.	if cntmod=1 kill ^bps(i)
	.	.	if cntmod=2 kill ^cps(i)
	.	.	tcommit
	.	.	set cnt=cnt+1
	quit

ver	;
	set updsize1=10,updsize2=20
	if ($zv'["VMS"=1) set updsize1=4*updsize1,updsize2=4*updsize2	; to account for increased autoswitch size on UNIX
	for i=1:1:10 do
	.	if $get(^aps(i))'=$get(^bps(i)) write "VERIFY-E-FAIL : ^aps(",i,")'=^bps(",i,")",!
	.	if $get(^aps(i))'=$get(^cps(i)) write "VERIFY-E-FAIL : ^aps(",i,")'=^cps(",i,")",!
	if $get(^aps(1))'="" write "VERIFY-E-FAIL : ^aps(1)'=""""",!
	if $get(^aps(2))'="" write "VERIFY-E-FAIL : ^aps(2)'=""""",!
	if $get(^aps(9))'="" write "VERIFY-E-FAIL : ^aps(9)'=""""",!
	if $get(^aps(10))'="" write "VERIFY-E-FAIL : ^aps(10)'=""""",!
	if ^aps(3)'=$j(3,updsize2) write "VERIFY-E-FAIL : ^aps(3)'=""$j(3,"_updsize2_")""",!
	if ^aps(4)'=$j(4,updsize2) write "VERIFY-E-FAIL : ^aps(4)'=""$j(4,"_updsize2_")""",!
	if ^aps(7)'=$j(7,updsize2) write "VERIFY-E-FAIL : ^aps(7)'=""$j(7,"_updsize2_")""",!
	if ^aps(8)'=$j(8,updsize2) write "VERIFY-E-FAIL : ^aps(8)'=""$j(8,"_updsize2_")""",!
	if ^aps(5)'=$j(5,updsize1) write "VERIFY-E-FAIL : ^aps(5)'=""$j(5,"_updsize1_")""",!
	if ^aps(6)'=$j(6,updsize1) write "VERIFY-E-FAIL : ^aps(6)'=""$j(6,"_updsize1_")""",!
	quit

ztr	;
	write $ZSTATUS,!
	quit

