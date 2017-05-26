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
; Script to test whether MPROF correctly measures the time spent in ZSYSTEM calls and 
; PIPE operations. It is called as a part of D9L06002815 test.
subproc ;
	R input
	S option=input
	V "TRACE":1:"^subproctrc"
	S hor1=$H
	I option=1  D
	.	; do zsystem
	.	ZSY "$gtm_tst/$tst/u_inref/loop.csh > loop.out"
	E  D
	.	; do pipe
	.	O "loop":(command="$gtm_tst/$tst/u_inref/loop.csh")::"pipe"
	.	U "loop"
	.	F  R tmp Q:$zeof
	.	C "loop"
	.	U $P
	S hor2=$H
	V "TRACE":0:"^subproctrc"
	S run=^subproctrc("*RUN")
	S children=^subproctrc("*CHILDREN")
	S runtime=$P(run,":",3)
	S childrentime=$P(children,":",3)
	S total=runtime+childrentime
	W (total/1000000),!,hor1_" - "_hor2,!
	Q
