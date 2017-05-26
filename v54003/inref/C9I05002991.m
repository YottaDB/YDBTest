;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2011-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9I05002991
  set tcount=0
  znonesuch1:0
  write "OK "_$increment(tcount),!
  znonesuch1:0 1
  write "OK "_$increment(tcount),!
  znonesuch1:0 a
  write "OK "_$increment(tcount),!
  znonesuch1:0 "b"
  write "OK "_$increment(tcount),!
  znonesuch2:0  write "OK "_$increment(tcount),!
  znonesuch2:0 1 write "OK "_$increment(tcount),!
  znonesuch2:0 a write "OK "_$increment(tcount),!
  znonesuch2:0 "b" write "OK "_$increment(tcount),!
  s falseval=0
  znonesuch3:falseval
  write "OK "_$increment(tcount),!
  znonesuch3:falseval 1
  write "OK "_$increment(tcount),!
  znonesuch3:falseval a
  write "OK "_$increment(tcount),!
  znonesuch3:falseval "b"
  write "OK "_$increment(tcount),!
  znonesuch4:falseval  write "OK "_$increment(tcount),!
  znonesuch4:falseval 1 write "OK "_$increment(tcount),!
  znonesuch4:falseval a write "OK "_$increment(tcount),!
  znonesuch4:falseval "b" write "OK "_$increment(tcount),!
  znonesuch5:$$falsefun()
  write "OK "_$increment(tcount),!
  znonesuch5:$$falsefun() 1
  write "OK "_$increment(tcount),!
  znonesuch5:$$falsefun() a
  write "OK "_$increment(tcount),!
  znonesuch5:$$falsefun() "b"
  write "OK "_$increment(tcount),!
  znonesuch6:$$falsefun()  write "OK "_$increment(tcount),!
  znonesuch6:$$falsefun() 1 write "OK "_$increment(tcount),!
  znonesuch6:$$falsefun() a write "OK "_$increment(tcount),!
  znonesuch6:$$falsefun() "b" write "OK "_$increment(tcount),!
  write "O" znonesuch7:1-1 0,a,"b" write "K "_$increment(tcount),!
  abcdefg:0  write "OK "_$increment(tcount),!
errorcases
  new $etrap
  set $etrap="goto err"
  set zl=$zlevel
  s trueval=1
  write "FAIL HERE: ",!
  znonesuch10:1
  write "FAIL HERE: ",! znonesuch11:trueval  write "DID NOT GET EXPECTED ERROR "_$increment(tcount),!
  write "FAIL HERE: ",! znonesuch12:$$truefun() 1 write "DID NOT GET EXPECTED ERROR "_$increment(tcount),!
  write "FAIL HERE: ",! znonesuch13:2-1 1,a,"b" write "DID NOT GET EXPECTED ERROR "_$increment(tcount),!
  write "FAIL HERE: ",! abcdefg:1  write "DID NOT GET EXPECTED ERROR "_$increment(tcount),!
  write "FAIL HERE: " for i=1:1:2 abcdefg:0  write i,! for j=1:1:2 abcdef:1  write "DID NOT GET EXPECTED ERROR "_$increment(tcount),!
  write "FAIL HERE: ",! for i=1:1:2 abcdefg
  write "END OF TEST",!
  quit
err
  for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:loc[("^"_$text(+0))
  set next=zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
  if $zstatus["INVCMD" d
  . write "GOT EXPECTED ERROR "_$increment(tcount),!
  e  write "GOT UNEXPECTED ERROR """_$zstatus_""" "_$increment(tcount),!
  set $ecode=""
  zgoto @next
  halt
truefun()
  quit 1
falsefun()
  quit 0
