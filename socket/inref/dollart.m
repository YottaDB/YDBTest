;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dollart	;;; dollart.m
	;   to verify that w /wait(5) should set $T to 0 if not getting a connection.
	s tcpdevasalongvariablename678901="server$"_$j,tcpport=6091,timeout=5,delim=$C(13)
	o tcpdevasalongvariablename678901:(LISTEN=tcpport_":TCP":attach="server":delimiter=delim):timeout:"SOCKET"
	e  w !,"Bind failed",!  q
	W !,"Bind successful",!
	u tcpdevasalongvariablename678901
	w /listen(1)
	i $P($key,"|",1)'="LISTENING"  u $P  W !,"Listen failed",!  c tcpdevasalongvariablename678901  q
	u $P
	w !,"Listen successful",!
	i 1
	u tcpdevasalongvariablename678901
	w /wait(5)
	e  u $P  w !,"PASS -- It did set $T to FALSE",!  c tcpdevasalongvariablename678901  q
	i $P($key,"|",1)'="CONNECT"  u $P  W !,"FAIL -- It should have set $T to FALSE",!  q
	s key=$key
	u $P
	w !,"NOT SURE -- We got a connection which we didnot intend to get"
	w !,"            connection is from ",key,!
	w !,"            Please try again!",!
	c tcpdevasalongvariablename678901
	q

