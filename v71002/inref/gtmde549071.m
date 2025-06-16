;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

blocksProcessed ;
	set blks=$ZTRNLNM("ydb_test_4g_db_blks")
	set:blks<1 blks=1
	for i=0:1:511 write "dump -block=",$$FUNC^%DH(i)," -header",!
	; Skip over unused blocks created when ydb_test_4g_db_blks is set
	for i=(512*blks):1:$$^%PEEKBYNAME("sgmnt_data.trans_hist.total_blks","DEFAULT")-1 write "dump -block=",$$FUNC^%DH(i)," -header",!
	quit
