;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.  ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb959	;
	set cnt=+$zcmdline
	do:cnt
	. set dwt1=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_dsk_write","DEFAULT"))
	. set dfs1=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_db_fsync","DEFAULT"))
	. set jfl1=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_jnl_flush","DEFAULT"))
	. set jfs1=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_jnl_fsync","DEFAULT"))
	. set jfb1=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_jfile_bytes","DEFAULT"))
	. set jfw1=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_jfile_writes","DEFAULT"))
	; Note: The below 2 lines are based on https://gitlab.com/YottaDB/DB/YDB/-/issues/959#description
	; But the "for" loop iteration count is cut down to 1/100th (1E7 -> 1E5) to reduce automated test runtime
	kill ^PSNDF
	for i=1:1:1E5 set ^PSNDF(50.6,i,"VUID")=$select(i#2:"A^B",1:"B^A")
	do:cnt
	. set dwt2=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_dsk_write","DEFAULT"))
	. set dfs2=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_db_fsync","DEFAULT"))
	. set jfl2=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_jnl_flush","DEFAULT"))
	. set jfs2=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_jnl_fsync","DEFAULT"))
	. set jfb2=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_jfile_bytes","DEFAULT"))
	. set jfw2=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_jfile_writes","DEFAULT"))
	. do verify(dwt1,dwt2,cnt,"DWT")
	. do verify(dfs1,dfs2,cnt,"DFS")
	. do verify(jfl1,jfl2,cnt,"JFL")
	. do verify(jfs1,jfs2,cnt,"JFS")
	. do verify(jfb1,jfb2,cnt,"JFB")
	. do verify(jfw1,jfw2,cnt,"JFW")
	quit

verify(start,end,cnt,stat)
	new ceil,pct,projection,allowance
	; "projection" is the linear growth model this check is built on : after "cnt" iterations the
	; counter reads "start", so one more iteration should add about "start"/"cnt".
	set projection=start/cnt*(cnt+1)
	; The projection is built from "cnt" iterations, so its uncertainty falls as 1/"cnt" : at
	; cnt=1 it comes from a single prior iteration. Allow 5% plus 25%/"cnt", and never less than
	; 5 counts. The subtest sets autoswitchlimit to one hundredth of the default
	; (jnlswitch_set_perf-ydb959.csh:31), which keeps these counters small enough that a
	; percentage band alone is worth less than a single count, and "n_jnl_fsync" is not a linear
	; function of the work done in any case, epochs being timer driven as well as autoswitch
	; driven. What this subtest guards against is the YDB#959 10x explosion, which still fails by
	; a wide margin.
	set pct=.05+(.25/cnt)
	set allowance=$select(projection*pct>5:projection*pct,1:5)
	; Round the ceiling UP : "\1" truncated the allowance downward, so the effective tolerance
	; was always below the intended one.
	set ceil=projection+allowance
	set max=$select(ceil=(ceil\1):ceil,1:ceil\1+1)
	; Compare with '> : "end<max" reported a FAIL for a value equal to the maximum it prints.
	set result=$select(end'>max:"PASS",1:"FAIL")
	write "Iteration ",cnt," : ",stat," gvstat : ",result
	if (result="FAIL") do
	. write " : Expected max = ",max," : Actual = ",end
	write !
	quit

