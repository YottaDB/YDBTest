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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 	This test fills the database with some globals. These global can be categorized in two sets.
; First set includes the globals from ^A to ^Z. There are 300 nodes created with these globals.
; After these updates, INTEG report is run to determine the required database blocks, say 'rb'.
; And then database is recreated but this time global buffer is set to rb(=328) value.
; 	New GTM process makes same 300 updates in freshly created database plus it makes second set
; of 100 updates. This second set of 100 updates creates 100 new globals and creates new record for
; each global in the directory tree. This record for the global in directory tree contains the collation
; information.
; 	Another GTM process starts and fetches the first set of global nodes in the global buffer and
; makes them dirty by updating them. Now instance is frozen. After this point, MUPIP JOURNAL EXTRACT
; should not go to the database to fetch collation information. This is what is verified by this test.
; Along with it, it is also tested that if the database file is missing, MUPIP JOURNAL EXTRACT should not
; try to read the database file.

dbfill;
	for i=1:1:300 set char="^"_$zch(65+(i#26)) set char=char_"("_i_")" set @char=$j(i*i,900)
	for i=1:1:100 set ^x(i)=i set str="^"_$$^%RANDSTR(20,,,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") set @str=i
	quit
bufferfill;
	for i=1:1:300 set char="^"_$zch(65+(i#26)) set char=char_"("_i_")" set tmp=@char
	for i=1:1:300 set char="^"_$zch(65+(i#26)) set char=char_"("_i_")" set @char=$j(i*2,900)
	zsy "mupip replic -source -freeze=on -comment=FROZEN"
	write "----------------------------------------------------------------------------------------"
	zsy "mupip journal -extract=mumps.mjf -noverify -detail -for -fences=none mumps.mjl >&! freeze.out1 ; unsetenv gtm_extract_nocol; unsetenv ydb_extract_nocol; mupip journal -extract=mumps.mjf -noverify -detail -for -fences=none mumps.mjl >&! freeze.out2 ; setenv gtm_extract_nocol 1 ; mupip replic -source -freeze=off ; mv mumps.dat mumps.bak ; mupip journal -extract=mumps.mjf -noverify -detail -for -fences=none mumps.mjl >&! dbmissing.out1 ; unsetenv gtm_extract_nocol; mupip journal -extract=mumps.mjf -noverify -detail -for -fences=none mumps.mjl >&! dbmissing.out2"
	quit
