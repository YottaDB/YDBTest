;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Open an active connection to the specified TCP/IP address
;	ip - address of server
;	port - TCP port on server
;
;	Returns
;		0 - failed.
;		1 - successful
open(ip,port)
	new dev
	i $D(tcpconn) w "Server connection already established",! q 0
	s tcpconn="gtcm"
	o tcpconn:::"SOCKET"	; create empty socket device
	o tcpconn:(connect=ip_":"_port_":TCP":ioerror="TRAP"):30:"SOCKET"
	s status=$T
	u tcpconn s dev=$DEVICE u $p
	i status=0 w "Timeout opening connection to server",!,dev,! zm GTMERR("GTM-E-OPENCONN") q 0
	i dev w "Error opening connection to server",!,dev,! zm GTMERR("GTM-E-OPENCONN") q 0
	s Server("ip")=ip
	s Server("port")=port
	q 1

; Close the current TCP/IP connection;
;	Return value:  none
close
	i $D(tcpconn)=0 w "No server connection to close",! b  q
	c tcpconn
	k tcpconn
	q

; Send an OMI packet through a connection.  This routine
; automatically prepends an OMI header to the specified
; message.
;	type - OMI request type
;	msg  - body of the OMI request (header automatically generated)
;
send(type,msg)
	new x,dev
	i '$data(tcpconn) w "No server connection established...",! q
	u tcpconn
	s x=$$str2VS^cvt($$encode^header(type)_msg)
	w x,!
	s dev=$DEVICE
	u $P
	i dev w "Error sending packet to server",!,dev,! b  q
	q


readerr
	if $P($ZSTATUS,",",3)="%GTM-E-IOEOF" u $P w "Socket closed by network partner",! b  u tcpconn q
	u tcpconn:exception=""
	q


; Reads a response to an OMI request from a connection.  This routine
; automatically decodes the header into the Resp local variable.
;
;	Return value:
;		a VS containing the body of the response packet (minus
;		the header).
;
receive()
	new msg,len,dev
	i '$data(tcpconn) w "No server connection established to receive...",! q ""
	u tcpconn:exception="do readerr"
	s msg=""
	r len#4:300
	s dev=$DEVICE
	i $T=0 u $P w "Error reading from server",!,dev,! b  q ""
	i dev u $P w "Error reading from server",!,dev,! b  q ""
	r msg#$$VI2num^cvt(len):300
	s dev=$DEVICE
	u $P
	i $T=0 w "Error reading from server",!,dev,! b  q ""
	i dev w "Error reading from server",!,dev,! b  q ""
	do decode^header(msg)
; The 13th byte is the first following the OMI header.
	q $E(msg,13,$L(msg))

