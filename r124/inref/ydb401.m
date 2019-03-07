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
test1(a)
  s x=v
  q

echo(a)
  w "zyre=",$zyre,!
  s b=c
  q

call()
  s rc=$&func()
  w "-- zwr shows rc=0 --",!
  zwr
  w "-- $g(rc) --",!
  w "rc=",$g(rc),!
  w "-- accessing rc --",!
  w "rc=",rc,!
  q
