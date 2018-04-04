;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genisvtestcases
	; This test program was written to validate that GTM only
	; uses the first 4 characters of the new trigger ISVs. It
	; creates another M program with all the possible listings
	; ISVs and the compiles it.  The number %YDB-E-SVNOSET errors
	; from the compile are counted
	;
	; The new ISVs are pulled from inspectISV.m, which are in
	; in both upper and lower case.  This program takes each ISV
	; and writes them out in the correct forms, mixed case forms,
	; and then writes them with the first four characters being
	; correct and the rest of the ISV being anything that is a
	; valid M literal
	set file="isv.list",garbage=64
	open file:readonly use file
	; there is an expectation that the file isv.list is written as
	; shortname\nlongname, like $ZTWO\n$ZTWOrmhole, otherwise this won't work
	for  quit:$zeof  read x if '$zeof read y  set isvlist(x)=y
	close file
	set x=""
	set file="isv.m"
	open file:newversion use file
	write "isv",!
	for  set x=$order(isvlist(x)) quit:x=""  do
	.	;write "isvlist(",x,")=",isvlist(x),!
	.	do mangleisv(x,isvlist(x),0)
	write $char(9),"quit",!,"notrun",!
	set x=""
	for  set x=$order(isvlist(x)) quit:x=""  do
	.	do mangleisv(x,isvlist(x),1)
	write $char(9),"quit",!
	close file
	quit
mangleisv(isv,target,setwrite)
	new trash
	if setwrite do setisvtrap(isv,target)
	else  do writeisvtrap(isv,target)
	set trash=""
	for i=5:1:$length(isv)  do
	.	if setwrite do setisvtrap(isv,$extract(isv,1,i))
	.	else  do writeisvtrap(isv,$extract(isv,1,i))
	.	set trash=trash_$char($increment(garbage))
	.	if setwrite do setisvtrap(isv,target_trash)
	.	else  do writeisvtrap(isv,target_trash)
	.	if garbage>121 set garbage=64
	.	if garbage>89,garbage<96 set garbage=96
	quit
	;
	; write the line to read the ISV
writeisvtrap(isv,target)
	write $char(9),"if ",isv,"'=",target
	write " write",$char(32,34)
	write isv,"!=",target
	write $char(34,44,33),!
	quit
	;
	; write the line to set the ISV
setisvtrap(isv,target)
	write $char(9),"set ",target,"=420",!
	quit
