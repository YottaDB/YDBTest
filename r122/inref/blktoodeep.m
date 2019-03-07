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

blktoodeep;
	IF '##class(%File).DirectoryExists(XOBDIR) DO  QUIT 0
	. WRITE !," o  Directory does not exist: "_XOBDIR
	IF '##class(%File).Exists(XOBPATH) DO  QUIT 0
	. WRITE !," o  File to be imported does not exist: "_XOBPATH
	quit
