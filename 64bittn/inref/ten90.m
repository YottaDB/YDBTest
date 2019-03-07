;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
tenninety
	set name=$piece($ZCMDLINE," ",1)
	set infile=name_".ext",top10=name_"2.ext",rev90=name_"1_reverse.ext"
	open infile:(readonly:exception="goto nofile")
	use infile:exception="goto doneread"
	for i=1:1 quit:$zeof  read lines(i)
doneread
	use $p
	; there is no header
	if i<3  goto nozwrheader
	; there is not enough data, the 10% file will be empty
	if i<12 goto notenoughdata

	; -1 to drop the the extra count from the for loop
	set total=i-1
	; -2 to drop the two header lines, but add them back in
	set toptencount=((total-2)/10)+2

	open top10:newversion
	use top10
	for i=1:1:toptencount  write lines(i),!
	close top10
	write "Wrote ",i," lines to the top 10% file",!

	open rev90:newversion
	use rev90
	write lines(1),!,lines(2),!
	for i=total:-1:toptencount  write lines(i),!
	close rev90
	write "Wrote ",(total-(i-1))+2," lines to the reversed 90% file",!
	write "Total lines (including zwr header) is ",total,!

	quit

nozwrheader
	write "%YDB-E-ERROR no headers in the extract",!
	quit

notenoughdata
	write "%YDB-E-ERROR not enough lines in the extract",!
	quit

nofile
	use $p
	write $zstatus,!
	if $length(name)=0 set name="<no file name given>"
	write "%YDB-E-ERROR the file ",name," does not exist",!
	quit
