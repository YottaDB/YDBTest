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

gtm1044
	set delim="***********************************************************************************************"
	write delim,!
	write "Case 1: Test $zatransform with 2 as the third argument",!
	write "This should return the character that collates immediately after the first character",!
	write "of the first argument or an empty string if no character does. Test this for each ASCII",!
	write "character from 0 to 255."
	set notations="Straight Reverse Polish Polish-Reverse Chinese Complex"
	for i=0:1:255  do
	. write delim,!,"Testing character #",i,!
	. for j=1:1:6  do
	. . set a=$zatransform($char(i),j,2)
	. . write $piece(notations," ",j),": ",$zwrite(a),!
	write !,delim,!
	write "Case 2: Test $zatransform with -2 as the third argument",!
	write "This should return the character that collates immediately before the first character",!
	write "of the first argument or an empty string if no character does. Test this for each ASCII",!
	write "character from 0 to 255.",!
	for i=0:1:255  do
	. write delim,!,"Testing character #",i,!
	. for j=1:1:6  do
	. . set a=$zatransform($char(i),j,-2)
	. . write $piece(notations," ",j),": ",$zwrite(a),!
	write !,delim,!
	write "Case 3: Test $zatransform with 2 and -2 as the third argument",!
	write "This time, we use several strings to make sure they're handled correctly.",!
	write "These strings are abc123, bc123a and c123ab. Each string is run through a",!
	write "$zatransform command with 2 as the third argument then one with -2 as the",!
	write "third argument. Output is in the same order they're run, separated by spaces.",!
	for i=1:1:6  do
	. set aplus=$zatransform("abc123",i,2)
	. set aminus=$zatransform("abc123",i,-2)
	. set bplus=$zatransform("bc123a",i,2)
	. set bminus=$zatransform("bc123a",i,-2)
	. set cplus=$zatransform("c123ab",i,2)
	. set cminus=$zatransform("c123ab",i,-2)
	. write $piece(notations," ",i),": ",$zwrite(aplus)," ",$zwrite(aminus)," ",$zwrite(bplus)," ",$zwrite(bminus)," ",$zwrite(cplus)," ",$zwrite(cminus),!
	write !,delim,!
	quit
