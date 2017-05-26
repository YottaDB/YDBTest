;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jnlext(type,fld,pos,fname);
	; This program is to analyze journal detaled extract files
	;	Author: Mir Layek Ali
	;	Please consult for any suggestions or, improvement
	; type = JRT REC Type (say, AIMG)
	; fld = Which record from Journal extract (say, TN)
	; pos = Which postion has the fld (say, 4th postion is TN)
	; jnournal extract file name
	S $ZT="s $ZT="""" g ERROR"
	W !,"Get ",type," records from ",fname," : Field Position:",pos,!
	OPEN fname
	FOR  USE fname Q:$ZEOF  R rec  DO
	. if rec[type DO
	. .  SET blkid=$P(rec,"\",pos)
	. .  USE 0  Write fld," = ",blkid,!
	CLOSE fname
	q

ERROR   ;Log M error
        ;----------------------------------------------------------------------
        ;
        ZSHOW "*":^errmsg
        ZM +$ZS
        Q
