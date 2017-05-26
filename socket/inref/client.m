	;;; client.m
	S ^configasalongvariablename78901("hostname")="mumpsmonkey0",^configasalongvariablename78901("delim")=$C(13),^configasalongvariablename78901("portno")=6321
	S portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim"),hostname=^configasalongvariablename78901("hostname")
	S tcpdevasalongvariablename678901="client$"_$j,timeout=30
	; o tcpdevasalongvariablename678901:(connect=hostname_":"_portno_":TCP":delimiter=delim:attach="client"):timeout:"SOCKET"
	o tcpdevasalongvariablename678901:(connect=hostname_":"_portno_":TCP":attach="client"):timeout:"SOCKET"
	s key=$key
	w !,"client: ",key,!
	; all yours

