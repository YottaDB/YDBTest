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
testdate ;
	; should also test:
	;s $ZDATEFORM=3 << fix, it should be set'able.
	;%YDB-E-SVNOSET, Cannot SET this special variable
	;        s $ZDATEFORM=3
	;n $ZDATEFORM
	;%YDB-E-INVSVN, Invalid special variable name
	;        n $ZDATEFORM
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	w "$ZDATEFORM:",$ZDATEFORM,!
	d ^%D ; change to %D
	s $ZDATEFORM=1
	w !,"$ZDATEFORM:",$ZDATEFORM,!
	d ^%D ; change to %D
	d do("0","DEFAULT","2")
	d do("1","current century","2 [-1999],4 [2000-]")
	d do("1900","[1900-1999]","4")
	d do("1925","[1925-2024]","4")
	d do("1980","[1980-2079]","4")
	d do("2000","[2000-2099]","4")
	d do("-12345","something invalid (current century)",4)
	d do("123","something invalid (current century)","4")
	d do("1839","something invalid (current century)",4)
	d do("1840","something invalid (current century)",4)
	d do("1841","year 0 for GT.M ([1841-1940])",4)
	d do("1860","[1860-1959]",4)
	d do("1890","[1890-1979]",4)
	d do("2025","[2025-2124]",4)
	d do("3025","%H cannot handle such large $H",4)
	d testh
	q
do(var,var2,var4)
	W !,"-----------------------------------------------------------",!
	s $ZDATEFORM=var
	w "ZDATE_FORM: ",$J($ZDATEFORM,6)," ",var2,?55,"  #%D OUTPUT DIGITS: ",var4,!
	w "-----------------",!
	s test="doh" ;%H
	d testdo
	w "----------",!
	s test="dodate" ;%DATE
	d testdo
	q
testdo	s testdo=test_"(var,""1/1/75"")" d @testdo
	s testdo=test_"(var,""10/10/20"")" d @testdo
	s testdo=test_"(var,""10/20/24"")" d @testdo
	s testdo=test_"(var,""1/1/25"")" d @testdo
	s testdo=test_"(var,""1/1/95"")" d @testdo
	s testdo=test_"(var,""3/3/00"")" d @testdo
	s testdo=test_"(var,""9/9/69"")" d @testdo
	s testdo=test_"(var,""9/9/1969"")" d @testdo
	q
dodate(var,var3)	;
	s res=$$FUNC^%DATE(var3)
	s %DT=res
	d %CDS^%H
	w "%DATE input:",$J(var3,10)," means -> $H: ",res," -> ",$J(%DAT,10),!
	;zwr
	q
doh(var,var3) ;
	;s %DT=h
	;do %CDS^%H ; always outputs in 4 digits
	s %DT=var3
	d %CDN^%H
	s %DT=%DAT
	d %CDS^%H
	w "%H    input:",$J(var3,10)," means -> $H: ",%DT," -> ",$J(%DAT,10),!
	;zwr
	q
testh	;
	w "%H cannot handle $H dates after 2/28/2100",!
	f h=94655:1:94660 w h,": ",$$CDS^%H(h),!
	; the last $H %H can handle is 94657 (2/28/2100)
	q
