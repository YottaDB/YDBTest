;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set x=$zcmdline
	do @x
	do namelevelorder
	quit
namelevelorder
	new x
	write "# Name-level $order     loop",! set x="^%"
	for  write "$o(",x,") = " set x=$order(@x,1) q:x=""  write x,!
	write !,"# Name-level $zprevious loop",! set x="^z"
	for  write "$zp(",x,") = " set x=$zprevious(@x) q:x=""  write x,!
	quit
1;
	set ^w=1
	set ^y=1
	quit
2;
	set ^w=1
	set ^x=1
	set ^y=1
	quit
3;
	set ^w=1
	set ^x(10)=1
	set ^y=1
	quit
4;
	set ^w=1
	set ^x(40)=1
	set ^y=1
	quit
5;
	set ^w=1
	set ^x0=1
	set ^y=1
	quit
6;
	set setup="set (^w,^x,^x(10),^x(40),^y)=1"
	write setup,! xecute setup
	do namelevelorder
	set kill="zkill ^x"
	write kill,! xecute kill
	do namelevelorder
	set kill="kill ^x(10)"
	write kill,! xecute kill
	do namelevelorder
	set kill="kill ^x(40)"
	write kill,! xecute kill
	do namelevelorder
	quit
7;
	set setup="set (^a(11),^a(21),^a(31),^b(11),^b(21),^b(31),^c(11),^c(21),^c(31))=1"
	write setup,! xecute setup
	do namelevelorder
	set kill="kill ^a(11),^b(11),^c(11)"
	write kill,! xecute kill
	do namelevelorder
	set kill="kill ^a(21),^b(21),^c(21)"
	write kill,! xecute kill
	do namelevelorder
	quit
8;
	set setup="set (^a(11),^a(21),^a(31),^b(11),^b(21),^b(31),^c(11),^c(21),^c(31))=1"
	write setup,! xecute setup
	do namelevelorder
	set kill="kill ^a(11),^b(21),^c(31)"
	write kill,! xecute kill
	do namelevelorder
	set kill="kill ^a(21),^b(31),^c(11)"
	write kill,! xecute kill
	do namelevelorder
	quit
