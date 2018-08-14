;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm8708	;
	write "Since one needs crit to attempt an epoch, CAT gvstat (# of crit acquired total successes) is a good test of this",!
	write "Record CAT gvstat (# of crit acquired total successes) at start",!
	set catstart=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_crit_success","DEFAULT"))
	write "Wait for 5 seconds (i.e. 5 epoch intervals since epoch_interval is set to 1 second)",!
	hang 5
	write "Record CAT gvstat (# of crit acquired total successes) at end",!
	set catend=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_crit_success","DEFAULT"))
	write "Confirm CAT gvstat at start and end is identical (i.e. no unnecessary epoch attempts were made) : "
	write $select((catstart=catend):"PASS",1:"FAIL"),!
	quit
