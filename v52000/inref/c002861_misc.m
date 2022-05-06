;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 write $x+$l(bb,2E22222222222222222222222233))
 set VL=""_$J($piece(T(T),2E22222222222222222222222233,6),"")
 set V="M"?@($MN("A",2E22222222222222222222222233)?.N)
 set V="M"?@($piece("A",2E22222222222222222222222233,$MN)?.N)
 set %=$x do $$^zu(x(x),@($piece($MN("A",2E22222222222222222222222233)?.N))
 set %=$x do @($piece($MN("A",2E22222222222222222222222233)?.N))
 set %=$x do $zu(x(x),@($piece(2E22222222222222222222222233,2E22222222222222222222222233,$MN)?.N))
 set %=$x goto @($piece($MN("A",2E22222222222222222222222233)?.N))
 set %=$x goto @($piece($MN(2E22222222222222222222222233,2E22222222222222222222222233)?.N))
 set %=$x zgoto @($piece($MN("A",2E22222222222222222222222233)?.N))
 set %=$x zgoto @($piece($MN(2E22222222222222222222222233,2E22222222222222222222222233)?.N))
 set %=$x do $$^zu(x(x),@($piece("A",2E22222222222222222222222233,$MN)?.N))
 write $data(@($piece(x(x),2E22222222222222222222222233,$MN)?.N))
 write $data(@($piece(x(x),$MN,2E22222222222222222222222233)?.N))
 write $get(@($piece(x(x),$MN,2E22222222222222222222222233)?.N))
 write $get(@($piece(x(x),2E22222222222222222222222233,$MN)?.N))
 write $incr(x(x),$piece(x(x),2E22222222222222222222222233,$MN)?.N)
 write $incr(x(x),$piece(x(x),$MN,2E22222222222222222222222233)?.N)
 write $incr(x(x),@($piece(x(x),$MN,2E22222222222222222222222233)?.N))
 write $incr(x(x),@($piece(x(x),$MN,$MN(2E22222222222222222222222233))?.N))
 write $order(@($piece(x(x),$MN,$MN(2E22222222222222222222222233)?.N)))
 write $zprevious(@($piece(x(x),$MN,$MN(2E22222222222222222222222233)?.N)))
 write $zqgblmod(@($piece(x(x),$MN,$MN(2E22222222222222222222222233)?.N)))
 write $order(@($piece(x(x),$MN,$MN(1)?.N)),@($piece(x(x),$MN,$MN(2E22222222222222222222222233))?.N))
 write $query(@($piece(x(x),$MN,$MN(2E22222222222222222222222233)?.N)))
 write $select(0:@($piece(x(x),$MN,$MN(1)?.N)),1:@($piece(x(x),$MN,$MN(2E22222222222222222222222233)?.N)))
 xecute @($piece(x(x),$MN,$MN(2E22222222222222222222222233)?.N))
 write $x+$l(bb,"€"))
 set VL=""_$J($piece(T(T),"€",6),"")
 set V="M"?@($MN("A","€")?.N)
 set V="M"?@($piece("A","€",$MN)?.N)
 set %=$x do $$^zu(x(x),@($piece($MN("A","€")?.N))
 set %=$x do @($piece($MN("A","€")?.N))
 set %=$x do $zu(x(x),@($piece(2E22222222222222222222222233,"€",$MN)?.N))
 set %=$x goto @($piece($MN("A","€")?.N))
 set %=$x goto @($piece($MN(2E22222222222222222222222233,"€")?.N))
 set %=$x zgoto @($piece($MN("A","€")?.N))
 set %=$x zgoto @($piece($MN(2E22222222222222222222222233,"€")?.N))
 set %=$x do $$^zu(x(x),@($piece("A","€",$MN)?.N))
 write $data(@($piece(x(x),"€",$MN)?.N))
 write $data(@($piece(x(x),$MN,"€")?.N))
 write $get(@($piece(x(x),$MN,"€")?.N))
 write $get(@($piece(x(x),"€",$MN)?.N))
 write $incr(x(x),$piece(x(x),"€",$MN)?.N)
 write $incr(x(x),$piece(x(x),$MN,"€")?.N)
 write $incr(x(x),@($piece(x(x),$MN,"€")?.N))
 write $incr(x(x),@($piece(x(x),$MN,$MN("€"))?.N))
 write $order(@($piece(x(x),$MN,$MN("€")?.N)))
 write $zprevious(@($piece(x(x),$MN,$MN("€")?.N)))
 write $zqgblmod(@($piece(x(x),$MN,$MN("€")?.N)))
 write $order(@($piece(x(x),$MN,$MN(1)?.N)),@($piece(x(x),$MN,$MN("€"))?.N))
 write $query(@($piece(x(x),$MN,$MN("€")?.N)))
 write $select(0:@($piece(x(x),$MN,$MN(1)?.N)),1:@($piece(x(x),$MN,$MN(€"")?.N)))
 xecute @($piece(x(x),$MN,$MN(€"")?.N))
 set (x,$ZZ,z(2E22222222222222222222222233))=($piece($h,"","",2)*0)+15
 set (x,$ZZ,z(x))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,z(2E22222222222222222222222233))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,^z(2E22222222222222222222222233))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,@y(2E22222222222222222222222233))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$$x(2E22222222222222222222222233))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$order(2E22222222222222222222222233))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece(x(2E22222222222222222222222233)))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece(^z(2E22222222222222222222222233)))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece(@y(2E22222222222222222222222233)))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece($$x(2E22222222222222222222222233)))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece(x(y)))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece(x(y),2E22222222222222222222222233))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece(x(y),"x",2E22222222222222222222222233))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$extract(x(y)))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$extract(x(y),2E22222222222222222222222233))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece(x(y),"x")=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$$x(y))=($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$$x(y))($piece($h,"",2E22222222222222222222222233)*0)+15
 set ($ZZ,$piece(x(y),"x"))=($piece($h,"",2E22222222222222222222222233)*0)+15
 S Y="%" F  M:$D(@Y) @(X_"Y)="_Y) S Y=$O(@Y) Q:Y=""  ; exposed duplicate triple insertion bug in m_merge.c
 write $x+$l(bb,2E22222222222222222222222233)		; Below cases are additions due to [YDB#371]
 write $x+$l("abcd",2E22222222222222222222222233)
 set VL=""_$J($piece("abcd",2E22222222222222222222222233,6),"")
 write $data(@($piece("abcd",2E22222222222222222222222233,$MN)?.N))
 write $data(@($piece("abcd",$MN,2E22222222222222222222222233)?.N))
 write $get(@($piece("abcd",$MN,2E22222222222222222222222233)?.N))
 write $get(@($piece("abcd",2E22222222222222222222222233,$MN)?.N))
 write $incr("abcd",$piece("abcd",2E22222222222222222222222233,$MN)?.N)
 write $incr("abcd",$piece("abcd",$MN,2E22222222222222222222222233)?.N)
 write $incr("abcd",@($piece("abcd",$MN,2E22222222222222222222222233)?.N))
 write $incr("abcd",@($piece("abcd",$MN,$MN(2E22222222222222222222222233))?.N))
 write $order(@($piece("abcd",$MN,$MN(2E22222222222222222222222233)?.N)))
 write $zprevious(@($piece("abcd",$MN,$MN(2E22222222222222222222222233)?.N)))
 write $zqgblmod(@($piece("abcd",$MN,$MN(2E22222222222222222222222233)?.N)))
 write $order(@($piece("abcd",$MN,$MN(1)?.N)),@($piece("abcd",$MN,$MN(2E22222222222222222222222233))?.N))
 write $query(@($piece("abcd",$MN,$MN(2E22222222222222222222222233)?.N)))
 write $select(0:@($piece("abcd",$MN,$MN(1)?.N)),1:@($piece("abcd",$MN,$MN(2E22222222222222222222222233)?.N)))
 xecute @($piece("abcd",$MN,$MN(2E22222222222222222222222233)?.N))
