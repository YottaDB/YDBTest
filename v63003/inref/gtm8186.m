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
; Tests goto, zgoto, and do by running each command with an
; offset that prints a unique statement to indicate success
;
gtm8186
	do testgoto
	do testdo
	do testzgoto
	quit

gotomessage
	write "goto passed",!
	quit

domessage
	write "do passed",!
	quit

zogotmessage
	write "zgoto passed",!
	quit

testgoto
	GOTO +22^gtm8186
	quit

testdo
	DO +25^gtm8186
	quit

testzgoto
	ZGOTO $ZLEVEL:+30^gtm8186
	quit


