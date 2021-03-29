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
gtm9180
	set cmd(1)="add -block=2147483648 -data=""Too large for V6"" -key=""^y(1)"" -data=""abc"""
	set cmd(2)="add -block=2200000000 -data=""Too large for V6"" -key=""^y(2)"" -data=""def"""
	set cmd(3)="add -block=2500000000 -data=""Too large for V6"" -key=""^y(3)"" -data=""ghi"""
	set cmd(4)="add -block=5000000000 -data=""Too large for V6"" -key=""^y(4)"" -data=""jkl"""
	set cmd(5)="add -block=50000000000 -data=""Too large for V6"" -key=""^y(5)"" -data=""mno"""
	set cmd(6)="add -block=500000000000 -data=""Too large for V6"" -key=""^y(6)"" -data=""pqr"""
	set cmd(7)="add -block=5000000000000 -data=""Too large for V6"" -key=""^y(7)"" -data=""stu"""
	set cmd(8)="add -block=50000000000000 -data=""Too large for V6"" -key=""^y(8)"" -data=""vwx"""
	set cmd(9)="add -block=500000000000000 -data=""Too large for V6"" -key=""^y(9)"" -data=""yza"""
	set cmd(10)="add -block=5000000000000000 -data=""Too large for V6"" -key=""^y(10)"" -data=""bcd"""
	set cmd(11)="add -block=50000000000000000 -data=""Too large for V6"" -key=""^y(11)"" -data=""efg"""
	set cmd(12)="add -block=500000000000000000 -data=""Too large for V6"" -key=""^y(12)"" -data=""hij"""
	set cmd(13)="add -block=5000000000000000000 -data=""Too large for V6"" -key=""^y(13)"" -data=""klm"""
	set cmd(14)="add -block=9223372036854775807 -data=""Too large for V6"" -key=""^y(14)"" -data=""nop"""
	set cmd(15)="add -block=9223372036854775808 -data=""Too large for V6"" -key=""^y(15)"" -data=""qrs"""
	set cmd(16)="dump -block=2147483648"
	set cmd(17)="dump -block=2200000000"
	set cmd(18)="dump -block=2500000000"
	set cmd(19)="dump -block=5000000000"
	set cmd(20)="dump -block=50000000000"
	set cmd(21)="dump -block=500000000000"
	set cmd(22)="dump -block=5000000000000"
	set cmd(23)="dump -block=50000000000000"
	set cmd(24)="dump -block=500000000000000"
	set cmd(25)="dump -block=5000000000000000"
	set cmd(26)="dump -block=50000000000000000"
	set cmd(27)="dump -block=500000000000000000"
	set cmd(28)="dump -block=5000000000000000000"
	set cmd(29)="dump -block=9223372036854775807"
	set cmd(30)="dump -block=9223372036854775808"
	set cmd(31)="dump -block=9223372036854775806"

	for i=1:1:31  do
	. write "running DSE command: ",cmd(i),!
	. zsystem "$DSE "_cmd(i)
	. write !,"###################################################################",!
