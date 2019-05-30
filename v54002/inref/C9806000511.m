;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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
9806000511     ; test ZWRITE of an ISV
  new (act)
  if '$data(act) new act set act="q"
  set $etrap="set estack=$stack do err"
  set $zerror=""
  for i=1:1:31 s $zerror=$zerror_$c(i)
  set a1b=$c(1),a2c=$c(2)

  zwrite $zerror,?1a1n1a,@("$zerror")
  zwrite ^$zerror ;SVNEXPECTED
  zwrite $$zerror ;SVNEXPECTED
  zwrite $stack($stack,"MCODE") ;SVNEXPECTED
  zwrite $zfoobar ;INVSVN

  do  ; this do is to match $stack, $estack, and $zlevel
  . set out="isvlist.outx" open out:newver use out
  . zshow "i":isvlist
  . close out

  set out="isvlist.m" open out:newver use out
  for i=1:1 set isv=$get(isvlist("I",i)) quit:isv=""  s isv=$piece(isv,"=") write " zwrite ",isv,!
  close out

  set out="isvlist.outx" open out:newver use out do ^isvlist
  close out

  set in="isvlist.outx" open in:readonly use in:(rewind:exception="goto EOF")
  set c=0
  for i=1:1  use in read x use $p do
  . ; Exclude some ISVs from comparison, as their values will be different
  . quit:x?1"$"1(1"STORAGE",1"Y",1"ZALLOCSTOR",1"ZCSTATUS",1"ZPOSITION",1"ZUSEDSTOR",1"ZREALSTOR",.1"Z"1"HOROLOG",1"ZUT",1"ZKEY")1"=".E
  . ; Compare ISV to previous value. If incorrec, issue an error
  . do:x'=isvlist("I",i)
  . . write "-------------------",!,x,!," vs.",!,isvlist("I",i),!,"-------------------",!
  . . set c=c+1

EOF
  close in
  use $p
  ;write "test"
  write !,$select($get(cnt)!$get(c):"FAIL",1:"PASS")," from ",$text(+0)
  quit

err
  set error=$piece($stack(estack,"MCODE"),";",2)
  if ""=error,$increment(cnt) write ! zshow "*"
  if $zstatus'[error,$increment(cnt) x act write !,"Expected: ",error,?20,"but got:",!,$zstatus
  set pos=$piece($stack(estack,"PLACE"),"^")
  set $ecode=""
  zgoto @(estack+1_":"_$piece(pos,"+")_"+"_($piece(pos,"+",2)+1))
