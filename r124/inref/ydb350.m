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
ydb350	;
	quit

readcmd	;
	write "; Below are terminal settings BEFORE READ command",!  use $p	; to flush terminal output
	do &sttydisp
	read x
	write "; Below are terminal settings AFTER  READ command",!  use $p	; to flush terminal output
	do &sttydisp
	quit

readstarcmd ;
	write "; Below are terminal settings BEFORE READ * command",!  use $p	; to flush terminal output
	do &sttydisp
	read *x
	write "; Below are terminal settings AFTER  READ * command",!  use $p	; to flush terminal output
	do &sttydisp
	quit

writecmd ;
	write "; Below are terminal settings BEFORE WRITE command",!  use $p	; to flush terminal output
	do &sttydisp
	write "dummy",!
	write "; Below are terminal settings AFTER  WRITE command",!  use $p	; to flush terminal output
	do &sttydisp
	quit
