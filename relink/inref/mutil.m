;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Copy .m routine into local variable
;
mfile2lv(line,mfile)
	new i,s
	kill line
	open mfile:(READONLY)
	use mfile
	for i=1:1 read s quit:$zeof  do
	.	set line(i)=s
	close mfile
	quit ""
;
; Write local variable out to .m file.
; Var should have form as returned by mfile2lv
;
lv2mfile(line,mfile)
	new i
	open mfile:(NEWVERSION)
	use mfile
	for i=1:1 quit:'$data(line(i))  write line(i),!
	close mfile
	quit ""

;
; Replace every occurrence of strf with strn in var line(0),line(1)...
; Var should have form as returned by mfile2lv
;
replaceString(line,strf,strn)
	new i,j,s,c,sn
	for i=1:1 quit:'$data(line(i))  do
	.	set s=line(i)
	.	set c=$length(s,strf)	; number of pieces delimited by <strf>
	.	set sn=""
	.	for j=1:1:c-1 set sn=sn_$piece(s,strf,j)_strn
	.	set sn=sn_$piece(s,strf,c)
	.	set line(i)=sn
	quit ""

;
; Take the diff of two files
;
diffFile(diff,line1,line2)
	new i
	for i=1:1 quit:'$data(line1(i))&'$data(line2(i))  do
	.	if $get(line1(i),"")'=$get(line2(i),"") do
	.	.	set diff(i,1)=line1(i)
	.	.	set diff(i,2)=line2(i)
	quit $data(diff)

	;Do CALL^%RI
	;ZSYstem "cp bar_template.txt bar.m"
	;Set %ZR("bar")=""
	;Set %ZF="###REPLACE:ENTRYREF"
	;Set %ZN=comstr
	;Do CALL^%RCE
	Quit 0
