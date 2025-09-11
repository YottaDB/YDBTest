;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7552	;
	; Note: This test assumes there are 3 regions AREG, BREG, DEFAULT
	; where ^a* maps to AREG, ^b* maps to BREG and the rest maps to DEFAULT.
	;
	if (("AREG"'=$VIEW("REGION","^a"))!("BREG"'=$VIEW("REGION","^b"))) do
	. write "The assumptions that ^a* maps to AREG and ^b* maps to BREG is violated",!
	. write "^a* = ",$VIEW("REGION","^a"),!,"^b* = ",$VIEW("REGION","^b"),!
	. write "The test will exit now",!
	. halt
	set ^stop=0
	; Fill up blocks in AREG first
	if $r(2)=1  for i=1:1:1000 set ^a(i)=$j(i,200)	; induces TPFAIL with LLLJ because ^b's root block will end up being
							; a leaf level block in AREG.
	else        for i=1:1:10 set ^a(i)=$j(i,200)	; induces TPFAIL with LLLe because ^b's root block will be a huge value
							; that does not exist as a block in AREG.
	; Fill up blocks in BREG next
	; Create many GVTs ^b1, ^b2, etc. before creating ^b that way making ^b's root block be a high number in BREG.
	for i=1:1:85 set xstr="set ^b"_i_"=$j(i,200)" xecute xstr
	for i=1:1:100 set ^b(i)=$j(i,200)
	; DEFAULT region is used only for locks and so no need to fill it with data
	set jmaxwait=0
	do ^job("child^gtm7552",9,"""""")
	hang 15
	set ^stop=1
	do wait^job
	quit
child	;
	; This test spawns off 9 processese in total which are divied into 3 types.
	; 4 of "nontp" whose sole purpose is to induce restarts in the "tp" processes.
	; 4 of "tp" processes which are the ones that used to TPFAIL due to GTM-7552.
	; 1 of "dsecrit" process whose sole purpose is to grab crit randomly to help with reproducing GTM-7552.
	if jobindex<5  do nontp   quit
	if jobindex<9  do tp      quit
	if jobindex=9  do dsecrit quit
	quit
nontp   ;
	; Sole purpose of "nontp" is to induce restarts in the "tp" processes.
	for  quit:^stop=1  do
	.	set x=$incr(^a(jobindex))
	.	set x=$incr(^b(jobindex))
	.	set y=$incr(^c(jobindex))
	quit
tp      ;
	do sstep  ; to print $trestart at every M line executed inside of TP
		; with the bug, one would notice that $trestart changed but M code execution did not resume from after TSTART
		; This is the process that would fail with TPFAIL error before GTM-7552 was fixed.
	for  quit:^stop=1  do
	.	tstart ():serial
	.	set ^a(jobindex)=$get(^a(jobindex))+1
	.	set ^b(jobindex)=$get(^b(jobindex))+1
	.	lock ^c(jobindex)		; this is the lock name which mapped to a region (DEFAULT) where no other
	.					; database references happened inside the TP transaction and caused
	.					; the tp restart to try inserting DEFAULT into the tp_reg_list using tp_grab_crit.
	.					; We want that to fail hence have "dsecrit" process randomly getting crit in
	.					; DEFAULT so this tp_grab_crit will fail and cause us to retry which in turn
	.					; exposes the GTM-7552 bug (leading to the TPFAIL error).
	.	set x=$incr(^b(2*jobindex))	; this is the restart point where things used to not work correctly
	.	lock
	.	tcommit
	quit
dsecrit ;
	set dev="dse"
	open dev:(command="$gtm_dist/dse":exception="goto badopen")::"PIPE"
	use dev
	write "find -reg=DEFAULT",!
	; read/write find output from dse
	; The 8 lines of output will include the path to a.dat, Region AREG, blank line followed by DSE prompt then
	; the same information for mumps.dat and Region DEFAULT
	do readwrite(8,dev)
	for i=1:1 quit:^stop=1  do
	.	write "crit -seize",!
	.	; read 3 lines returned for each command sent
	.	; an example of the 3 lines returned for crit -seize is:
	.	; DSE>
	.	; Seized write critical section.
	.	;
	.	do readwrite(3,dev)
	.	hang $r(100)*0.001
	.	write "crit -release",!
	.	; read 3 lines returned for each command sent
	.	do readwrite(3,dev)
	close dev
	quit
readwrite(numlines,dev)
	for j=1:1:numlines read cmdres use $p  write cmdres,!  use dev
	quit
badopen
	use $p
	write !,"badopen error",!
	write $zstatus,!
	zshow "d"
	halt
sstep   ;
	set $zstep="set %zsaveio=$io use $p w:$x ! w $zpos,?11,"": $trestart="",$trestart,"" : "" zp @$zpos  use %zsaveio zstep into"
	zb sstep+3^gtm7552:"zstep into"
	set %zsaveio=$io use $p write !,"Stepping STARTED",!  use %zsaveio
