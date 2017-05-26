;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2003, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; server.m
	S ^configasalongvariablename78901("hostname")="mumpsmonkey0",^configasalongvariablename78901("delim")=$C(13),^configasalongvariablename78901("portno")=6321
	S ^configasalongvariablename("portno")=1236 ; this is a different variable, so should work if longname works
	S portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim")
	S tcpdevasalongvariablename678901="server$"_$j,timeout=30
	set tcpdevasalongvariablename="which server?" ; this is a different variable for long names version !!!
	o tcpdevasalongvariablename678901:(LISTEN=portno_":TCP":attach="server"):timeout:"SOCKET"
	; o tcpdevasalongvariablename678901:(LISTEN=portno_":TCP":attach="server":delimiter=delim):timeout:"SOCKET"
	u tcpdevasalongvariablename678901
	w /listen(1)
	w /wait(timeout)
	s key=$key,childsocket=$p(key,"|",2),ip=$p(key,"|",3)
	u $P
	w !,"server: ",key,!
	; all yours
