;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
; Portions Copyright (c) Fidelity National                      ;
; Information Services, Inc. and/or its subsidiaries.           ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

c002698	;
	; ------------------------------------------------------------------------------------------------------
	; C9E12002698 [Narayanan] KILL of globals in TP transactions cause database damage and assert failures
	; ------------------------------------------------------------------------------------------------------
	set ^stop=0
	set ^maxindex=100
	for i=1:1:^maxindex  do
	.	for j=1:1:^maxindex  do
	.	.	set ^x(i,j)=$j(j,350)
	set jmaxwait=0
	set njobs=1+$r(8)
	do ^job("thread^c002698",njobs,"""""")
	hang 15
	set ^stop=1
	do wait^job
	quit

thread	;
	view "GDSCERT":1
	set playmode=0
	set playverbose=0
	set maxindex=^maxindex
	for i=1:1  quit:^stop=1  do
	.	write "i ",i
	.	set loopiter=1+$r(4)
	.	write " loopiter ",loopiter
	.	;
	.	for m=1:1:loopiter do
	.	.	;
	.	.	; the order in which the "write"s are done below is relied upon by the "play" label below.
	.	.	; any changes to the order here need to correspondingly happen there.
	.	.	;
	.	.	set j1(m)=((i+$r(10))#maxindex)+1
	.	.	write " j1 ",j1(m)
	.	.	set k1max(m)=1+$r(20)
	.	.	write " k1max ",k1max(m)
	.	.	set x1(m)=$r(2)
	.	.	write " x1 ",x1(m)
	.	.	;
	.	.	set j2(m)=((i+$r(10))#maxindex)+1
	.	.	write " j2 ",j2(m)
	.	.	set k2(m)=1+$r(k1max(m))
	.	.	write " k2 ",k2(m)
	.	.	set x2(m)=$r(2)
	.	.	write " x2 ",x2(m)
	.	.	;
	.	.	set j3(m)=((i+$r(10))#maxindex)+1
	.	.	write " j3 ",j3(m)
	.	.	set x3(m)=$r(2)
	.	.	write " x3 ",x3(m)
	.	.	;
	.	write !
	.	do oneiter
	quit

oneiter	;
	if $data(playverbose)=0 set playverbose=0
	if playverbose=1 write "    tstart ():serial",!
	else  tstart ():serial
	do
	.	for num=1:1:loopiter  do
	.	.	;
	.	.	; -------------------------------------------------------------------------
	.	.	; SET of level I and II subscripts followed by random TROLLBACK/TCOMMIT
	.	.	; -------------------------------------------------------------------------
	.	.	;
	.	.	if playverbose write "        tstart ():serial",!
	.	.	else  tstart ():serial
	.	.	for k1=1:1:k1max(num)  do
	.	.	.	set xstr="set ^x("_j1(num)_","_k1_")=$j("_jobindex_",300)"
	.	.	.	if playverbose write "        ",xstr,!
	.	.	.	else  xecute xstr
	.	.	if x1(num)=0  do
	.	.	.	if playverbose write "        tcommit",!
	.	.	.	else  tcommit
	.	.	if x1(num)=1  do
	.	.	.	if playverbose write "        trollback 1",!
	.	.	.	else  trollback 1
	.	.	;
	.	.	; -------------------------------------------------------------------------
	.	.	; KILL of level II subscript followed by random TROLLBACK/TCOMMIT
	.	.	; -------------------------------------------------------------------------
	.	.	;
	.	.	if playverbose write "        tstart ():serial",!
	.	.	else  tstart ():serial
	.	.	set xstr="kill ^x("_j2(num)_","_k2(num)_")"
	.	.	if playverbose write "        ",xstr,!
	.	.	else  xecute xstr
	.	.	if x2(num)=0  do
	.	.	.	if playverbose write "        tcommit",!
	.	.	.	else  tcommit
	.	.	if x2(num)=1  do
	.	.	.	if playverbose write "        trollback 1",!
	.	.	.	else  trollback 1
	.	.	;
	.	.	; -------------------------------------------------------------------------------
	.	.	; $GET of level I subscript tree underneath followed by random TROLLBACK/TCOMMIT
	.	.	;	The ideal way to do this is a ZWRITE of the global but that will print
	.	.	;	output which we want to avoid. The work around used is to do a MERGE of
	.	.	;	the GLOBAL's level I subscript into a LOCAL. This achieves the same
	.	.	;	purpose (of doing READs) without any display output.
	.	.	; -------------------------------------------------------------------------------
	.	.	;
	.	.	if playverbose write "        tstart ():serial",!
	.	.	else  tstart ():serial
	.	.	; Randomly choose whether to test MERGE or ZYENCODE/ZYDECODE. Only do the ZYENCODE/ZYDECODE
	.	.	; test when j3(num) and ^x(js(num)) are defined, otherwise a ZYENCODESRCUNDEF error will be issued.
	.	.	if $RANDOM(2)&($data(j3(num))#2)&($data(^x(j3(num)))=11)  do
	.	.	.	set xstr="zyencode encv=^x("_j3(num)_") zydecode decv=encv"
	.	.	else  do
	.	.	.	set xstr="merge lclmerge=^x("_j3(num)_")"
	.	.	if playverbose write "        ",xstr,!
	.	.	else  xecute xstr
	.	.	if x3(num)=0  do
	.	.	.	if playverbose write "        tcommit",!
	.	.	.	else  tcommit
	.	.	if x3(num)=1  do
	.	.	.	if playverbose write "        trollback 1",!
	.	.	.	else  trollback 1
	.	.	;
	.	.	; -------------------------------------------------------------------------
	.	.	; KILL of level I subscript followed by random TROLLBACK/TCOMMIT
	.	.	; -------------------------------------------------------------------------
	.	.	;
	.	.	if playverbose write "        tstart ():serial",!
	.	.	else  tstart ():serial
	.	.	set xstr="kill ^x("_j2(num)_")"
	.	.	if playverbose write "        ",xstr,!
	.	.	else  xecute xstr
	.	.	if x3(num)=0  do
	.	.	.	if playverbose write "        tcommit",!
	.	.	.	else  tcommit
	.	.	if x3(num)=1  do
	.	.	.	if playverbose write "        trollback 1",!
	.	.	.	else  trollback 1
	if playverbose write "    tcommit",!
	else  tcommit
	quit

play	;
	set jobindex=1
	set playmode=1
	set file="input.txt"
	open file:(exception="if $zeof=1 quit")
	set i=1
	use file
	for  quit:$zeof=1  do
	.	read line(i)
	.	set i=i+1
	close file
	use $p
	set numrecs=i-1
	for n=1:1:numrecs  do
	.	set fieldnum=0
	.	set fieldnum=fieldnum+2
	.	set i=$piece(line(n)," ",fieldnum)             set fieldnum=fieldnum+2
	.	set loopiter=$piece(line(n)," ",fieldnum)      set fieldnum=fieldnum+2
	.	for m=1:1:loopiter  do
	.	.	set j1(m)=$piece(line(n)," ",fieldnum)    set fieldnum=fieldnum+2
	.	.	set k1max(m)=$piece(line(n)," ",fieldnum) set fieldnum=fieldnum+2
	.	.	set x1(m)=$piece(line(n)," ",fieldnum)    set fieldnum=fieldnum+2
	.	.	set j2(m)=$piece(line(n)," ",fieldnum)    set fieldnum=fieldnum+2
	.	.	set k2(m)=$piece(line(n)," ",fieldnum)    set fieldnum=fieldnum+2
	.	.	set x2(m)=$piece(line(n)," ",fieldnum)    set fieldnum=fieldnum+2
	.	.	set j3(m)=$piece(line(n)," ",fieldnum)    set fieldnum=fieldnum+2
	.	.	set x3(m)=$piece(line(n)," ",fieldnum)    set fieldnum=fieldnum+2
	.	do oneiter
	quit

playverbose	;
	set playverbose=1
	do play
	quit

