;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2008, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestTrap
	s $zyerror="ZYERROR^TestTrap"
	s $ZT="TrapErr"
	d TT1
	q

TT1	n $ZT ; Setting $ET does not save $ZT to the stack so do it here
	s $ET="g TrapCmd"
	d FSErr(1,$G(hide))
	w !,"done"
	q

TrapErr	s ^XMGL4=1
	w !,"TrapErr:"_$ZE,?15,$zl
	q

TrapCmd	;w !,"TrapCmd:"_$ZE
	i 1 d
	. ;w !,"In inner do block",?20,$zl
	q

FSErr(int,hide)
	n test
	;w:'hide !,int,?10,$zl
	s test=int+1
	s ^XMGL=test
	d FSErr(test,hide)
	q

ZYERROR	s $ZYERROR="ZYERROR^TestTrap" ; should not be needed, but is
	i $ZS["STACKCRIT" s $ZE="<FRAMESTACK>"_$p($ZS,",",2) q  ; avoid stack overflow from next line
	s $ZE=$ZS
	q
