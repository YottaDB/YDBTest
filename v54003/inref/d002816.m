;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
d002816 ;
	; Test if op_gvrectarg keeps first_sgm_info & sgm_info_ptr in sync in case of JOB INTERRUPT
	; Ensure the test runs for not a lot longer than 10 seconds.
	; The key is that ^a and ^b be mapped to DIFFERENT regions
	;
	set ^stop=0
	set ^sleepinseconds=10	; time that test will take to run
	kill ^mumpspid
	do ^job("child^d002816",2,"""""")
	quit
	;
child	;
	do @jobindex
	quit
1	;
	set ^mumpspid=$job
	set $zint="do zintr"
	set areg=$VIEW("REGION","^a")
	set breg=$VIEW("REGION","^b")
	; areg and breg could be a LIST of regions if ^a and/or ^b span multiple regions.
	; do not allow this case as it makes things more complicated than necessary.
	if (($zfind(areg,","))!($zfind(areg,","))!(areg=breg)) do
	.	write "^a and ^b should be non-spanning and map to different regions. Exiting...",!
	.	halt
	set sleepinseconds=^sleepinseconds
	for i=1:1:(sleepinseconds*10) do
	.	tstart ():serial
	.	hang 0.1
	.	set ^a(i)=i
	.	tcommit
	quit
2	;
	for  quit:$data(^mumpspid)  hang 0.1
	set pidtointrpt=^mumpspid
	for i=1:1 quit:$$^isprcalv(pidtointrpt)=0  do
	.	set cmd="$gtm_dist/mupip intr "_pidtointrpt_" >& mupipintrpt"_i_".out"
	.	zsystem cmd
	quit
zintr	;
	if $zjobexam()
	set x=$incr(^b)
	quit
