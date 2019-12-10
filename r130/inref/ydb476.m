;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This routine checks the behavior of $ZSIGPROC on receiving invalid input
; Invalid input: "12x"
; Expected output: Return value of $ZSIGPROC is "not" 0. As 0 represents
; 		   successful transfer of signal to process.
invalidsignamelookup
	write "checking zsigproc's handling of invalid input having mixed value",!
	new sigval,outp
	set sigval="12x"
	set outp=$ZSigproc($j,sigval)
	if (outp=0) do
	. write "FAILED, expected non zero result for signalvalue ",sigval," but received  ",outp,!
	write "Completed",!,!
	quit

