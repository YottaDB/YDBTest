;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
; All rights reserved.
;
;	This source code contains the intellectual property
;	of its copyright holder(s), and is made available
;	under a license.  If you do not know the terms of
;	the license, please stop and do not read further.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ydb1098loginterval;
	; Test that the source server logs periodic messages only every 10000 transactions.
	; This is needed to ensure the logfile does not grow to a huge size.
	;
	for i=1:1:500  do
	.	for j=1:1:100  do
	.	.	set ^x(i,j)=$j(i,200)
	.	hang 0.01
	quit
