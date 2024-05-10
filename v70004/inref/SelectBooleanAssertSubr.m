;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available 	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

test	; Expression from:
	;   https://gitlab.com/YottaDB/DB/YDB/-/issues/698#note_544075462
	;
	set $ztrap="write ""error: "",$piece($zstatus,"","",3,4),! halt"
	;
	set true=1
	set false=0
	set null=""
	set itrue="true"
	set ifalse="false"
	set inull="null"
	set ^false=0
	set ^ifalse="false"
	set ^itrue="true"
	;
	write (($$RetSame($select(false:1,1:0),4)!$random((($select(false:1,1:$zysqlnull)!('$select(true:1)))'&(((('@inull)'?1""0"")'&(((^false&($test&'null))'!((@^itrue'=('@ifalse))'[(@itrue]]@^ifalse)))?1""1""))=((0='$test)'[((('@itrue)&@inull)?1""0""))))))'&((($$Always0)'!^false)'=(@^ifalse'!(null'&$test))))
	quit
	;
Always0	; quit 0
	;
RetSame(boolvalue,depth) ;
	quit boolvalue	; return boolean value as is from function call
