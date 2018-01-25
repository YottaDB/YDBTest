;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

exctst	; test some exception cases (EXCEPTION, ZREAK actions and $ZSTEP) for desired behavior
	; Also set bad exception in OPEN command, and trigger it as a secondary error in later USE, READ or WRITE command.
	w !,"Starting $ZL=",$ZL,!
	s $ZT="USE $P W !,$ZS,!,""$ZL="",$ZL,! ZG "_$ZL_":base+tst^"_$T(+0)
base	i $i(tst) O "/barfoo/foobar":(READONLY:EXCEPTION="do fubar")
	i $i(tst) set unix=$ZVERSION'["VMS",file="exctst.file"
	i $i(tst) if unix  zsystem "rm -f "_file zsystem "touch "_file
	i $i(tst) if 'unix zsystem "create "_file
	i $i(tst) O file:(READONLY:EXCEPTION="do fubar")  use file
ubase	i $i(tst) use file:(EXCEPTION="do fubar":LENGTH="-1")
read	i $i(tst) use file:(EXCEPTION="do fubar") read x
write	i $i(tst) use file:(EXCEPTION="do fubar") write x
zbt0	i $i(tst) use $p ZB zbt1:"badzbreak"
zbt1	i $i(tst) ZB zbt2:"ZST" S $ZSTEP="",$ZSTEP="badztep"
zbt2	i $i(tst) ZB zbt3:"ZST" S $ZSTEP="D nolab"
zbt3	i $i(tst)
	i $i(tst)
	quit
