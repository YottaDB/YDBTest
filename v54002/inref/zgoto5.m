;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zgoto5	;
	; Make sure NEW'd variables unwind properly with ZGOTO 0
	;
	New i
	Set i=1
action
	Set ii=$Increment(i)
	ZWRite ii
	ZGoto:(3>ii) 0:action^zgoto5
	Write "DONE!",!
