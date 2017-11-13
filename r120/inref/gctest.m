;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gcTest   ; Examine some GT.M GC issues.

gcTest1  ; Basic test - 94.8s.
   d dotest()
   q  ; >>> gcTest1

zhtm(zh,ms)  ; Return timestamp based on $zh value
   ;
   n (z,zh,ms)
   s zh=$g(zh,$zh)
   s t=$p(zh,",")*3600*24+$p(zh,",",2)+($p(zh,",",3)/1E6)
   i '$quit d
   .  s z("lszh")=$g(z("lszh"),t)
   .  w "tm:"_$j(t-z("lszh"),14,7)_"s"_" "_$VIEW("SPSIZE")_" "_$g(ms),!
   .  s z("lszh")=t
   q:$quit t q  ; >>> zhtm

dotest()  ; Try to produce a catastrophic GC situation.
   ;
   n (z)
   ;
   d zhtm(,"test-Start")
   ;
   ; 200,000 * 10 * (15+6) = ~42,000,000
   s lsspsz=""
   s numiters=+$piece($zcmdline," ",1)
   f i=0:1:numiters d
   .  s spsz=$VIEW("SPSIZE")
   .  i (+spsz'=+lsspsz)!($p(spsz,",",2)<$p(lsspsz,",",2)) d zhtm(,"test-"_i_" "_lsspsz)
   .  s lsspsz=spsz
   .  k rc
   .  f r=1:1:10 d
   .  .  s rc($ze("abcdefghijklmnopqrstuvwxyz",r,r+5))=$zj("",15) ; ="aaaaabbbbbccccc" (constant here results in interesting optimizations)
   .  m rs("foo",i)=rc
   .  ;m rs("foo",300000-i)=rc ; Reversing subscripts - no help
   .  ;m rs("foo",-i)=rc   ; Negative subscript - no help
   .  ;s n="" f  s n=$o(rc(n)) q:n=""  s rs("foo",i,n)=rc(n)  ; No change here.
   ;
   d zhtm(,"test-DONE")
   q  ; >>> dotest

check	;
	;
	set file=$zcmdline
	open file:(exception="goto done")
        for i=1:1 use file  read cpu(i)
done    if '$zeof write $zstatus,!
        close file
	set errcnt=0
	set i=i-1
	for j=1:1:i-1  do
	. set max=cpu(j)*3
	. if cpu(j+1)>max write "TEST-E-FAIL : ",! zshow "v"  if $incr(errcnt)
	if errcnt=0 write "TEST-E-PASS",!
        quit
