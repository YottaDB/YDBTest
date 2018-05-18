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
;
gtm8914
	WRITE "$VIEW(""GVSTATS"",""DEFAULT"")
	$VIEW("GVSTATS","DEFAULT"), ZSHOW "G" and ZSHOW "T"
	$VIEW("GVSTATS","BREG"), ZSHOW "G" and ZSHOW "T"

	ZSHOW "G"

	ZSHOW "T"
