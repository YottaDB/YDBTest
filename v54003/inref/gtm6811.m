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
dohang
  set ^stop=0
  open "running.txt" ; create file to indicate that the process is running
  for i=1:1:120 halt:^stop  hang 1
  write "%YDB-E-TIMEOUT, Process not stopped in allotted time",!
  halt

dohang1
  set ^a=1
  goto dohang

dohang2
  set ^a=2
  goto dohang

dowrite
  write ^a,!
  halt

dostop
  set ^stop=1
  halt
