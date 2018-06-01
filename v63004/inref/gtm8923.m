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
gtm8923
	SET $etrap="use $p zshow ""*"" halt"

	SET ^encodings="UTF-16 UTF-16BE UTF-16LE"

	SET testCases="49 174"

	FOR J=1:1:$L(testCases," ") DO
	. SET ^testPoint=$P(testCases," ",J)
	. WRITE "Testing ASCII dec char "_^testPoint_":",!
	. WRITE "------------------------------------------",!
	. DO testLoop
	. WRITE !

	quit

testLoop
	FOR I=1:1:$L(^encodings," ") DO
	. SET chset=$P(^encodings," ",I)
	. SET file="gtm8923"_chset_".file"
	. ;READ * test
	. OPEN file:CHSET=chset
	. USE file:CHSET=chset
	. WRITE $char(^testPoint),!
	. CLOSE file
	. OPEN file:CHSET=chset
	. USE file:CHSET=chset
	. READ *text,!
	. CLOSE file
	. USE $P
	. WRITE "READ * test on "_chset_" file:",!
	. ZWRITE text
	. WRITE !
	. ;WRITE * test
	. OPEN file:CHSET=chset
	. USE file:CHSET=chset
	. WRITE *^testPoint,!
	. CLOSE file
	. OPEN file:CHSET=chset
	. USE file:CHSET=chset
	. READ text,!
	. CLOSE file
	. USE $P
	. WRITE "WRITE * test on "_chset_" file:",!
	. ZWRITE text
	. WRITE !,!

        do ^job("child^gtm8923",2,"""""")     ; start 2 jobs ; .

	FOR I=1:1:$L(^encodings," ") DO
	. SET chset=$P(^encodings," ",I)
	. ;READ * test
	. SET text=^readTests(I)
	. WRITE "READ * test on "_chset_" socket:",!
	. ZWRITE text
	. WRITE !
	. ;WRITE * test
	. SET text=^writeTests(I)
	. WRITE "WRITE * test on "_chset_" socket:",!
	. ZWRITE text
	. WRITE !,!

	quit

child
	SET file="gtm8923.socket"

	FOR I=1:1:$L(^encodings," ") DO
	. SET chset=$P(^encodings," ",I)
	. ;READ * test
	. IF jobindex=1 DO  ;
	. . OPEN file:(CONNECT="gtm8923R"_I_".socket:LOCAL":attach="attach_socket":CHSET=chset)::"SOCKET"
	. . USE file:CHSET=chset
	. . WRITE $char(^testPoint),!
	. . CLOSE file
	. ELSE  IF jobindex=2 DO
	. . OPEN file:(LISTEN="gtm8923R"_I_".socket:LOCAL":attach="attach_socket":CHSET=chset)::"SOCKET"
	. . USE file:CHSET=chset
	. . write /wait
	. . READ *text,!
	. . CLOSE file
	. . USE $P
	. . WRITE "READ * test on "_chset_" socket: "
	. . WRITE text,!
	. . SET ^readTests(I)=text
	. ELSE  DO
	. . WRITE "INVALID JOBINDEX",!
	. . WRITE "jobindex= "_jobindex,!
	. ;WRITE * test
	. IF jobindex=1 DO  ;
	. . OPEN file:(CONNECT="gtm8923W"_I_".socket:LOCAL":attach="attach_socket":CHSET=chset)::"SOCKET"
	. . USE file:CHSET=chset
	. . WRITE *^testPoint,!
	. . CLOSE file
	. ELSE  IF jobindex=2 DO
	. . OPEN file:(LISTEN="gtm8923W"_I_".socket:LOCAL":attach="attach_socket":CHSET=chset)::"SOCKET"
	. . USE file:CHSET=chset
	. . write /wait
	. . READ text,!
	. . CLOSE file
	. . USE $P
	. . WRITE "WRITE * test on "_chset_" socket:"
	. . WRITE text,!
	. . SET ^writeTests(I)=text
	. ELSE  DO
	. . WRITE "INVALID JOBINDEX",!
	. . WRITE "jobindex= "_jobindex,!

	quit
