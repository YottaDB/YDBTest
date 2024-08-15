;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
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
        set max=start/(cnt)*(cnt+1)*(1.05)\1
        set result=$select(end<max:"PASS",1:"FAIL")
        write "Iteration ",cnt," : ",stat," gvstat : ",result
        if (result="FAIL") do
        . write " : Expected max = ",max," : Actual = ",end
        write !
        quit

