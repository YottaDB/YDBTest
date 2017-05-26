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
gtm6994

callin(val)
  write " passed value: ",val,!
  do testval(val)
  quit

callout
  new retval,status,longtests,ulongtests,testnum
  ;
  set longtests=$&longtestcount()
  write !,"testing ",longtests," longs",!,!
  for testnum=0:1:longtests-1  do
  . set retval=$&retlong(testnum) set:'$data(retval) retval=">>>undefined<<<"
  . do testval(retval)
  . set retval=0
  . do &longptrout(testnum,.retval)  set:'$data(retval) retval=">>>undefined<<<"
  . do testval(retval)
  ;
  set ulongtests=$&ulongtestcount()
  write !,"testing ",ulongtests," ulongs",!,!
  for testnum=0:1:ulongtests-1  do
  . set retval=$&retulong(testnum) set:'$data(retval) retval=">>>undefined<<<"
  . do testval(retval)
  . set retval=0
  . do &ulongptrout(testnum,.retval)  set:'$data(retval) retval=">>>undefined<<<"
  . do testval(retval)
  quit

testval(value)
  new cmpval
  set cmpval=value+0 write:value'=cmpval value,"+0 <> ",cmpval,!
  set cmpval=value-2+2 write:value'=cmpval value,"-2+2 <> ",cmpval,!
  set cmpval=value+2-2 write:value'=cmpval value,"+2-2 <> ",cmpval,!
  set cmpval=value-10+10 write:value'=cmpval value,"-10+10 <> ",cmpval,!
  set cmpval=value+10-10 write:value'=cmpval value,"+10-10 <> ",cmpval,!
  quit

nestcallin(depth,maxdepth)
  ; test nesting of call-ins with huge stringpools and exclusive news to make sure alias garbage collection works fine
  new retval,j
  if (depth#3=0) new (depth,maxdepth)
  set *x(depth)=stringpool
  for j=1:1:depth set @("x"_depth_"y"_j)="xxxxxxxx"_depth
  set stringpool(depth)=$justify("",80000)_$get(stringpool(depth-1))
  if depth<maxdepth set retval=$&nestxcall(depth+1,maxdepth)+depth
  else   set retval=0
  quit retval

