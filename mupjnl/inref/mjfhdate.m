;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mjfhdate ;convert $H in mjf output to DATE format
	s mjf=$ZCMDLINE
	s outfile=$P
	s next=0
	o mjf u mjf
	r header
	u $P w "#",header,!
	u mjf r line
	for  q:$zeof=1  do
	. u $P
	. s dollarh=$P(line,"\",2)
	. s $E(line,4,14)="#"_$ZDATE(dollarh)_" "_$ZDATE(dollarh,"24:60:SS")_"#"
	. w line,!
	. u mjf r line
	q
