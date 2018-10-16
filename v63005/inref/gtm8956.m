;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Invoke BADCHAR ERROR
	write "# Compile for BADCHAR ERROR"
	view "BADCHAR":"Yes"
	set c=$PIECE("Hello "_$ZCH(190)_" world!",$ZCH(191),1,2)

;Invoke BLKTOODEEP ERROR
	write "# Compile for BLKTOODEEP ERROR"
	. WRITE !," o  File to be imported does not exist: "_XOBPATH

;Invoke LITNONGRAPH ERROR
	write "Compile for LITNONGRAPH ERROR"
	write !,"This is an incorrect string literal	with a tab or something"
