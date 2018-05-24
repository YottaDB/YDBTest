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
; Tests that ZSHOW "T" produces summary lines for "G" and "L"
;

gtm8804
	;accessing and locking in database to ensure ZSHOW "g" and "l" have at least one nonzero statistic
	set ^x=1
	lock ^x

	write "output for zshow g",!
	new g
	ZSHOW "G":g
	;filter out variable settings
	do out^zshowgfilter(.g,"CTN,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")
	ZWRITE g

	write !,"output for zshow l",!
	new l
	ZSHOW "L":l
	ZWRITE l

	write !,"output for zshow t (summary of g and l)",!
	new t
	ZSHOW "T":t
	;filter out variable settings
	do out^zshowgfilter(.t,"CTN,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT,BTD")
	ZWRITE t
	quit

