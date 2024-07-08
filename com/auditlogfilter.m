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

; This filter masks out several fields in audit log
; For more information on audit logging, see:
;   http://tinco.pair.com/bhaskar/gtm/doc/books/ao/UNIX_manual/ch03s06.html
;
; Typical usage:
;   cat $aulogfile | $gtm_dist/mumps -run "filter^auditlogfilter"


filter	; mask out session- and host-dependent values from audit log
	;
	for  do  quit:line=""
	.read line
	.if line="" quit
	.;
	.if $piece(line,";",2)["dist=" do
	..set $piece(line,";",1)="<timestamp_masked>"
	..set $piece(line,";",2)=" dist=<masked>"
	..set $piece(line,";",4)=" uid=<masked>"
	..set $piece(line,";",5)=" euid=<masked>"
	..set $piece(line,";",6)=" pid=<masked>"
	..set $piece(line,";",7)=" tty=<masked>"
	.;
	.write line,!
	quit
