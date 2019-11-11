;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This module was derived from FIS GT.M code.
;
dbupdate ;
    for i=0:1:20 hang 1 for j=0:1:500 tstart ():(serial:transaction="BATCH") set ^a(i,j)=j tcommit
    for i=0:1:20 hang 1 for j=0:1:500 tstart ():(serial:transaction="BATCH") set ^b(i,j)=j tcommit
    hang 5
    set ^a(16,20001)=20001
    set ^b(16,20001)=20001
    quit
