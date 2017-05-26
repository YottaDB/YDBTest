;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dollarorder	;
	for i=1:1:65 set ^a(i)=i
	do querysetup ; Though the globals are used for $query, set them up for $order too,
	write "# $order(^a) starting with null subscript",!
	set q=1 set x="" for  write "$order(^a("_x_")) = " set x=$order(^a(x)) write x,! set q=q+1 quit:q>70
	write "# $order(^a) starting with highest subscript",!
	set q=1 set x=65 for  write "$order(^a("_x_")) = " set x=$order(^a(x)) write x,! set q=q+1 quit:q>70
	write "# $order((^a),-1) starting with null subscript",!
	set q=1 set x="" for  write "$order(^a("_x_"),-1) = " set x=$order(^a(x),-1) write x,! set q=q+1 quit:q>70
	write "# $zprevious(^a) starting with null subscript",!
	set q=1 set x="" for  write "$zprevious(^a("_x_")) = " set x=$zprevious(^a(x)) write x,! set q=q+1 quit:q>70
	write "# $order(^a) starting with null subscript",!
	set q=1 set x="" for  write "$order(^x(1,"_x_")) = " set x=$order(^x(1,x)) write x,! set q=q+1 quit:q>10
	write "# $order((^x),-1) starting with null subscript",!
	set q=1 set x="" for  write "$order(^x(1,"_x_"),-1) = " set x=$order(^x(1,x),-1) write x,! set q=q+1 quit:q>10
	write "# $zprevious(^x) starting with null subscript",!
	set q=1 set x="" for  write "$zprevious(^x(1,"_x_")) = " set x=$zprevious(^x(1,x)) write x,! set q=q+1 quit:q>10
	write "# $zprevious(^x) starting with highest set subscript",!
	set q=1 set x=4 for  write "$zprevious(^x(1,"_$zwrite(x)_")) = " set x=$zprevious(^x(1,$zwrite(x))) write x,! set q=q+1 quit:q>10
	for i=4,1,0,0,0 set:i x=i write "$zprevious(^x(1,"_$zwrite(x)_")) = " set x=$zprevious(^x(1,$zwrite(x))) write x,!
	kill ^a
	; setup for $query
	do querysetup
	write "#### test $query with spanning regions ####",!
	set y="^a"
	for  set y=$query(@y) quit:y=""  write y,"=",@y,!
	write "#### test zwrite with spanning regions ####",!
	zwrite ^a
	quit
querysetup
	set ^a(1)=1
	set ^a(31)=31
	set ^a(41)=41
	set ^a(25)=25
	set ^a(40)="40"
	set ^a(40,5)="40,5"
	set ^a(40,5,7)="40,5,7"
	set ^a(40,5,8)="40,5,8"
	set ^a(40,5,8,9)="40,5,8,9"
	set ^a(40,6)="40,6"
	set ^a("a")="a"
	set ^x(1)=1
	set ^x(1,1)=1
	set ^x(1,2)=1
	set ^x(1,3)=1
	quit
