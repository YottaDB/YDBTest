docat4
	; add writeonly to all opens
	; cat is just an arbitrary unix command used to test the pipe.  The command can be any valid unix command
	write "Create pipe device handles p1-p4",!
	set p1="test1"
	set p2="test2"
	set p3="test3"
	set p4="test4"
	set cshell=$SELECT($ZV["OS390":"/bin/tcsh",1:"/bin/csh")
	set pinfo="process_info.outx"
	write "Open pipe device p1 using csh as the shell with output from f100.m piped to cat | tr -d e >out1",!
	write "tr will delete the letter e from the input",!!
	write "Open pipe device p2 using sh as the shell with output from funcs100.m piped to cat>out2",!!
	write "Open pipe device p3 using tcsh as the shell with output from f100.m piped to cat>out3",!!
	write "Open pipe device p4 defaulting to sh as the shell with output from funcs100.m piped to tr 7 z > out4",!
	write "tr will change number 7 to the letter z",!!
	open p1:(shell=cshell:command="cat -u| tr -d e >out1":writeonly:stderr="e1")::"pipe"
	use p1
	set k1=$KEY
	do ^f100
	open p2:(shell="/bin/sh":command="cat -u>out2":writeonly:stderr="e2")::"pipe"
	use p2
	set k2=$KEY
	do ^funcs100
	open p3:(newversion:shell="/usr/local/bin/tcsh":command="cat -u>out3":writeonly:stderr="e3"):10:"pipe"
	use p3
	set k3=$KEY
	do ^f100
	open p4:(command="tr 7 z > out4":writeonly:stderr="e4")::"pipe"
	use p4
	set k4=$KEY
	do ^funcs100
	use $p
	open pinfo
	use pinfo
	write !,"process numbers are:  ",k1," ",k2," ",k3," ",k4,!!
	close pinfo
	zsystem "ps -ef | grep -v grep | grep -v ps >> process_info.outx"
	use $p
	write !!,"Execute zshow to see which devices are open",!!
	zshow "d"
	write !,"After writing the pipe handle name to the end of each open pipe device, each device is closed",!!
	use p1
	write p1,!
	close p1
	use p2
	write p2,!
	close p2
	use p3
	write p3,!
	close p3
	use p4
	write p4,!
	close p4
	write "Execute zshow to show the pipe devices are closed",!!
	zshow "d"
	quit
