;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	write "mumps.gld : ",^GBL,!
	set $ZGBLDIR="a"
	write "a.gld     : ",^GBL,!
	set $ZGBLDIR="b"
	write "b.gld     : ",^GBL,!
	write "; Test SET $ZGBLDIR=""T"" switches to mumps.gld but $ZGBLDIR still shows up as ""T""",!
	write "; We verify mumps.gld is current gld by checking value of ^GBL which should say THIS IS MUMPS in that case",!
	set $ZGBLDIR="T"
	write "  " zwrite ^GBL
	write "  " zwrite $ZGBLDIR
	write "; Test that $VIEW(GBLDIRXLATE) works.",!
	write "; Run [$VIEW(""GBLDIRXLATE"",""T"")] and verify it returns the expected [mumps].",!
	write "  ",$view("GBLDIRXLATE","T"),!
	quit
