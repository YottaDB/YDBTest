;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2003-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c002017       ;
	set max=24000		; Must match below
	set minsw=2000		; Must match below
        f i=1:1:minsw*2   do
	.	tstart ():(serial:transaction="BA")
	.	s ^a(i)=$j(i,720)
	.	s ^x(i)=$j(i,720)
	.	tcommit
	zsystem "$DSE all -buff"   ; this will write an epoch record in all regions
	h 2	;h 1 is not enough due to rounding issues between journal record time and DCL time in VMS
	zsystem "date +""%d-%b-%Y %H:%M:%S"" > time1.txt"
 	h 2	;Introduce another sleep for 2 sec to make sure GT.M time in the journal files after this
		;is greater than the time in time1.txt
        f i=minsw:1:max-1  do
	.	tstart ():(serial:transaction="BA")
	.	s ^a(i)=$j(i,720)
	.	s ^x(i)=$j(i,720)
	.	tcommit
	s ^a(max)=$j(max,720)
	; we do not set ^x(max) here
	q
	; Following order will make sure last valid record's time is from DEFAULT and recover output is deterministic
defreg;
	h 1
	set max=24000		; Must match below
	s ^x(max)=$j(max,720)
        quit
dverify ; verify process for #43 (C9C06-002017)
	set max=24000		; Must match below and above
	f i=1:1:max  d
	. i ^a(i)'=$j(i,720) w "** FAIL ",!,"^a(",i,") = ",$GET(^a(i)),! q
	. i ^x(i)'=$j(i,720) w "** FAIL ",!,"^x(",i,") = ",$GET(^x(i)),!,q
	q
everify ; verify the extract file created by backward recovery
	; Expects that all records after the time1.txt time should be in the extract file
	set max=24000		; Must match above
	set minsw=2000		; Must match above
	set x=$zsearch("*.mjf")
	set name=$zparse(x,"name")	; File name matches the first global extracted
	set extract=name_".mjf"
	o extract:(readonly)
	u extract:exception="G eof"
	set num=minsw
	set name=$$FUNC^%LCASE(name)
	set gbl="^a"	; expect records of "^a" first
	set failed=0
	set done=0
	f  do  quit:(failed!done)
	. u extract
	. r line
	. set type=$p(line,"\",1)
	. if type="05" do  quit:failed
        .. set value=$piece(line,"\",$length(line,"\")) ; The value is always the last piece
	.. set left=$p(value,"=",1)
	.. set right=$p(value,"=",2)
	.. set lvalue=gbl_"("_num_")"
	.. set rvalue=""""_$j(num,720)_""""
	.. if (left'=lvalue)!(right'=rvalue)  do
	... use $p write "VERIFICATION FAILED:",value," Expected:",lvalue,"=",rvalue,!
	... set failed=1
	.. set num=num+1
	. if (num>max) do
	. . if gbl="^a" set gbl="^x",num=minsw	; expect records of ^x next
	. . else  set done=1
eof	;
	close extract
	u $p
	if ((failed=0)&(num=(max+1))) w "VERIFICATION PASSED",!
	q

