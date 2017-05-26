;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
filler
	new SUBSCRIPTCOUNT,SUBSCRIPTS,MAXLENGTH
	new i,file,count,tp

	set file=$piece($zcmdline," ",1)
	set count=+$piece($zcmdline," ",2)
	set MAXLENGTH=+$piece($zcmdline," ",3)
	set prefill=+$piece($zcmdline," ",4)

	set SUBSCRIPTCOUNT=5
	do pregenerateSubscripts

	open file:newversion
	use file
	write "fill(prefill,jobindex)",!
	write " set prefill=$get(prefill,1)",!
	write " set jobindex=$get(jobindex,0)",!
	;write " set:prefill ^index=0",!
	write " set range=$select(prefill:1,1:2)",!
	for i=1:1:count do
	.	write " set tp=$random(range)",!
	.	write " tstart:tp ()",!
	.	write " "_$$generateOperation(),!
	.	;write " if prefill!(^index<"_i_") "_$$generateOperation(),!
	.	;write " set:('prefill) ^index=^index+1"
	.	write " tcommit:tp",!
	.	write:(i#50=0) " quit:('prefill)&(^count<jobindex)",!
	close file

	quit

pregenerateSubscripts
	for i=1:1:SUBSCRIPTCOUNT set SUBSCRIPTS(i)=$$^%RANDSTR(3,,"AN")
	quit

generateSubscript()
	quit SUBSCRIPTS($random(SUBSCRIPTCOUNT)+1)

generateName()
	quit $$^%RANDSTR(1,,"A")_$$^%RANDSTR(1,,"N")

generateGVN()
	quit "^"_$$generateName()_"("""_$$generateSubscript()_""")"

generateValue()
	new range,string
	set range=$random(10)
	set range=$select(range<5:MAXLENGTH/20,range<9:MAXLENGTH/10,1:MAXLENGTH)
	set range=$random(range)
	set string=$$^%RANDSTR($select(range<200:range,1:200),,"AN")
	quit $select(range<200:""""_string_"""",1:"$justify("""_string_""","_range_")")

generateOperation()
	new return
	set return="set "_$$generateGVN()_"="_$$generateValue()
	quit return
