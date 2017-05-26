CLIENT2	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/25/00 18:59:22 - LIX
	; This program should run all the time till ^stopasalongvariablename45678901 is set.
	; It tries to get a connection from a host on a certain port and read whatever is available
	; till the server closes its connection, in which case, exception handler should initiate another
	; round of reconnection and reading
	s hostname=^configasalongvariablename78901("hostname"),portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim")
	s tcpdevasalongvariablename678901="client$"_$j,timeout=5
	s:'$d(^cnt) ^cnt=0
	s dataread=0
	d log("CLIENT2 START")
	d connect
	q:$d(^stopasalongvariablename45678901)
	u tcpdevasalongvariablename678901:(ioerror="T":exception="d reconnec")
	f  q:$d(^stopasalongvariablename45678901)  u tcpdevasalongvariablename678901  r x  u $P  zwr x  s x=$H_" "_x  s ^dataread(dataread)=1,^dataread(dataread,$H)=1,dataread=dataread+1 d log(x)
	q
reconnec
	c tcpdevasalongvariablename678901
	d log("CONNECTION LOST")
	q:$d(^stopasalongvariablename45678901)
connect	s t=0
	f i=1:1  d  q:t
	. i $d(^stopasalongvariablename45678901)  d log("PROCESS SHUTDOWN")  s t=1  q
	. o tcpdevasalongvariablename678901:(ichset="UTF-8":connect=hostname_":"_portno_":TCP":delimiter=$C(512):attach="client"):timeout:"SOCKET"
	. s t=$T
	. i t  d
	. . u tcpdevasalongvariablename678901:(ioerror="T":exception="d reconnec")  
	. . s key=$key  
	. . d log("CONNECTION ESTABLISHED -- "_key)
	. e  d log("NO CONNECTION AVAILABLE")
	q
log(str)
	l +^cnt
	s ^tcpasalongvariablename45678901(^cnt,$H,tcpdevasalongvariablename678901)=str,^cnt=^cnt+1
	l
	q
