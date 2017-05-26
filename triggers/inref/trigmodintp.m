;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2011-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trigmodintp ;
	;
	; Test that triggers can be installed & fired inside the same TP transaction without any TRIGMODINTP errors
	;
	set ^stop=0,(^a,^b,^c,^d)=0
	set jmaxwait=0
	write "Check that we start out with NO triggers",!
	write $ztrigger("SELECT","*"),!
	do ^job("child^trigmodintp",8,"""""")
	hang 15
	if ^stop'=1 set ^stop=1
	else  write "TEST-E-FAIL : ^stop was set to 1 by at least one child. Look for TEST-E-VERIFYFAIL messages in *.mjo* files",!
	do wait^job
	write "Check that we end with NO triggers",!
	write $ztrigger("SELECT","*"),!
	quit
child	;
	if jobindex=8  do  quit
	.	for  quit:^stop=1  do
	.	.	for i=1:1:10000  set ^fixed(i)=$justify(i,200)
	.	.	for i=1:1:10000 set x=^fixed(i)
	.	.	kill ^fixed
	set error=0
	set str="TEST-E-VERIFYFAIL"
	do ^sstep
	for i=1:1  quit:^stop=1  do
	.	tstart ():serial
	.	write "$trestart = ",$trestart,!
	.	set ^arand=$random(100),^brand=$random(100),^crand=$random(100),^drand=$random(100)
	.	set arand=^arand,brand=^brand,crand=^crand,drand=^drand
	.	set a=^a,b=^b,c=^c,d=^d
	.	set x=$incr(^a,^arand)	; should increment ^a by 1*arand
	.	set x=$ztrigger("ITEM","+^a -commands=S -xecute=""do atrig^trigmodintp""")
	.	set x=$ztrigger("ITEM","+^b -commands=S -xecute=""do btrig^trigmodintp""")
	.	set x=$ztrigger("ITEM","+^c -commands=S -xecute=""do ctrig^trigmodintp""")
	.	set x=$incr(^a,^arand)	; should increment ^a by 1*arand, ^b by 1*brand, ^c by 2*crand, ^d by 4*drand
	.	set x=$ztrigger("ITEM","-^c -commands=S -xecute=""do ctrig^trigmodintp""")
	.	set x=$incr(^a,^arand)	; should increment ^a by 1*arand, ^b by 1*brand, ^c by 2*crand, ^d by 2*drand
	.	set x=$ztrigger("ITEM","-^b -commands=S -xecute=""do btrig^trigmodintp""")
	.	set ^fixed(i)=$job
	.	set x=$incr(^a,^arand)	; should increment ^a by 1*arand, ^b by 1*brand, ^c by 1*crand, ^d by 1*drand
	.	set x=$ztrigger("ITEM","-^a -commands=S -xecute=""do atrig^trigmodintp""")
	.	if (^a'=(a+(4*^arand))) write str_": ^a Expected = ",a+(4*^arand)," : Actual = ",^a,! set error=1
	.	if (^b'=(b+(3*^brand))) write str_": ^b Expected = ",b+(3*^brand)," : Actual = ",^b,! set error=1
	.	if (^c'=(c+(5*^crand))) write str_": ^c Expected = ",c+(5*^crand)," : Actual = ",^c,! set error=1
	.	if (^d'=(d+(7*^drand))) write str_": ^d Expected = ",d+(7*^drand)," : Actual = ",^d,! set error=1
	.	tcommit
	.	if error zshow "*" set:^stop=0 ^stop=1  halt
	quit
atrig	;
	set x=$incr(^b,^brand)
	set x=$incr(^c,^crand)
	set x=$incr(^d,^drand)
	quit
btrig	;
	set x=$incr(^c,^crand)
	set x=$incr(^d,^drand)
	quit
ctrig	;
	set x=$incr(^d,^drand)
	quit
