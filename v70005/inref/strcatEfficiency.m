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

; On an x86, both tests take about 7ms on v70005 pro and above (and 500ms on older versions)

; empty function used just to force a compile of this routine
noop
	quit

test1
	for i=1:1:10 set x(i)=$justify(i,100000)
	for i=1:1:10000  set z=x(1)_x(2)_x(3)_x(4)_x(5)_x(6)_x(7)_x(8)_x(9)_x(10)
	quit

test2
	set c="c"
	for i=1:1:10 set x(i)=$justify(i,100000)
	set tmp=x(10)
	for i=1:1:10000  set z=x(1)_x(2)_x(3)_x(4)_x(5)_x(6)_x(7)_x(8)_x(9)_tmp  set tmp=tmp_c
	quit
