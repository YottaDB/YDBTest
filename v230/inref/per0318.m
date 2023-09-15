;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
; Portions Copyright (c) Fidelity National			;
; Information Services, Inc. and/or its subsidiaries.		;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

per0318	;per0318 - Handle K @"" and N @""
	s ^c=0
	s zl=$zl,^zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1,zl="_zl_" w !,$zs zg @(zl_"":""_next)"
	s a=1
	; litnew
	n @""
	i '$d(a) s ^c=^c+1 w !,"variable not newed"
	;
	i '$d(a) s ^c=^c+1 w !,"variable missing on return from new"
	k @""
	i '$d(a) s ^c=^c+1 w !,"variable not killed"
	s x="",a=1
	; varnew
	n @x
	i '$d(a) s ^c=^c+1 w !,"variable not newed"
	;
	i '$d(a) s ^c=^c+1 w !,"variable missing on return from new"
	k @x
	i '$d(a) s ^c=^c+1 w !,"variable not killed"
	s x="",a=1
	; newx
	x "n @x"
	i '$d(a) s ^c=^c+1 w !,"variable missing on return from new"
	;
	x "k @x"
	i '$d(a) s ^c=^c+1 w !,"variable not killed"
	k x
	k @x s ^c=^c+1 w !,"undefined argument not detected by an indirect kill"
	n @n s ^c=^c+1 w !,"undefined argument not detected by an indirect new"
	s $zt=^zt
	w !,$s(^c:"BAD result",1:"OK")," from test of kill and new indirect null arguments"
	q
