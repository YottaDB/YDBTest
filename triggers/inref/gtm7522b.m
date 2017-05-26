;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7522b	;
	; below is a test that $ztrigger output is correct even in case of incremental rollbacks OR restarts
	tstart ():serial
	set i=0
        if $ZTRIGGER("ITEM","+^ROLLBACK("_$incr(i)_") -commands=S -xecute=""w 123"" -name=rollback"_i)
	do
	. tstart ():serial
        . if $ZTRIGGER("ITEM","+^ROLLBACK("_$incr(i)_") -commands=S -xecute=""w 123"" -name=rollback"_i)
	. trollback -1
	. do
	. . tstart ():serial
        . . if $ZTRIGGER("ITEM","+^ROLLBACK("_$incr(i)_") -commands=S -xecute=""w 123"" -name=rollback"_i)
	. . do
	. . . tstart ():serial
        . . . if $ZTRIGGER("ITEM","+^ROLLBACK("_$incr(i)_") -commands=S -xecute=""w 123"" -name=rollback"_i)
	. . . tcommit
	. . if $trestart<2 trestart
	. . trollback -1
	. do
	. . tstart ():serial
        . . if $ZTRIGGER("ITEM","+^ROLLBACK("_$incr(i)_") -commands=S -xecute=""w 123"" -name=rollback"_i)
	. . do
	. . . tstart ():serial
        . . . if $ZTRIGGER("ITEM","+^ROLLBACK("_$incr(i)_") -commands=S -xecute=""w 123"" -name=rollback"_i)
	. . . if $trestart<3 trestart
	. . . trollback -1
	. . tcommit
	. do
	. . tstart ():serial
        . . if $ZTRIGGER("ITEM","+^ROLLBACK("_$incr(i)_") -commands=S -xecute=""w 123"" -name=rollback"_i)
	. . do
	. . . tstart ():serial
        . . . if $ZTRIGGER("ITEM","+^ROLLBACK("_$incr(i)_") -commands=S -xecute=""w 123"" -name=rollback"_i)
	. . . tcommit
	. . tcommit
	tcommit
	quit

