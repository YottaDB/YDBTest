;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
var;
	w "===========================================",!
	w "string:",!
	w ^["/this/sample","strato"]GBL,!
	s var="strato"
	s vara="/this/sample"
	w "variables:",!
	w ^[vara,var]GBL,!
	w "vara:",vara,";var:",var,!
	s ind="var"
	s indi="vara"
	w "indirection:",!
	w ^[@indi,@ind]GBL,!
	s str="zzz strato zzz"
	s str1="zzz /this/sample zzz"
	w "functions:",!
	w ^[$P(str1," ",2),$P(str," ",2)]GBL,!
	w "===========================================",!
	q

