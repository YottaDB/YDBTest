;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2007, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c002916server
INETD	;
	s file="c2916out.txt" o file:newversion
	u file
	zshow "D"
	close file
	s dev=$device,dollarkey=$key
	use $p:delim=$char(13,10)
	w "from server process ",$JOB,!
	zshow "D"
	read "test lost read or write [read] ? ",!,what
	s devr=$device,dollarkeyr=$key,zeofr=$zeof,zar=$za
	if what="" s what="read"
	o file:append
	u file
	zshow "*"
	close file
	s incrtrapPRE="s trapdev=$device,trapstatus=$zstatus"
	s incrtrapNODISP=""
	u $p:(ioerror="TRAP":exception="g incrtrap^incrtrap")
	w "wrote file c2916out.txt",!,"please disconnect",!
	s (done,errorlast)=0
	for i=1:1:50 do  quit:done
	. if what="read" do
	. . r line(i)
	. . s (devcur,devr(i))=$device,dollarkeyr(i)=$key,zeofr(i)=$zeof,zar(i)=$za
	. else  do
	. . write "line "_i_" of useless output",! h 5
	. . s (devcur,devw(i))=$device,dollarkeyw(i)=$key,zeofw(i)=$zeof,zaw(i)=$za
	. o file:append u file w !,"after "_what_" "_i,! zshow "*" close file u $p
	. if devcur do
	. . if errorlast s done=1
	. . else  s errorlast=1
	. if devcur o file:append u file w !,"when $device",! zwrite  close file u $p
	o file:append u file
	write !,"at end",!
	zshow "*"
	close file
	q
