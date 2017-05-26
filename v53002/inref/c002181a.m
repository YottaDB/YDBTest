;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2008, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EP8     WRITE !,"THIS IS ",$TEXT(+0)
	; Want to hit an error in the ZTRAP frame, not the ET frame. Make this happen by expanding the size of the ZTRAP frame,
	; which is achieved by newing many variables.
	SET VARS="V1" FOR I=1:1:500 SET VARS=VARS_",V"_I
        NEW $ZTRAP SET $ZTRAP="NEW "_VARS_" DO ET"
        KILL A
BAD     WRITE A
        WRITE !,"THIS IS NOT DISPLAYED"
        QUIT
ET      WRITE 2/0
        QUIT
