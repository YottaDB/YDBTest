;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm10123 ;
	new stats
	set subtotal=0
	set num1=10
	set num2=$piece($zcmdline," ",1)
	set var=$piece($zcmdline," ",2)
	write "## Run [$INCREMENT(^x)] "_num1_" times and "
	for i=1:1:num1  do
	. if $increment(^x)
	write "[$INCREMENT("_var_")] "_num2_" times",!
	if var'="none"  do
	. for i=1:1:num2  do
	. . if $increment(@var)
	set subtotal=num1+num2
	set ^total=^total+subtotal

	write "# Run [$VIEW(""GVSTAT"",""DEFAULT"")]. Expect SET>"_^total_", INC="_^total_". Previously, INC would not appear.",!
	write $piece($VIEW("GVSTAT","DEFAULT"),",",1)_":"_$piece($VIEW("GVSTAT","DEFAULT"),",",88),!
	write "# Run [ZSHOW ""G""]. Expect SET>"_subtotal_", INC="_subtotal_". Previously, INC would not appear.",!
	zshow "G":stats
	write $piece(stats("G",0),",",3)_","_$piece(stats("G",0),",",90),!
	write $piece(stats("G",1),",",3)_","_$piece(stats("G",0),",",90),!
	write "# Run [$$STAT^%YGBLSTAT($JOB,""INC,SET"")]. Expect SET>"_subtotal_", INC="_subtotal_". Previously, INC would not appear.",!
	view "STATSHARE"
	write $$STAT^%YGBLSTAT($JOB,"INC,SET"),!

	quit
