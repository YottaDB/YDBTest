;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm5894
fillglo
	for i=1:1:500 set ^x(i)=$translate($justify("x",512)," ","X")
	quit

verifyglo
	for i=1:1:500 do
	.   if ^x(i)'=$translate($justify("x",512)," ","X") do
	.   .  write "TEST-E-FAIL Corrupted data: ",! zwrite ^x halt
	write "TEST-I-PASS Data OK"