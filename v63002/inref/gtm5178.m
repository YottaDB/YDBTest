;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm5178
	write !,!,"# CODE EXECUTES IGNORING THE LINES THAT CREATED WARNINGS",!
	do ^sstep
	do test1^gtm5178
	do test2^gtm5178
	do test3^gtm5178
	do test4^gtm5178
	do test5^gtm5178
	quit
test1
	for i=1:1:1 do
	. . write "2 dots beneath a for loop with no dots",!
	quit

test2
	. write "1 dot beneath a line with no dots",!
	quit

test3
	. . write "2 dots beneath a line with no dots",!
	quit

test4
	do
	. write "1 dot beneath a do with no dots",!
	. do
	. . write "2 dots beneath a do with 1 dot",!
	quit

test5
	do
	. write "1 dot beneath a do with no dots",!
	. do
	. . write "2 dots beneath a do with 1 dot",!
	. . do
	. . . . write "4 dots beneath a do with 2 dot",!
	. . write "2 dots after the 4 dots should produce an error (should still be compiled properly)",!
	quit
