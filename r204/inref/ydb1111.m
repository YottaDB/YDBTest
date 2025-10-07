;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ydb1111
	; File exists to give warning for newing a var multiple times on the same line.
	; This line should give the warning.
	new test1,test2,test1
	; This line should NOT give the warning even though test2 was newed on the previous line.
	new test2
	new a
	new a,b
	new @a,@a
	new @a,@b
	new @a,a
	new a,@a
	new a
	new $test,a,$test
	new a
	new test,$test
	new a,b,(a) ; This line should not give a warning as variables inside parentheses means to new every other variable.
	new a,b,(a,a)
	new a,(a),a
	new (a,a)
	new (@a,a)
	new (@a,@a)
	new a new a ; This counts as 2 separate commands, so no warning should be given.
	new a,(b)
	new a
	new b,b,b   ; This line should trigger 2 warnings.
	new a,b,a,b ; This line should trigger a warning for both a and b.
	QUIT
