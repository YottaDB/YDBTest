;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main	;;; client.m
	do ^sstepgbl
	S unix=$zv'["VMS"
	S portno=^realport
	w "realport: ",^realport
	S delim=$C(13),hostname="localhost"
	S tcpdev="client$"_$j
	S timeout=120
	W "Client: attempting connection",!
	; o tcpdev:(connect=hostname_":"_portno_":TCP":delimiter=delim:attach="client"):timeout:"SOCKET"
	o tcpdev:(connect=hostname_":"_portno_":TCP":attach="client"):timeout:"SOCKET"
	s key=$key
	w !,"client: ",key,!
	if unix do
	. ; To test : D9I06-002687  - TCP Read uses lots of CPU
	. ; sleep for 30 seconds and redirect the ps -fp output to a file, to be examined later by the main script
	. h 30
	. set pscommand="ps -fp "_^serverjobid_" >checkTIME_psout.out"
	. zsystem (pscommand)
	;
	u tcpdev w "Hello from cln2163"
	c tcpdev
	zwrite
	q
