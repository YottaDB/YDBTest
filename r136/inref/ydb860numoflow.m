;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

; Note: Below are various test cases that failed during fuzz testing. No pattern otherwise to these test cases.
; The below are tests based on https://gitlab.com/YottaDB/DB/YDB/-/issues/860#note_1208173286

 write (0!((-(+(-("1E47"))))))
 write (0!((-(+(-("1E47"))))))&(0!((-(+(-("1E47"))))))
 write (0!((-(+(-("1E47"))))))!(0!((-(+(-("1E47"))))))
 write (0!((-(+(-("1E47"))))))!'(0!((-(+(-("1E47"))))))
 quit

