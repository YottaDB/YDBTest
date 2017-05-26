;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a timestamp based on $h, adjusted by (+/-) deltaseconds seconds.
timestampdh(deltaseconds)
	set:'$data(deltaseconds) deltaseconds=+$zcmdline
	write $$FUNC(deltaseconds),!
	quit

; Return the adjusted timestamp as a string.
FUNC(deltaseconds)
	new dh,dayseconds,dhseconds
	set dh=$h,dayseconds=86400
	set dhseconds=($piece(dh,",",1)*dayseconds)+$piece(dh,",",2)+deltaseconds
	quit $zdate((dhseconds/dayseconds)_","_(dhseconds#dayseconds),"MON DD 24:60:SS")
