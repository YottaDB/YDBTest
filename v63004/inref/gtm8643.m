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
gtm8643
 	set tcpdev="server$"_$j
 	set portno=0
	set timeout=10

 	open tcpdev:(ZLISTEN=portno_":TCP":attach="server"):timeout:"SOCKET"

	FOR queueDepth=4:1:6 DO
 		. use $p	; principal device
		. WRITE "WRITE /listen("_queueDepth_"):",!
 		. use tcpdev
 		. WRITE /listen(queueDepth)
		. WRITE !

	quit


