;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb1093	;
	write "; This test does $zextract() of a UTF-8 literal (ö) with a byte length of 2 and character length of 1",!
	write "; and then does a $zlength() on it and expects the return to be 1",!
	write "; Before YDB#1093 fixes (YDB@e4ae9bcc), it used to incorrectly return a value of 2",!
	write "; After the fixes, it correctly returns the expected value of 1",!
	write ";",!
	write "; Note we also test a few other combinations (i.e. $zlength on $extract) even though they are not pertinent",!
	write "; Note that this test may run in M or UTF-8 mode (test framework random choice) and so the reference file",!
	write "; is coded to expect different outputs based on the mode/chset",!
	write !
	write "$zchset = ",$zchset,!
	write "$zlength($zextract(""ö"")) = ",$zlength($zextract("ö")),!
	write "$zlength($zextract(""ö"",1)) = ",$zlength($zextract("ö",1)),!
	write "$zlength($zextract(""ö"",1,1)) = ",$zlength($zextract("ö",1,1)),!
	write "$zlength($zextract(""ö"",1,2)) = ",$zlength($zextract("ö",1,2)),!
	write "$zlength($extract(""ö"")) = ",$zlength($extract("ö")),!
	write "$zlength($extract(""ö"",1)) = ",$zlength($extract("ö",1)),!
	write "$zlength($extract(""ö"",1,1)) = ",$zlength($extract("ö",1,1)),!
	write "$zlength($extract(""ö"",1,2)) = ",$zlength($extract("ö",1,2)),!
	quit
