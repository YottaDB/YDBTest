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
; YDB#1284 : VIEW "STP_GCOL_FREE" returns the physical memory of the unused part of the stringpool,
; and the free pages in the C library heap, to the operating system.
;
; Each stage is run in its own process by stp_gcol_free-ydb1284.csh, so every stage starts from a
; new stringpool. $zcmdline is "<VIEW keyword> <STP_GCOL_NOSORT value> <keep>", where <keep> is 1 to
; keep enough strings that the garbage collection cannot shrink the stringpool, and 0 to keep none.
;
; A stage sets 20000 local variable nodes to 1000-byte strings, which expands the stringpool several
; times, KILLs all but the kept nodes, and runs the VIEW. Memory use is VmRSS from /proc/self/status,
; in KiB.
;
; A garbage collection shrinks the stringpool when it leaves more than 1 MiB of it unused above the
; level that triggers the next collection. That level is three times the space in use, raised if
; need be to leave 16 bytes free for each local variable node slot the collection walked. How far the
; stringpool expands while it fills varies, so the nodes kept are computed from its size: with a
; third of the stringpool still in use, the level is at least the stringpool size, so the size is
; unchanged and the stage measures what the VIEW itself returns to the operating system. With none
; kept, the space reserved for the node slots sets the level, far below the stringpool size, so the
; stringpool shrinks.
;
; STP_GCOL_FREE is a VIEW command keyword only. The keyword table is shared by the VIEW command and
; the $VIEW() function, so fnview checks that $VIEW() rejects it.
;
ydb1284	;
	write "Run one label at a time. See stp_gcol_free-ydb1284.csh",!
	quit
	;
free	; Fill, KILL and VIEW, then check the stringpool size and how much memory is still resident
	new kw,nosort,keep,k,n,i,start,filled,after,growth,killed,detail,sp1,sp2,x,bad
	set kw=$piece($zcmdline," ",1),nosort=$piece($zcmdline," ",2),keep=$piece($zcmdline," ",3),n=20000
	view "STP_GCOL_NOSORT":nosort
	set start=$$rss
	for i=1:1:n set x(i)=$justify(i,1000)
	set filled=$$rss,growth=filled-start
	do chk(growth'<(n*1000\1024),"filling "_n_" nodes with 1000-byte strings added at least "_(n*1000\1024)_" KiB to VmRSS","start "_start_", filled "_filled)
	; Keep k nodes: none, or 1000-byte strings adding up to a third of the stringpool size
	set k=$select(keep:$piece($view("SPSIZE"),",",1)\3000+1,1:0)
	for i=(k+1):1:n kill x(i)
	set killed=growth*(n-k)\n	; the part of what the fill added that the KILLed strings used
	set sp1=$piece($view("SPSIZE"),",",1)
	view kw
	set sp2=$piece($view("SPSIZE"),",",1)
	set after=$$rss,detail="start "_start_", filled "_filled_", after VIEW "_after
	if 'keep do
	. do chk(sp2<sp1,"piece 1 of $VIEW(""SPSIZE"") (stringpool size) is smaller after VIEW """_kw_""" than before it","before "_sp1_", after "_sp2)
	. do chk((after-start)<(growth/4),"VmRSS after VIEW """_kw_""" is back within a quarter of what the fill added",detail)
	else  do
	. do chk(sp2=sp1,"piece 1 of $VIEW(""SPSIZE"") (stringpool size) is the same after VIEW """_kw_""" as before it","before "_sp1_", after "_sp2)
	. if "STP_GCOL_FREE"=kw do chk((filled-after)>(killed*3/4),"VIEW """_kw_""" released more than three quarters of what the KILLed strings used",detail)
	. else  do chk((filled-after)<(killed/4),"VIEW """_kw_""" released less than a quarter of what the KILLed strings used",detail)
	; Use the memory again, including any pages that were returned to the operating system
	for i=1:1:n set x(i)=$justify(i,1000)
	set bad=0
	for i=1:1:n if x(i)'=$justify(i,1000) set bad=i quit
	do chk('bad,"all "_n_" nodes hold the expected value after they are set again","node "_bad_" is "_$get(x(bad)))
	quit
	;
fnview	; $VIEW("STP_GCOL_FREE") issues VIEWFN
	new x,got
	set got=""
	new $etrap set $etrap="set got=$piece($zstatus,"","",3) set $ecode="""" goto fnviewd"
	set x=$view("STP_GCOL_FREE")
fnviewd	;
	do chk("%YDB-E-VIEWFN"=got,"$VIEW(""STP_GCOL_FREE"") issues VIEWFN",$select(""=got:"no error, returned "_$get(x),1:$zstatus))
	quit
	;
rss()	; VmRSS of this process in KiB. The value in /proc/self/status is padded with tabs and spaces.
	new f,line,rss
	set f="/proc/self/status",rss=""
	open f:readonly
	use f
	for  read line quit:$zeof  if $extract(line,1,6)="VmRSS:" set rss=+$translate($piece(line,":",2),$char(9,32))
	close f
	use $principal
	quit rss
	;
chk(ok,what,detail)
	; The actual values depend on the build and the environment, so they appear only when a check fails.
	write $select(ok:"PASS",1:"FAIL")," : ",what
	write:'ok " (",detail,")"
	write !
	quit
