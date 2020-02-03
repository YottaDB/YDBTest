;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	write "access method = ",$view("gvaccess_method","default"),!
	set before=+$piece($view("gvstat","default"),"DRD:",2)
	write "DRD before = ",before,!
	for i=1:1:100 set x=$data(^X($random(1000*i)))
	set after=+$piece($view("gvstat","default"),"DRD:",2)
	write "DRD after = ",after,!
	QUIT
