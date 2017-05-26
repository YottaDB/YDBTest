;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8376g;
	; This is an  issue with $SELECT reported by Epic that caused a GTMASSERT2 when $gtm_side_effects=1
	;
	set A=$random(2),x=A!$s(1:2,^Global($s(1:2)):A)
	write "x = ",x,!
	quit
