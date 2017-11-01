;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
waitforglobal	;
	for i=1:1 set gbl=$order(^%) quit:gbl'=""  hang 1
	; record the gbl name seen in case needed later for debugging
	set file="waitforglobal_dbg"_$j_".out"
	open file use file
	write "# "_$zdate($horolog,"24:60:SS")_" : "_gbl
	close file
	quit
