;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2003-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c001511 ;
	f i=1:1:10 d
	. set ^x=$j(1,32500)
	. k ^x
	. set ^y=$j(1,32500)
	. k ^y
	. zsystem "$DSE buff"	; to write an epoch record
	. set ^x=$j(1,32500)	; this will cause a nearly 32K size PBLK record
	. set ^y=$j(1,32500)
	quit

