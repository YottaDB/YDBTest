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

readonly;
	set $ztrap="goto incrtrap^incrtrap"
	write "# Update a.dat through mumps.gld first",!
        set ^|"mumps.gld"|a=1
	write "# Update a.dat through x.gld next. This used to SIG-11 in r1.22",!
        set ^|"x.gld"|a=1
	quit
