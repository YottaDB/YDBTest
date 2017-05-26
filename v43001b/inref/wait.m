;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wait	; waits till some updates go in to each of the regions AREG and BREG
	s done=0
	s timeout=180
	d getab(.astart,.bstart)
	;w "at beginning:",astart," ",bstart,!
	for tim=1:1:timeout q:done=1  d
	. h 1
	. d getab(.an,.bn)
	. if (an'=astart),(bn'=bstart) s done=1
	i tim=timeout d
	. w "TEST-E-TIMEOUT, waited for ",timeout," secs, but at least one of the regions were not updated",!
	. w " ^a at start:",astart," now:",an," ^b at start:",bstart," now:",bn
	q
getab(x,y) ;
	s x=$piece($piece($view("GVSTAT","AREG"),"SET:",2),",",1)
	s y=$piece($piece($view("GVSTAT","BREG"),"SET:",2),",",1)
	q
