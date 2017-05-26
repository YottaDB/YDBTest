;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tterase;
	set logfile="ttlog.log"
	set newline="------------------------"
	set erase="erase",bs="BACKSPACE",del="DELETE"
	set cr=$char(13)	; carriage return character
	set esc=$char(27)	; escape character
	; Following are the values for xterm and vt320 terminal type.
	set er=$char(127),kbs=$char(127)
	;
	;
	;
	open logfile:new
	for e1="ESCAPE","NOESCAPE" do
	.	for e2="EDIT","NOEDIT" do
	.	.	for e3="EMPTERM","NOEMPTERM" do
	.	.	.	kill flag
	.	.	.	set dp=""
	.	.	.	set dp="("_e1_":"_e2_":"_e3_")"
	.	.	.	set flag("esc")=0 set:(e1="ESCAPE") flag("esc")=1
	.	.	.	set flag("edit")=0  set:(e2="EDIT") flag("edit")=1
	.	.	.	set flag("noempt")=0 set:(e3="NOEMPTERM") flag("noempt")=1
	.	.	.	use logfile write newline,! zwrite flag write newline,!
	.	.	.	do readkeys^tterase(1)
	.	.	.	do readkeys^tterase(0)
	;
	quit
	;
readkeys(empbuf);
	use $principal:@dp
	write "-------------------------------------------------------------------------",!
	write "case:"_dp,!,!
	do testerase^tterase(empbuf)
	do testbs^tterase(empbuf)
	do:(flag("edit")!flag("esc")) testdel^tterase(empbuf)
	;zwrite x,$zb,$key
	write "-------------------------------------------------------------------------",!
	quit
	;
testerase(empbuf);
	; Following are the values for xterm and vt320 terminal type.
	set er=$char(127)
	write "Enter ERASE special terminal input character"
	if (empbuf) write " on empty read buffer"
	else  write " on nonempty read buffer - Use string GTMM -"
	write:(empbuf&flag("noempt")) " followed by newline character"
	write:('empbuf) " followed by newline character"
	write !
	read x
	write:('empbuf&'flag("noempt")&(($zb=cr)&($key=cr))) !,"PASS",!
	write:('empbuf&flag("noempt")&(($zb=cr)&($key=cr))) !,"PASS",!
	write:(empbuf&'flag("noempt")&($zb=$key)&($key=er)) !,"PASS",!
	write:(empbuf&flag("noempt")&(($zb=$key)&($key=cr))) !,"PASS",!
	do:('empbuf&flag("edit")) verifyedit^tterase("ERASE special terminal input character")
	quit
testbs(empbuf);
	; Following are the values for xterm and vt320 terminal type.
	set kbs=$char(127)
	write "Enter BACKSPACE key"
	if (empbuf) write " on empty read buffer"
	else  write " on nonempty read buffer - Use string GTMM -"
	write:(empbuf&flag("noempt")) " followed by newline character"
	write:('empbuf) " followed by newline character"
	write !
	read x
	write:('empbuf&'flag("noempt")&(($zb=cr)&($key=cr))) !,"PASS",!
	write:('empbuf&flag("noempt")&(($zb=cr)&($key=cr))) !,"PASS",!
	write:(empbuf&'flag("noempt")&($zb=$key)&($key=kbs)) !,"PASS",!
	write:(empbuf&flag("noempt")&(($zb=$key)&($key=cr))) !,"PASS",!
	do:('empbuf&flag("edit")) verifyedit^tterase("BACKSPACE")
	quit
testdel(empbuf);
	; Following are the values for xterm and vt320 terminal type.
	set kdch1=esc
	set:(flag("esc")!flag("edit")) kdch1=kdch1_"[3~"
	write "Enter DELETE key"
	if (empbuf) write " on empty read buffer"
	else  write " on nonempty read buffer - Use string GTMM -"
	write:(empbuf&flag("noempt")&flag("edit")) " followed by newline character"
	write:('empbuf&flag("edit")) " followed by newline character"
	write !
	read x
	write:('empbuf&'flag("edit")&($zb=kdch1)&($key=kdch1)) !,"PASS",!
	write:('empbuf&flag("edit")&($zb=cr)&($key=cr)) !,"PASS",!
	write:(empbuf&('flag("noempt")!flag("esc"))&($zb=kdch1)&($key=kdch1)) !,"PASS",!
	write:(empbuf&flag("noempt")&($zb=cr)&($key=cr)) !,"PASS",!
	do:('empbuf&flag("edit")) verifyedit^tterase("DELETE")
	quit
	;
verifyedit(key);
	new expectx set expectx=$select(key="DELETE":"TM",1:"GTM")
	write "Enter string GTM. Go to beginning by pressing LEFT arrow key thrice. "
	write "Enter "_key_" followed by newline character",!
	read x
	write:(($zb=$key)&($zb=cr)&(x=expectx)) !,"PASS",!
	quit
