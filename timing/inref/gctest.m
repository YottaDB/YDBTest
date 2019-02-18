;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gcTest   ; Examine some GT.M GC issues.

gcTest1  ; Basic test - 94.8s.
   do dotest()
   quit  ; >>> gcTest1

zhtm(zh,ms)  ; Return timestamp based on $zh value
   ;
   new (z,zh,ms)
   set zh=$g(zh,$zh)
   set t=$piece(zh,",")*3600*24+$piece(zh,",",2)+($piece(zh,",",3)/1E6)
   if '$quit do
   .  set z("lszh")=$g(z("lszh"),t)
   .  write "tm:"_$j(t-z("lszh"),14,7)_"s"_" "_$VIEW("SPSIZE")_" "_$g(ms),!
   .  set z("lszh")=t
   quit:$quit t quit  ; >>> zhtm

dotest()  ; Try to produce a catastrophic GC situation.
   ;
   new (z)
   ;
   do zhtm(,"test-Start")
   ;
   ; 200,000 * 10 * (15+6) = ~42,000,000
   set lsspsz=""
   set numiters=+$piece($zcmdline," ",1)
   for i=0:1:numiters do
   .  set spsz=$VIEW("SPSIZE")
   .  if (+spsz'=+lsspsz)!($piece(spsz,",",2)<$piece(lsspsz,",",2)) do zhtm(,"test-"_i_" "_lsspsz)
   .  set lsspsz=spsz
   .  kill rc
   .  for r=1:1:10 do
   .  .  set rc($ze("abcdefghijklmnopqrstuvwxyz",r,r+5))=$zj("",15) ; ="aaaaabbbbbccccc" (constant here results in interesting optimizations)
   .  merge rs("foo",i)=rc
   ;
   do zhtm(,"test-DONE")
   quit  ; >>> dotest

check	;
	;
	set file=$zcmdline
	open file:(exception="goto done")
        for i=1:1 use file  read cpu(i)
done    if '$zeof write $zstatus,!
        close file
	set errcnt=0
	set i=i-1
	set allowedscale=2.5 ; see comments in timing/u_inref/gctest.csh about allowing 2.5x increase every iteration
	for j=1:1:i-1  do
	. set actualscale(j)=(cpu(j+1)/cpu(j))*100\1/100
	. if $incr(actualscale,actualscale(j))
	if actualscale>(allowedscale*j) do
	. write "TEST-E-FAIL : cpu(",j+1,")=",cpu(j+1)," is ",actualscale,"x times cpu(1)=",cpu(1)," but max allowed is ",allowedscale*j,"x",!
	. if $incr(errcnt)
	if errcnt=0 write "TEST-E-PASS",!
	else        write !,"ZSHOW ""V"" output follows",! zshow "v"
        quit
