;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
nooflow
	write:'("1"="8E49") "No overflow: =",!
	write:'("1"["8E49") "No overflow: [",!
	write:'("1"]"8E49") "No overflow: ]",!
	write:'("1"]]"8E49") "No overflow: ]]",!
	write:'("8E49"?8N) "No overflow: ?",!

	write:"1"'="8E49" "No overflow: '=",!
	write:"1"'["8E49" "No overflow: '[",!
	write:"1"']"8E49" "No overflow: ']",!
	write:"1"']]"8E49" "No overflow: ']]",!
	write:"8E49"'?8N "No overflow: '?",!
