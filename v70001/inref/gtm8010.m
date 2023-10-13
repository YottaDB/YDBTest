;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-8010 Implement only the last part of this issue - specifically, the part where the value of
;          EXCEPTION= strings of length 128 to 255 could be mishandled potentially resulting in a
;	   segmentation violation (SIG-11) on an open of /dev/null.
;
; The full writeup for this test is in v70001/u_inref/gtm8010.csh.
;
gtm8010
	;
	; This test generates exception string from 32 bytes all the way up to 251 bytes. For the last
	; test, we just add three zeroes to the end to make the string exactly 255 bytes (which the test
	; verifies). Each string is tested with an open/close of /dev/null
	;
	set outfile="gtm8010_exception_strings.txt"
	open outfile:new
	set devnull="/dev/null"
	set errcnt=0
	set exceptblk="set x="
	set exceptstr="set y=$increment(errcnt)"
	for i=1:1:26 do
	. set exceptstr=exceptstr_" "_exceptblk_i
	. write "Testing iteration ",i," with exception length ",$zlength(exceptstr),!
	. use outfile write "Iteration ",i,": ",exceptstr,! use $P
	. do tryopen(exceptstr)
	set $zpiece(suffix,"0",255-$zlength(exceptstr)+1)=""
	set exceptstr=exceptstr_suffix
	if $zlength(exceptstr)'=255 do
	. write "FAILURE - final except string is not length 255 (len=",$zlength(exceptstr),!
	. zhalt
	write "Testing iteration ",i+1," with exception length ",$zlength(exceptstr),!
	use outfile write "Iteration ",i+1,": ",exceptstr,! use $P
	do tryopen(exceptstr)
	write:errcnt=0 !,"Pass GTM8010 with no errors",!
	write:errcnt'=0 !,"** FAILURE - Errors detected - See previous error messages",!
	close outfile
	quit

;
; Routine to attempt open of /dev/null with a given exception string. Return if success, (which we
; expect), else, probably stopping with a SIG-11 on pre-V70001 versions.
;
tryopen(exceptstr)
	new $etrap
	set $etrap="do openerr quit"
	open devnull:(exception=exceptstr)
	use devnull
	write "discarded text ",$random(99999999),!	; Write a little something with randomized length
	close devnull
	quit

;
; $ETRAP error routine that gets invoked if we hit a non-device issue
;
openerr
	write " *** $zstatus: ",$zstatus,!
	set $ecode=""
	quit



