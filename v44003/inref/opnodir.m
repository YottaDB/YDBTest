;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
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

opnodir;;
	;; path component is not directory
	s unix=$ZV'["VMS"
	s sd="nosuchdir"
	o sd:new
	close sd
	if unix d
	. s sd="nosuchdir/abc.txt"
	else  s sd="[.nosuchdir]abc.txt"
	o sd:(readonly:exception="G BADOPEN")
	w "This should not be displayed",!
	u sd
	F  U sd R x U $P W x,!
	Q
BADOPEN
	w "Inside error handler",!
	ZWRITE $ZSTATUS
	Q
