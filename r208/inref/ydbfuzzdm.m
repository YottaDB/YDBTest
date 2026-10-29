;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; Runs direct mode cases for r208 subtests of fixes for failures found by fuzz testing. Each subtest keeps its
; cases in its own routine <rtn>.
;
; $gtm_dist/mumps -run gen^ydbfuzzdm <rtn> <case>   writes <case>.inp, the lines to feed to "mumps -direct",
;                                                   and any files the case needs
; $gtm_dist/mumps -run chk^ydbfuzzdm <rtn> <case>   checks <case>.out, the output of "mumps -direct < <case>.inp",
;                                                   against the expectations listed for <case> in <rtn>
;
; Each case is a label in <rtn> whose lines are
;	;inp:<M expression that evaluates to one line of input>
;	;has:<text that the output must contain>
;	;not:<text that the output must not contain>
; The ;inp: expressions are evaluated here, so they can use $$cycles below.
; No case may print a fatal error, so every case also checks that the output has no "-F-".
; A case that needs files has a label files<case> in <rtn> that creates them.
;
ydbfuzzdm
	quit

gen	;
	new rtn,case,file,i,line
	set rtn=$piece($zcmdline," ",1),case=$piece($zcmdline," ",2),file=case_".inp"
	do:$text(@("files"_case_"^"_rtn))'="" @("files"_case_"^"_rtn)
	open file:(newversion)
	use file
	for i=1:1 set line=$text(@(case_"+"_i_"^"_rtn)) quit:line'[";"  if $piece(line,";",2)?1"inp:".e  write @$piece(line,";inp:",2,$length(line,";inp:")),!
	close file
	quit

chk	;
	new rtn,case,file,i,line,out,kind,text,n
	set rtn=$piece($zcmdline," ",1),case=$piece($zcmdline," ",2),file=case_".out",out=""
	open file:(readonly)
	use file
	for  read line quit:$zeof  set out=out_line_$char(10)
	close file
	for i=1:1 set line=$text(@(case_"+"_i_"^"_rtn)) quit:line'[";"  do
	. set kind=$extract($piece(line,";",2),1,4),text=$piece(line,kind,2,$length(line,kind))
	. if "has:"=kind do report(case,out[text,"has",text)
	. if "not:"=kind do report(case,'(out[text),"does not have",text)
	do report(case,'(out["-F-"),"does not have","a fatal error (-F-)")
	quit

cycles(n,on,off)	; Returns n pairs of lines "on" then "off"
	new i,lines
	set lines=on_$char(10)_off
	for i=2:1:n set lines=lines_$char(10)_on_$char(10)_off
	quit lines

report(case,ok,verb,text)
	write $select(ok:"PASS",1:"WRONG")," : ",case," output ",verb," ",text,!
	quit

