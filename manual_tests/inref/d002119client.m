	read "What host [localhost]: ",host,!
	read "What port [7777]: ",port,!
	if host="" set host="localhost"
	if port="" set port=7777
	set sock="sock1"
	open sock:(connect=host_":"_port_":TCP":delim=$char(13,10):ioerror="TRAP")::"SOCKET"
	write "connected to ",host,":",port,!
	zshow "D"
	use sock:(ioerror="TRAP":exception="zgoto "_$zlevel_":error")
	; soak up zshow "D" from server
	for i=0:1:10 read a(i) q:a(i)["something"
	s dev0=$DEVICE
	use $principal
	write "Please respond to ",host," - ",a(i)
	read answer
	use sock
	write answer,!
	s dev1=$DEVICE
	for j=0:1:20 read b(j) s dev=$DEVICE,key=$KEY q:b(j)="the end"
	use $principal
	write !,"success",!
	quit

error	use $principal
	write "socket error:",!
	ZSHOW "*"
	quit
