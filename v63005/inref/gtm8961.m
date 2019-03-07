;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

writeslashpass
	set ^stop=0
	set sock="socket"
        open sock:(LISTEN="passsocket1:LOCAL":attach="passhandle1")::"SOCKET"
	use sock:(detach="passhandle1")
	open sock:(LISTEN="passsocket2:LOCAL":attach="passhandle2")::"SOCKET"
	job passchild
	use sock
	write /wait
	write /pass(,,"passhandle1")
	use $p
	set ^stop=1
	zsystem "$gtm_tst/com/wait_for_proc_to_die.csh "_$zjob
	quit

passchild
	set sock="socket"
	open sock:(CONNECT="passsocket2:LOCAL")::"SOCKET"
	use sock
	write /accept(.receivedsocket,,)
	set dollarkey=$key
	set dollarzsocket=$ZSOCKET("","LOCALADDRESS",)
	set o="output.txt"
	open o
	use o
	write "Output for ZSHOW D:  ",!
	ZSHOW "D"
	write "$KEY = ",dollarkey,!
	write "$ZSOCKET = ",dollarzsocket,!
	for  hang .1  quit:^stop
	quit

