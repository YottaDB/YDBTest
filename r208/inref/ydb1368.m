;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
ydb1368	; Called by r208/u_inref/next_naked-ydb1368.csh. Each stageN label is a stage.
	quit
stage1	; a SET of a naked reference after a $NEXT() that returns -1
	set ^x(1)=1
	write "$next=",$next(^x(5)),!
	set ^(7)="seven"
	write "$reference=",$reference,!
	quit
stage2	; a $GET() of a naked reference after a $NEXT() that returns -1
	set ^x(1)=1
	write "$next=",$next(^x(5)),!
	write "$get=",$get(^(1)),!
	write "$reference=",$reference,!
	quit
stage3	; a loop of $NEXT() of a naked reference, each of which returns -1
	new i,y
	write "$next=",$next(^x(5)),!
	for i=1:1:40 set y=$next(^(-1))
	write "i=",i," y=",y,!
	write "$reference=",$reference,!
	quit
stage4	; a SET of a naked reference with 2 subscripts after a $NEXT() that returns -1
	set ^x(3,1)=31
	write "$next=",$next(^x(3,5)),!
	set ^(9)="nine"
	write "$reference=",$reference,!
	quit
stage7	; a $ORDER() and then a SET of a naked reference after a $NEXT() that returns -1
	set ^x(1)=1
	write "$next=",$next(^x(5)),!
	write "$order=",$order(^(0)),!
	write "$reference=",$reference,!
	set ^(7)="seven"
	write "$reference=",$reference,!
	quit
