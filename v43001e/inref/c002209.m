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
c002209	;
        ; See C9D01-002209 for details
	; Test that LOCK, LOCK +, LOCK -, ZALLOCATE, ZDEALLOCATE accept extended reference syntax for nrefs in the form of locals
        ;
	set lkestr="$LKE show -all"
	lock +|"mumps.gld"|local1         zsy lkestr
        zallocate |"mumps.gld"|local3     zsy lkestr
	lock |"mumps.gld"|local2          zsy lkestr
	lock -|"mumps.gld"|local2         zsy lkestr
        zdeallocate |"mumps.gld"|local3   zsy lkestr
	quit
