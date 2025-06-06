;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmde534846 ;
	set initial(0)=0.1,hangtime(0)=0.045
	set initial(1)=.012345,hangtime(1)=0.005
	set initial(2)=.002345,hangtime(2)=0.001

	for i=0:1:2  do
	. set $ztimeout=initial(i)
	. hang hangtime(i)
	. if ($ztimeout>=(initial(i)-hangtime(i)))  do
	. . write "FAIL: $ztimeout="_$ztimeout_", but expected < "_(initial(i)-hangtime(i)),!
	. else  do
	. . zwrite $ztimeout

	quit
