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

	SET encodings="UTF-16"
	SET encodings="UTF-16 UTF-16BE UTF-16LE"

	FOR I=1:1:$L(encodings," ") DO
	. SET chset=$P(encodings," ",I)
	. SET file="gtm8923"_chset_".file"
	.
	. ;READ * test
	. OPEN file:CHSET=chset:10
	. USE file:CHSET=chset
	. WRITE "1",!
	. CLOSE file
	. OPEN file:CHSET=chset:10
	. USE file:CHSET=chset
	. READ *x,!
	. CLOSE file
	. USE $P
	. WRITE "READ * test on "_chset_" file:"
	. WRITE x,!
	. ;CLOSE file
	.
	. ;WRITE * test
	. OPEN file:CHSET=chset:10
	. USE file:CHSET=chset
	. WRITE *"49",!
	. CLOSE file
	. OPEN file:CHSET=chset:10
	. USE file:CHSET=chset
	. READ x,!
	. CLOSE file
	. USE $P
	. WRITE "WRITE * test on "_chset_" file:"
	. WRITE x,!

        do ^job("child^gtm8923",2,"""""")     ; start 2 jobs ; .

	WRITE ^readTests("1"),!
	WRITE ^writeTests("1"),!

	WRITE ^readTests("2"),!
	WRITE ^writeTests("2"),!

	WRITE ^readTests("3"),!
	WRITE ^writeTests("3"),!


	quit

child
	SET encodings="UTF-16 UTF-16BE UTF-16LE"

	SET file="gtm8923.socket"

	FOR I=1:1:$L(encodings," ") DO
	. SET chset=$P(encodings," ",I)
	.
	. IF jobindex=1 DO  ;
	. . OPEN file:(CONNECT="gtm8923R"_I_".socket:LOCAL":attach="attach_socket":CHSET=chset):10:"SOCKET"
	. . USE file:CHSET=chset
	. . WRITE "1",!
	. . CLOSE file
	.
	. ELSE  IF jobindex=2 DO
	. . OPEN file:(LISTEN="gtm8923R"_I_".socket:LOCAL":attach="attach_socket":CHSET=chset):10:"SOCKET"
	. . USE file:CHSET=chset
	. . write /wait
	. . READ *x,!
	. . CLOSE file
	. . USE $P
	. . WRITE "READ * test on "_chset_" socket: "
	. . WRITE x,!
	. . SET ^readTests(I)="READ * test on "_chset_" socket: "_x
	.
	. ELSE  DO
	. . WRITE "INVALID JOBINDEX",!
	. . WRITE "jobindex= "_jobindex,!
	.
	.
	. ;WRITE * test
	. IF jobindex=1 DO  ;
	. . OPEN file:(CONNECT="gtm8923W"_I_".socket:LOCAL":attach="attach_socket":CHSET=chset):10:"SOCKET"
	. . USE file:CHSET=chset
	. . WRITE *"49",!
	. . CLOSE file
	.
	. ELSE  IF jobindex=2 DO
	. . OPEN file:(LISTEN="gtm8923W"_I_".socket:LOCAL":attach="attach_socket":CHSET=chset):10:"SOCKET"
	. . USE file:CHSET=chset
	. . write /wait
	. . READ x,!
	. . CLOSE file
	. . USE $P
	. . WRITE "WRITE * test on "_chset_" socket:"
	. . WRITE x,!
	. . SET ^writeTests(I)="WRITE * test on "_chset_" socket: "_x
	.
	. ELSE  DO
	. . WRITE "INVALID JOBINDEX",!
	. . WRITE "jobindex= "_jobindex,!

	quit
