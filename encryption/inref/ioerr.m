;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A helper script employed in the encryption/ioerr test. It
; (in most cases) produces an error that the test ensures is
; redirected to a correct location and encrypted, as appropriate.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fileFlush
	set file=$piece($zcmdline," ",1)
	set key=$piece($zcmdline," ",2)
	set iv=$piece($zcmdline," ",3)
	set flush=$piece($zcmdline," ",4)
	set string=$piece($zcmdline," ",5,99)
	open file:key=key_" "_iv
	use file
	write string
	set:('flush) $x=0
	quit

principalError
	set key=$piece($zcmdline," ",1)
	set iv=$piece($zcmdline," ",2)
 	use $principal:key=key_" "_iv
 	write 1/0
 	quit

principalWriteError
	set key=$piece($zcmdline," ",1)
	set iv=$piece($zcmdline," ",2)
	set flush=$piece($zcmdline," ",3)
	set string=$piece($zcmdline," ",4,99)
 	use $principal:key=key_" "_iv
	write string
	write:flush !
 	write 1/0
 	quit

fileWriteError
	set file=$piece($zcmdline," ",1)
	set key=$piece($zcmdline," ",2)
	set iv=$piece($zcmdline," ",3)
	set write=$piece($zcmdline," ",4)
	set string=$piece($zcmdline," ",5,99)
	open file:key=key_" "_iv
	use file
	write:(write) string,!
	if 1/0
	quit
