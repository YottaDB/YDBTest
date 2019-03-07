;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; see test/manually_start/u_inref/maxtrignames.csh for the
	; purpose of this test program
maxtrignames
	new start,stop
	set start=$HOROLOG
	VIEW "JOBPID":1
	;
	do file^dollarztrigger("maxtrignames.trg",1)
	do select^dollarztrigger("*","initial.trg")
	; load short names
	job loadJ^maxtrignames("someglobal",2)
	for i=1:1  quit:$data(^alldone)  hang 1
	zsystem "mkdir -p short ; $MUPIP backup ""*"" ./short/ >&! short.log"
	; load long names
	job loadJ^maxtrignames("someVeryLongGlobalVariableName",5)
	for i=1:1  quit:^alldone=2  hang 1
	zsystem "mkdir -p long ; $MUPIP backup ""*"" ./long/ >&! long.log"
	;
	do select^dollarztrigger("*","loaded.trg")
	;
	set stop=$HOROLOG
	set ^time("total")="Total test time is "_$$^difftime(stop,start)_" seconds"
	quit

	; routines to load the triggers into the DB consuming the name space
loadJ(name,start)
	set maxnames=^maxtrignames-1
	VIEW "JOBPID":1
	; Start/stop criteria
	set stop=start+1000,stop=stop-(stop#1000)-1
	; GBL name
	set shortname=$extract(name,1,21)
	set output=shortname_start_".trg"
	open output:newversion
	use output
	set gbl=name_$select($length(name)<20:"",1:$char(65+$random(4)))
	tstart ()
	for i=start:1:stop  do
	.	write "+^",gbl,"(",i,") -commands=ZTR -xecute=""set x=",i,"""",!
	.	write "-^",gbl,"(",i,") -commands=ZTR -xecute=""set x=",i,"""",!
	tcommit
	close output
	do file^dollarztrigger(output,1)
	if start<maxnames job loadJ^maxtrignames(name,stop+1):(CMDLINE="loadJ^maxtrignames")
	else  set ^alldone=$increment(^alldone)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routines to test the triggers installation
test1
	do testautoname
	do testautonamereset
	quit

testautoname
	new file,invalidloadstat,validloadstat
	set file="testautoname.out"
	open file:newversion
	use file
	do ^echoline
	write "Attempt to load a trigger past 999,999 for ^someglobal",!
	set invalidloadstat=$ztrigger("item","+^someglobal(000000) -commands=ZTR -xecute=""set x=000000""")
	if invalidloadstat=1 write "TEST-F-FAIL: trigger load should NOT succeed. See ",file,!
	do ^echoline
	write "Attempt to load a named trigger for ^someglobal",!
	set validloadstat=$ztrigger("item","+^someglobal(1000000) -commands=ZTR -xecute=""set x=1000000"" -name=%000000")
	if validloadstat=0 write "TEST-F-FAIL: trigger load with user defined name should succeed. See ",file,!
	close file
	quit

testautonamereset
	new file,reset,validloadstat,trg,i
	set file="testautonamereset.out"
	open file:newversion
	use file
	set i=$get(^reset,$random(5))		; ^reset is for debugging purposes when testing one delete option
	set trg=$piece($text(reset+i^maxtrignames),";",2)
	do ^echoline
	write "Attempt to reset #SEQNO with this trigger spec GTM_TEST_DEBUGINFO :",trg,!
	set reset=$ztrigger("item",trg)
	if reset=0 write "TEST-F-FAIL: name reset operations should succeed. See ",file,!
	do ^echoline
	write "Reload the first trigger for ^someglobal. It should be named someglobal#1#",!
	set validloadstat=$ztrigger("item","+^someglobal(1) -commands=S -xecute=""set x=$increment(^fired($ZTName))""")
	if validloadstat=0 write "TEST-F-FAIL: trigger load should succeed because autogenerate namespace was reset. See ",file,!
	close file
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test2
	do testlongnames
	do testlongnamesreset
	quit

testlongnames
	new i,gbl,name,shortname,validstat,delstat,invalidstat
	set file="testlongnames.out"
	open file:newversion
	use file
	set name="someVeryLongGlobalVariableName"
	set shortname=$extract(name,1,21)
	set gbl=name_$char(65+$random(4))
	set i=^maxtrignames-1
	set trg="+^"_gbl_"("_i_") -commands=ZTR -xecute=""set x="_i_""""
	do ^echoline
	write "Attempt to load a trigger past 999,999 for ^",name,"X",!
	set invalidstat=$ztrigger("item",trg)
	if invalidstat=1 write "TEST-F-FAIL: should NOT be able to load a trigger past 999,999. See ",file,!
	do ^echoline
	set trg="+^"_gbl_"("_$increment(i)_") -commands=ZTR -xecute=""set x="_i_""""
	write "Attempt to load a named trigger for ^",name,"X using the matching truncated autogenerate name ",shortname,!
	set validstat=$ztrigger("item",trg_" -name="_shortname)
	if validstat=0 write "TEST-F-FAIL: should be able to load a trigger with a user defined name. See ",file,!
	do ^echoline
	write "Delete ",shortname," name trigger",!
	set delstat=$ztrigger("item","-"_shortname)
	if delstat=0 write "TEST-F-FAIL: should be able to load a trigger with a user defined name. See ",file,!
	close file
	quit

testlongnamesreset
	new i,gbl,name,shortname,file,validstat
	set file="testlongnamesreset.out"
	open file:newversion
	use file
	; renaming all auto generated names reduces #TNCOUNT to zero and #SEQNO is reset
	do ^echoline
	write "Rename all of the someVeryLongGlobalVariableNameX autogenerated name triggers",!
	do text^dollarztrigger("rename^maxtrignames","rename.trg")
	do file^dollarztrigger("rename.trg",1)
	use file
	;
	set name="someVeryLongGlobalVariableName"
	set shortname=$extract(name,1,21)
	set gbl=name_$char(65+$random(4))
	set i=^maxtrignames-1
	set trg="+^"_gbl_"("_i_") -commands=ZTR -xecute=""set x="_i_""""
	do ^echoline
	write "Attempt to load a trigger for ^",name,"X after #SEQNO was reset. It should be ",shortname,"#1",!
	set validstat=$ztrigger("item",trg)
	if validstat=0 write "TEST-F-FAIL: failed to load trigger after #SEQNO was reset. See ",file,!
	close file
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; setup - need to alter the GLD to redirect the long names to the same region but randomly choose the target region
; All the names go to the same region becuase name space is now per-region
setup
	new reg
	set reg(0)="AREG",reg(1)="BREG",reg(2)="CREG",reg(3)="DREG",reg(4)="DEFAULT"
	do text^dollarztrigger("gde"_reg($r(5))_"^maxtrignames","maxtrignames.gde")
	do text^dollarztrigger("tfile^maxtrignames","maxtrignames.trg")
	zsystem "$gtm_dist/mumps -run GDE @maxtrignames.gde"
	set ^maxtrignames=1000000
	quit


gdeAREG
	;add -name someVeryLongGlobalVariableNameA -region=AREG
	;add -name someVeryLongGlobalVariableNameB -region=AREG
	;add -name someVeryLongGlobalVariableNameC -region=AREG
	;add -name someVeryLongGlobalVariableNameD -region=AREG
	;add -name someglobal -region=dreg
	quit

gdeBREG
	;add -name someVeryLongGlobalVariableNameA -region=BREG
	;add -name someVeryLongGlobalVariableNameB -region=BREG
	;add -name someVeryLongGlobalVariableNameC -region=BREG
	;add -name someVeryLongGlobalVariableNameD -region=BREG
	;add -name someglobal -region=dreg
	quit

gdeCREG
	;add -name someVeryLongGlobalVariableNameA -region=CREG
	;add -name someVeryLongGlobalVariableNameB -region=CREG
	;add -name someVeryLongGlobalVariableNameC -region=CREG
	;add -name someVeryLongGlobalVariableNameD -region=CREG
	;add -name someglobal -region=dreg
	quit

gdeDREG
	;add -name someVeryLongGlobalVariableNameA -region=DREG
	;add -name someVeryLongGlobalVariableNameB -region=DREG
	;add -name someVeryLongGlobalVariableNameC -region=DREG
	;add -name someVeryLongGlobalVariableNameD -region=DREG
	;add -name someglobal -region=dreg
	quit

gdeDEFAULT
	;add -name someVeryLongGlobalVariableNameA -region=DEFAULT
	;add -name someVeryLongGlobalVariableNameB -region=DEFAULT
	;add -name someVeryLongGlobalVariableNameC -region=DEFAULT
	;add -name someVeryLongGlobalVariableNameD -region=DEFAULT
	;add -name someglobal -region=dreg
	quit

reset	;-^someglobal(1) -commands=S -xecute="set x=$increment(^fired($ZTName))"
	;-someglobal#1
	;-someglobal#1#
	;-someglobal#*
	;-someglobal*
	quit

rename
	;;;;;;;;;;;;;;;;;;;;;;+^someglobal(1) -commands=SET -xecute="set x=$increment(^fired($ZTName))" -name=someglobal
	;+^someVeryLongGlobalVariableNameA(1) -commands=SET -XECUTE="set x=$increment(^fired($ZTName))" -name=A
	;+^someVeryLongGlobalVariableNameB(1) -commands=SET -XECUTE="set x=$increment(^fired($ZTName))" -name=B
	;+^someVeryLongGlobalVariableNameC(1) -commands=SET -XECUTE="set x=$increment(^fired($ZTName))" -name=C
	;+^someVeryLongGlobalVariableNameD(1) -commands=SET -XECUTE="set x=$increment(^fired($ZTName))" -name=D
	quit

tfile
	;+^someglobal(1)                      -commands=SET -xecute="set x=$increment(^fired($ZTName))"
	;+^someVeryLongGlobalVariableNameA(1) -commands=SET -XECUTE="set x=$increment(^fired($ZTName))"
	;+^someVeryLongGlobalVariableNameB(1) -commands=SET -XECUTE="set x=$increment(^fired($ZTName))"
	;+^someVeryLongGlobalVariableNameC(1) -commands=SET -XECUTE="set x=$increment(^fired($ZTName))"
	;+^someVeryLongGlobalVariableNameD(1) -commands=SET -XECUTE="set x=$increment(^fired($ZTName))"
