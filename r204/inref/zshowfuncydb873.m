;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
level0  ;
	DO level1
	QUIT

level1  ;
	DO level2
	QUIT

level2  ;
	SET a="The quick brown fox",c="jumps over the lazy dog"
	ZWRITE $STACK  ; for debugging, verify that this is stack level 2
	DO print
	QUIT

print  ;
	SET n=2  ZSHOW "V":d:n  ZWRITE d
