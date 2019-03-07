;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	set jrisave=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_addrs.gvstats_rec.n_jrec_epoch_idle","DEFAULT"))
	write "Perform update SET ^x=1",!
        set ^x=1
	write "Sleep for 8 seconds to ensure an idle epoch gets written",!
	; "hang 8" below takes into account 1 second for flush timer + 5 seconds for idle epoch timer + 2 seconds for buffer
	hang 8
	write "Confirm an idle epoch did get written : "
	set jridelta=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_addrs.gvstats_rec.n_jrec_epoch_idle","DEFAULT"))-jrisave
	write "JRI gvstat increased by ",(jridelta>0),!
	write "Perform update SET ^x=2",!
        set ^x=2
	set jresave=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_addrs.gvstats_rec.n_jrec_epoch_regular","DEFAULT"))
	write "Sleep for anywhere from 1 to 5 seconds",!
	hang 1+$random(5)
	write "Perform update SET ^x=3",!
        set ^x=3
	write "Sleep for 1 second",!
	hang 1
	write "Perform update SET ^x=4",!
        set ^x=4
	write "Confirm a regular epoch got written in between updates ^x=2 and ^x=4 : "
	set jredelta=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_addrs.gvstats_rec.n_jrec_epoch_regular","DEFAULT"))-jresave
	write "JRE gvstat increased by ",(jredelta>0),!
        quit
