;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
erasebs;
	write "Test the different values for special terminal input character ERASE and BACKSPACE key",!,!
	set bs=$char(8)		; BACKSPACE key
	set erase=$char(127)	; c_cc[VERASE] value - ERASE character
	use $p:(EMPT)
	write "Enter ERASE special terminal input character",!
	read x
	write:(($zb=$key)&($zb=erase)) "PASS",!
	write "Enter backspace key",!
	read x
	write:(($zb=$key)&($zb=bs)) "PASS",!
	quit

