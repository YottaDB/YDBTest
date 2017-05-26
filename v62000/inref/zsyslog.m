;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; 	Copyright 2014 Fidelity Information Services, Inc	;
; 								;
; 	This source code contains the intellectual property	;
; 	of its copyright holder(s), and is made available	;
; 	under a license.  If you do not know the terms of	;
; 	the license, please stop and do not read further.	;
;	    	     	    	     	    	 		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Test for $ZSYSLOG() (added via GTM-7999).
;
; Test for being the first message to oplog and not first message (aka do it twice) to check for
; one-off issues in reused buffer.
;
	;
	; First up, push out a message to muck up the buffers
	;
	zmessage 150379139:99999999		; SUSPENDING informational message
	if $zsyslog("Very bogus syslog message #1 from v62000/zsyslog test that is sort-of long")
	;
	; Now use a more complex message to muck things up further
	;
	zmessage 150376563:"ignore-this":3735928559:3735928559:"ignore-this":3735928559:3735928559:"ignore-this":999999999 ; DBCERR
	;
	; And push another shorter msg out that shouldn't have artifacts from the last msg.
	;
	if $zsyslog("Another shorter bogus syslog message #2 from v62000/zsyslog test")
	quit
