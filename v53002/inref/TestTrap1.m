;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2008, 2014 Fidelity Information Services, Inc	;
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
TestTrap1
	set cnt=0
	s $zyerror="ZYERROR^TestTrap1"
	s $ZT="do TrapErr"
	K ^ET,^IL,^L,^ZT
	s (^ET,^IL,^L,^ZT)=0
	d TT1
	q

TT1	n $zt ; Setting $ET does not save $ZT to the stack so do it here
	s $ET="g TrapCmd"
	w !,"$ST Level of Set $ET: ",$st,!
	d FSErr(1,$G(hide))
	w !,"done"
	q

TrapErr	i $I(^ZT) s ^ZT($st,$I(^ZT($st)))=$ZE
	w !!,"$ZT at the end",!
	s $ec=""
	q

TrapCmd	i $I(^ET) s ^ET($st,$I(^ET($st)))=$ZE
	d
	. i $I(^IL)
	q

FSErr(int,hide)
	n test
	s test=int+1
	s ^L=test
	d FSErr(test,hide)
	q

ZYERROR	s $ZYERROR="ZYERROR^TestTrap1" ; should not be needed, but is
	;i $ZS["STACKCRIT" s $ZE="<FRAMESTACK>"_$p($ZS,",",2) q  ; avoid stack overflow from next line
	if cnt<3 write !,"$ZSTATUS=",$ZSTATUS
	set cnt=cnt+1
	s $ZE=$ZS
	q
