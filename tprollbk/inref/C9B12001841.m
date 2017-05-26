;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9B12001841	; check $REFERENCE after a rollback
  set $etrap="goto err"
  new (act)
  if '$d(act) new act set act="write !,""$R after "",x,"" rollback: "",$reference"
  set cnt=0
  tstart ()
  set ^a(1)=1
  tstart (x)
  set ^b(1,2,3)=123
  trollback -1
  if $r'="",$increment(cnt) set x="partial" xecute act
  tstart (x)
  set ^b(1)=1
  trollback -1
  set ^a(1,2)=2
  trollback
  if $r'="",$increment(cnt) set x="full" xecute act
  write !,$select(cnt:"FAIL",1:"PASS")," from ",$T(+0)
  quit
err set $ecode=""
  trollback:$tlevel
  write !,"Unexpected error: ",$ZS,!,"From ",$T(+0)
  quit
