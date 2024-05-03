;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; See v70003/u_inref/dlr_zkey_sig11-gtmde294187.csh for flow of this M program.

parent	;
	set njobs=2
	for i=1:1:njobs job child(i) set job(i)=$zjob
	set s="socket"
	for i=1:1:njobs do
	. set port=$select(i=1:$ztrnlnm("portno1"),1:$ztrnlnm("portno2"))
	. open s:(listen=port_":TCP"):15:"socket"
	use s
	for i=1:1:10000 do
	. write /wait
	. set zkey(i)=$zkey
	. hang:(""=zkey(i)) 0.001	; if data is not ready for read (possible on slower system), hang a bit
	use $p zwrite zkey(i)
	for i=1:1:njobs do ^waitforproctodie(job(i))
	quit

child(childindex)	;
	set s="socket"
	set port=$select(childindex=1:$ztrnlnm("portno1"),1:$ztrnlnm("portno2"))
	open s:(CONNECT="[127.0.0.1]:"_port_":TCP":ioerror="trap")::"SOCKET"
	quit

