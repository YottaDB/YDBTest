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
; Cases for r208/tstart_many_names-ydb1346 : a TSTART that names local variables to restore on a restart.
; Each label NEWs and sets v1 to v<n> to 1, does a TSTART that names them, sets them to 2 and does a TRESTART,
; then checks that the restart restored every one of them to 1.
;
ydb1346
	quit
low	; TSTART with 1 to 5 names
	do t1,t2,t3,t4,t5
	quit
t1	; TSTART with 1 name
	new v1
	set (v1)=1
	tstart (v1)
	if $trestart=0 set (v1)=2 trestart
	do check(1)
	tcommit
	quit
t2	; TSTART with 2 names
	new v1,v2
	set (v1,v2)=1
	tstart (v1,v2)
	if $trestart=0 set (v1,v2)=2 trestart
	do check(2)
	tcommit
	quit
t3	; TSTART with 3 names
	new v1,v2,v3
	set (v1,v2,v3)=1
	tstart (v1,v2,v3)
	if $trestart=0 set (v1,v2,v3)=2 trestart
	do check(3)
	tcommit
	quit
t4	; TSTART with 4 names
	new v1,v2,v3,v4
	set (v1,v2,v3,v4)=1
	tstart (v1,v2,v3,v4)
	if $trestart=0 set (v1,v2,v3,v4)=2 trestart
	do check(4)
	tcommit
	quit
t5	; TSTART with 5 names
	new v1,v2,v3,v4,v5
	set (v1,v2,v3,v4,v5)=1
	tstart (v1,v2,v3,v4,v5)
	if $trestart=0 set (v1,v2,v3,v4,v5)=2 trestart
	do check(5)
	tcommit
	quit
t6	; TSTART with 6 names
	new v1,v2,v3,v4,v5,v6
	set (v1,v2,v3,v4,v5,v6)=1
	tstart (v1,v2,v3,v4,v5,v6)
	if $trestart=0 set (v1,v2,v3,v4,v5,v6)=2 trestart
	do check(6)
	tcommit
	quit
t7	; TSTART with 7 names
	new v1,v2,v3,v4,v5,v6,v7
	set (v1,v2,v3,v4,v5,v6,v7)=1
	tstart (v1,v2,v3,v4,v5,v6,v7)
	if $trestart=0 set (v1,v2,v3,v4,v5,v6,v7)=2 trestart
	do check(7)
	tcommit
	quit
t8	; TSTART with 8 names
	new v1,v2,v3,v4,v5,v6,v7,v8
	set (v1,v2,v3,v4,v5,v6,v7,v8)=1
	tstart (v1,v2,v3,v4,v5,v6,v7,v8)
	if $trestart=0 set (v1,v2,v3,v4,v5,v6,v7,v8)=2 trestart
	do check(8)
	tcommit
	quit
t9	; TSTART with 9 names
	new v1,v2,v3,v4,v5,v6,v7,v8,v9
	set (v1,v2,v3,v4,v5,v6,v7,v8,v9)=1
	tstart (v1,v2,v3,v4,v5,v6,v7,v8,v9)
	if $trestart=0 set (v1,v2,v3,v4,v5,v6,v7,v8,v9)=2 trestart
	do check(9)
	tcommit
	quit
t16	; TSTART with 16 names
	new v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16
	set (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16)=1
	tstart (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16)
	if $trestart=0 set (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16)=2 trestart
	do check(16)
	tcommit
	quit
t31	; TSTART with 31 names
	new v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,v31
	set (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,v31)=1
	tstart (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,v31)
	if $trestart=0 set (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,v31)=2 trestart
	do check(31)
	tcommit
	quit
check(n)	; After a TRESTART, each of v1 to v<n> must have its value from before the TSTART
	new i,ok
	set ok=1
	for i=1:1:n if @("v"_i)'=1 set ok=0 write "WRONG : v",i,"=",@("v"_i)," after the restart",!
	write:ok "PASS : ",n," name",$select(n=1:"",1:"s"),", $TRESTART=",$trestart,", v1 to v",n," restored",!
	quit
