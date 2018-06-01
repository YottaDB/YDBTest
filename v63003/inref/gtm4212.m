;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
gtm4212
	set p230="temp230.out"
	set p231="temp231.out"
	set ple230="temple230.out"
	set pge231="tempge231.out"
	open p230
	open p231
	open ple230
	open pge231
	use p230 do patheq(230)
	use p231 do patheq(231)
	use ple230 do patheq(230-1-$random(10))
	use pge231 do patheq(231+1+$random(10))
	quit

patheq(n)
	write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	write "a"
	set l=l+1
	if l<n do  goto patheq+5
	. if l#25=0  write "/"
	. else  write "a"
	. set l=l+1
	quit


