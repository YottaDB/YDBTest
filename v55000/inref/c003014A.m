;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ep1()
	Do ep2^c003014()
	Quit

ep2()
	Do ep3^c003014()
	Quit

ep3(a,b)
	Do ep4^c003014()
	Quit

;
; In this top stack level, do a read which:
;
;   1) Sets the restore_pc/ctxt.
;   2) Hopefully looks for the CTRAP and responds appropriately
;
ep4()
	Use $Principal:(NOCENABLE:CTRAP=$Char(3))
	Write $zsigproc($Job,2) Hang 10		; send sigint to avoid having to rely on expect
	Write !,"No trap"
	Quit
