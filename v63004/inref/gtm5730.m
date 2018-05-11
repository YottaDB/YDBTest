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
gtm5730()
	 TSTART
	 FOR i=1:1:2000 set ^x(i)=i ;
	 FOR i=1:1:2000 W ^x(i);

	 TCOMMIT

	 ;ensures all updates to DB are moved from memory to disk
	 ;mupip journal -extract (done in caller script right after this M program exits) only checks the disk
	 view "flush"

	 quit

