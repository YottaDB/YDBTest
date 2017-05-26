;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8481	; do a mean thing to a database to see that MUPIP INTEG -FAST -ONONLINE does not explode
	; this sets up a state that's easy to turn evil
	for v="^x","^y" for i=1:1:2048 set @v@(i_$justify("*",50))=$justify(i,220)
	set v="^x" for i=1.5:150:2200 set @v@(i_$justify("*",50))=$justify(i,220)
	halt
