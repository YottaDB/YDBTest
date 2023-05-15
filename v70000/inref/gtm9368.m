;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; These are helper functions for testing v70000/gtm9368.
;
; timdiff: Diff of a start and end time - return elapsed time between the two
timediff
	new starttime,endtime
	set starttime=$zpiece($zcmdline," ",1)
	set endtime=$zpiece($zcmdline," ",2)
	set elapsetime=$$^difftime(starttime,endtime)
	write elapsetime
	quit
