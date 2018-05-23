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
 	set timeout=10
 	set tcpdev="server$"_$j
 	set portno=0

 	open tcpdev:(ZLISTEN=portno_":TCP":attach="server"):timeout:"SOCKET"

 	use $p	; principle device
	WRITE "WRITE /listen(4):",!
 	use tcpdev
 	WRITE /listen(4)
 	WRITE /wait(timeout)
	WRITE !

 	use $p	; principle device
	WRITE "WRITE /listen(5):",!
 	use tcpdev
 	WRITE /listen(5)
 	WRITE /wait(timeout)
	WRITE !

 	use $p	; principle device
	WRITE "WRITE /listen(6):",!
 	use tcpdev
 	WRITE /listen(6)
 	WRITE /wait(timeout)
	WRITE !

	quit


