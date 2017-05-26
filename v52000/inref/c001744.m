;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2007-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c002003	;
	; C9B10-001744 $Order() can return wrong value if 2nd expr contains gvn
	;
	do checkcorrectness
	do checkreference
	quit
	;
checkcorrectness;
	write !,"Test $Order() gives correct result if 2nd arg is a global variable",!
	set ^x(1)=2,^x(2)=3,^x(3)=4,^y("")=1,^y(1)=-1
	zwrite ^x,^y
	for sbsx="""""",1,2,3  do
	.	for sbsy="""""",1  do
	.	.	write !
	.	.	set xstr="write $order(^x("_sbsx_"),^y("_sbsy_")),!"
	.	.	set xstr=xstr_" write ""$reference="",$reference,!"
	.	.	write xstr,!
	.	.	xecute xstr
	quit
checkreference;
	write !,"Test $Order() sets $REFERENCE correctly",!
	kill ^x
	set ^x(1)=1,^x(2)=2
	write "$order(^x(1))                      = ",$justify($order(^x(1)),4)," : $reference = ",$reference,!
	write "$order(^x(1),-1)                   = ",$justify($order(^x(1),-1),4)," : $reference = ",$reference,!
	write "$order(^x(2))                      = ",$justify($order(^x(2)),4)," : $reference = ",$reference,!
	write "$order(^x(2),-1)                   = ",$justify($order(^x(2),-1),4)," : $reference = ",$reference,!
	write "$order(^x(""""))                     = ",$justify($order(^x("")),4)," : $reference = ",$reference,!
	write "$order(^x(""""),-1)                  = ",$justify($order(^x(""),-1),4)," : $reference = ",$reference,!
	write "$order(^x(""""),1)                   = ",$justify($order(^x(""),1),4)," : $reference = ",$reference,!
	write "0!^x($order(^x(""""),$get(y,^x(1)))) = ",$justify(0!^x($order(^x(""),$get(y,^x(1)))),4)," : $reference = ",$reference,!
	write "0!^X($order(^x(""""),$select(1:-1))) = ",$justify(0!^x($order(^x(""),$select(1:-1))),4)," : $reference = ",$reference,!
	quit
