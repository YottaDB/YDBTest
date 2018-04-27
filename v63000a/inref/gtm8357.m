;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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
gtm8357
	set pipe="pipe"
	set case=0
	set zstepenv=$select($random(2):"ydb_zstep",1:"gtm_zstep")
	set def="setenv "_zstepenv_" 'NEW myio SET myio=\$IO USE \$PRINCIPAL ZPRINT @\$ZPOSITION BREAK  USE myio';"
	for cmd=def,"",def do
	. write !,$text(case+$increment(case))
	. set cmd=cmd_"$gtm_dist/mumps -run begin^"_$text(+0)
	. set cnt=0
	. open pipe:(command=cmd)::"pipe"
	. for i=1:1 use pipe read line:1 quit:$zeof  do:""'=line
	. . use $principal
	. . write !,line
	. . if line["YDB>",$increment(cnt) do
	. . . set next=$select(1=cnt:"write $zstep,!",(3=case)+6=cnt:"zcontinue",(3=case)&(5=cnt):"set $ZSTEP=""B""",1:"zstep")
	. . . write !,cnt,?5,next
	. . . use pipe
	. . . write next,!
	. close pipe
	quit
begin	break  do name
	write "line1",!
	write "line2",!
	write "line3",!
	write "line4",!
	write "line5",!
	write "line6",!
	quit
name	write "line7",!
	write "line8",!
	write "line9",!
	quit
case
;# Set gtm_zstep environmental variable to display the code in specified location
;# gtm_zstep is not defined test case
;# gtm_zstep is defined and overwritten while doing debug

