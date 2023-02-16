;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Helper M program used by r138/u_inref/ydb722.csh

ydb722	;
	quit

test1	;
	write "# Install SET/ZTRIGGER trigger for ^x1(i) to SET ^x2(i) to $H and HANG for 1 second inside trigger",!
	set X=$ztrigger("item","+^x1(index=:) -command=set,ztrigger -xecute=""set ^x2(index)=$H  hang 1""")
	do setx11
	write "# Run [ZTRIGGER ^x1(2)]"
	ztrigger ^x1(2)
	quit

zwrtest1;
	zwrite ^x1,^x2
	quit

test2a	;
	write "# Install SET trigger for ^x1(i) to do a $INCR(^x2(i))"
	set X=$ztrigger("item","+^x1(index=:) -command=set -xecute=""if $increment(^x2(index))""")
	quit

test2b	;
	do setx11
	quit

jnlflush	;
	view "JNLFLUSH"
	quit

setx11	;
	write "# Run [SET ^x1(1)=1]"
	set ^x1(1)=1
	quit

test3	;
	write "# Install SET/ZTRIGGER trigger for ^x1(i) to SET ^x2(i)",!
	set X=$ztrigger("item","+^x1(index=:) -command=set,ztrigger -xecute=""if $incr(^x2(index))""")
	do setx11
	write "# Run [ZTRIGGER ^x1(2)]"
	ztrigger ^x1(2)
	quit

test4	;
	write "# Test following scenarios",!
	write "# a) If the TP transaction has only ONE $ZTRIGGER/ZTRIGGER and NO database updates happened inside the trigger,",!
	write "#    then a NULL record should be replicated.",!
	write "# b) If the TP transaction has only ONE $ZTRIGGER/ZTRIGGER and at least ONE database update happened inside the trigger,",!
	write "#    then that database update should be replicated across (USET should be converted to TSET etc.) and no NULL record",!
	write "#    should be replicated.",!
	write "# c) If the TP transaction has more than ONE of the above and NO database updates happened inside the trigger,",!
	write "#    then a NULL record should be replicated.",!
	write "# d) If the TP transaction has more than ONE of the above and at least ONE database update happened inside the trigger,",!
	write "#    then that database update should be replicated across (USET should be converted to TSET etc.) and no NULL record",!
	write "#    should be replicated.",!
	if $ztrigger("item","+^x1(index=:) -command=set,kill -xecute=""set $ztwormhole=index,^x2(index)=1""")
	if $ztrigger("item","+^x1(index=:) -command=ztrigger -xecute=""set $ztwormhole=index,x2(index)=1""")
	set ^x1(1)=1
	ztrigger ^x1(1)
	tstart ():serial
	if $ztrigger("item","+^x3(index=:) -command=set -xecute=""set $ztwormhole=index,x3(index)=1""")
	ztrigger ^x3(1)
	if $ztrigger("item","+^x4(index=:) -command=set -xecute=""set $ztwormhole=index,x3(index)=1""")
	ztrigger ^x4(1)
	tcommit
	tstart ():serial
	if $ztrigger("item","+^x5(index=:) -command=set -xecute=""set $ztwormhole=index,x5(index)=1""")
	ztrigger ^x5(1)
	if $ztrigger("item","+^x6(index=:) -command=set -xecute=""set $ztwormhole=index,x6(index)=1""")
	ztrigger ^x6(1)
	kill ^x1(1)
	set ^x1(2)=2
	ztrigger ^x1(2)
	tcommit
	quit

