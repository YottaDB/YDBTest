;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                ;
;  Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       ;
;  All rights reserved.                                          ;
;                                                                ;
;        This source code contains the intellectual property     ;
;        of its copyright holder(s), and is made available       ;
;        under a license.  If you do not know the terms of       ;
;        the license, please stop and do not read further.       ;
;                                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for GTM-9321 - Test to check that $ORDER(<indirection>,<literal>) maintains correct $REFERENCE value
;
; Test methodology:
;  - Global variable is created.
;  - Loop through the subscripts of the global variable
;    - Reference($data(^dd)) a different global variable to set the value of $REFERENCE(old)
;    - Access the previous subscript value($order()) using indirection, thus updating $REFERENCE
gtm9321
	write !,"# Creating global variable",!
	set ^house("Harry Potter")="Gryffindor"
	set ^house("Draco Malfoy")="Slytherin"
	set ^house("Cedric Diggory")="Hufflepuff"
	set ^house("Cho Chang")="Ravenclaw"
	write !,"# Testing $ORDER(<indirection>,<literal>)",!
	write !,"# $REFERENCE(old) | Previous subscript | $REFERENCE(current)",!
	new x,y,l set x=""
	for  set x=$order(^house(x)) quit:x=""  do
	. set y=$name(^house(x))
	. set:$data(^dd) l=0
	. write $reference,?18,"| ",$order(@y,-1),?39,"| ",$reference,!
